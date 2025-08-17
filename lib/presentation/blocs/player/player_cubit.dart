import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/player_preferences.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository;
  final SettingsRepository _settingsRepository;
  StreamController<int>? _positionController;
  Timer? _sleepTimer;

  PlayerCubit(this._playerRepository, this._settingsRepository)
    : super(PlayerState.initial()) {
    _initializePositionStream();
    _initializePlaybackSpeed();
  }

  void _initializePlaybackSpeed() {
    final savedSpeed = _settingsRepository.getSettings().playbackSpeed;
    emit(state.copyWith(playbackSpeed: savedSpeed));
    _playerRepository.setPlaybackSpeed(savedSpeed);
  }

  Future<void> setPlayingSong(List<SongModel> playlist, SongModel song) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    final bool isPlaying = await _playerRepository.play(song.data);
    emit(
      state.copyWith(
        playlist: playlist,
        currentIndex: index,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> nextSong() async {
    if (state.playlist.isEmpty) return;

    int nextIndex;
    if (state.repeatMode == RepeatMode.one) {
      nextIndex = state.currentIndex;
    } else {
      nextIndex = _getNextIndex();
    }

    final bool isPlaying = await _playerRepository.play(
      state.playlist[nextIndex].data,
    );
    emit(state.copyWith(currentIndex: nextIndex, isPlaying: isPlaying));
  }

  Future<void> previousSong() async {
    if (state.playlist.isEmpty) return;

    int previousIndex;
    if (state.repeatMode == RepeatMode.one) {
      previousIndex = state.currentIndex;
    } else {
      previousIndex = _getPreviousIndex();
    }

    final bool isPlaying = await _playerRepository.play(
      state.playlist[previousIndex].data,
    );
    emit(state.copyWith(currentIndex: previousIndex, isPlaying: isPlaying));
  }

  Future<void> togglePlayPause() async {
    final bool isPlaying = await _playerRepository.togglePlayPause();
    emit(state.copyWith(isPlaying: isPlaying));
  }

  void _initializePositionStream() {
    _positionController = StreamController<int>.broadcast();
    _startPositionUpdates();
  }

  Future<void> _startPositionUpdates() async {
    while (!isClosed) {
      if (state.isPlaying) {
        final position = await _playerRepository.getCurrentPosition();
        final currentPositionMs = position?.inMilliseconds ?? 0;

        if (!_positionController!.isClosed) {
          _positionController!.add(currentPositionMs);
        }

        final currentSong = state.currentSong;
        if (currentSong != null && currentPositionMs > 0) {
          final songDurationMs = currentSong.duration ?? 0;
          final isNearEnd = currentPositionMs >= (songDurationMs - 1000);

          // Verificar si el sleep timer está esperando que termine la canción
          if (state.isSleepTimerActive &&
              state.sleepTimerRemaining == Duration.zero &&
              state.waitForSongToFinish &&
              isNearEnd) {
            // La canción terminó y estábamos esperando - pausar ahora
            await _playerRepository.pause();
            emit(state.copyWith(isPlaying: false));
            stopSleepTimer();
            return;
          }

          if (isNearEnd && state.hasSelectedSong) {
            if (state.repeatMode == RepeatMode.one) {
              await _playerRepository.seek(Duration.zero);
            } else if (state.repeatMode == RepeatMode.all ||
                state.playlist.length > 1) {
              await nextSong();
            }
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        final position = await _playerRepository.getCurrentPosition();
        if (!_positionController!.isClosed) {
          _positionController!.add(position?.inMilliseconds ?? 0);
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Stream<int> getCurrentSongPosition() {
    return _positionController?.stream ?? const Stream.empty();
  }

  Future<void> seekTo(Duration position) async {
    final bool isPlaying = await _playerRepository.seek(position);
    emit(state.copyWith(isPlaying: isPlaying));
  }

  void toggleShuffle() {
    final newShuffleState = !state.isShuffleEnabled;
    emit(state.copyWith(isShuffleEnabled: newShuffleState));
    _savePlayerPreferences();
  }

  void toggleRepeat() {
    RepeatMode newMode;
    switch (state.repeatMode) {
      case RepeatMode.none:
        newMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.none;
        break;
    }
    emit(state.copyWith(repeatMode: newMode));
    _savePlayerPreferences();
  }

  int _getNextIndex() {
    if (state.isShuffleEnabled) {
      if (state.playlist.length <= 1) return state.currentIndex;
      final random = Random();
      int nextIndex;
      do {
        nextIndex = random.nextInt(state.playlist.length);
      } while (nextIndex == state.currentIndex);
      return nextIndex;
    } else {
      if (state.currentIndex < state.playlist.length - 1) {
        return state.currentIndex + 1;
      } else {
        return 0;
      }
    }
  }

  int _getPreviousIndex() {
    if (state.isShuffleEnabled) {
      if (state.playlist.length <= 1) return state.currentIndex;
      final random = Random();
      int previousIndex;
      do {
        previousIndex = random.nextInt(state.playlist.length);
      } while (previousIndex == state.currentIndex);
      return previousIndex;
    } else {
      if (state.currentIndex > 0) {
        return state.currentIndex - 1;
      } else {
        return state.playlist.length - 1;
      }
    }
  }

  void startSleepTimer(Duration duration, bool waitForSong) {
    stopSleepTimer();

    emit(
      state.copyWith(
        sleepTimerDuration: duration,
        sleepTimerRemaining: duration,
        isSleepTimerActive: true,
        waitForSongToFinish: waitForSong,
      ),
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        _handleSleepTimerExpired();
        return;
      }

      final newRemaining = Duration(seconds: remaining.inSeconds - 1);
      emit(state.copyWith(sleepTimerRemaining: newRemaining));
    });
  }

  void stopSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    emit(state.copyWith(isSleepTimerActive: false, waitForSongToFinish: false));
  }

  void toggleWaitForSongToFinish() {
    emit(state.copyWith(waitForSongToFinish: !state.waitForSongToFinish));
  }

  Future<void> _handleSleepTimerExpired() async {
    if (state.waitForSongToFinish && state.isPlaying && state.hasSelectedSong) {
      final currentSong = state.currentSong;
      if (currentSong != null) {
        final position = await _playerRepository.getCurrentPosition();
        final currentPositionMs = position?.inMilliseconds ?? 0;
        final songDurationMs = currentSong.duration ?? 0;
        final isNearEnd = currentPositionMs >= (songDurationMs - 5000);

        if (!isNearEnd) {
          // Timer expiró pero esperamos el final de la canción
          // Cambiar el timer para que se active cuando termine la canción
          _sleepTimer?.cancel();
          _sleepTimer = null;

          // Actualizar estado para mostrar que está esperando el final
          emit(
            state.copyWith(
              sleepTimerRemaining: Duration.zero,
              // Mantener isSleepTimerActive true para indicar que sigue esperando
            ),
          );
          return;
        }
      }
    }

    // Pausar la música y limpiar el timer
    await _playerRepository.pause();
    emit(state.copyWith(isPlaying: false));
    stopSleepTimer();
  }

  Future<bool> setPlaybackSpeed(double speed) async {
    if (!state.hasSelectedSong) {
      return false;
    }

    final success = await _playerRepository.setPlaybackSpeed(speed);
    if (success) {
      emit(state.copyWith(playbackSpeed: speed));
    }
    return success;
  }

  double getPlaybackSpeed() {
    return _playerRepository.getPlaybackSpeed();
  }

  void _savePlayerPreferences() {
    final preferences = PlayerPreferences(
      isShuffleEnabled: state.isShuffleEnabled,
      repeatMode: state.repeatMode,
    );
    Preferences.playerPreferences = preferences;
  }

  @override
  Future<void> close() {
    _positionController?.close();
    _sleepTimer?.cancel();
    return super.close();
  }
}
