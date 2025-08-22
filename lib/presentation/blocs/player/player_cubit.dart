import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/player_preferences.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

/// Cubit que maneja el estado del reproductor de música.
/// 
/// Gestiona la reproducción de canciones, playlists, modos de repetición,
/// shuffle, velocidad de reproducción y temporizador de sueño.
/// 
/// Características principales:
/// - Reproducción con shuffle inteligente (canción actual siempre primera)
/// - Tres modos de repetición: none, one, all
/// - Navegación preservando listas shuffle existentes
/// - Auto-advance con lógica diferenciada por modo de repetición
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

  /// Establece una nueva canción y playlist para reproducir.
  /// 
  /// Regenera una nueva lista shuffle (a menos que se proporcione una existente)
  /// con la canción seleccionada como primera en la secuencia aleatoria.
  /// 
  /// [playlist] - Lista original de canciones
  /// [song] - Canción a reproducir
  /// [shuffledPlaylist] - Lista shuffle existente (opcional, para preservar secuencia)
  Future<void> setPlayingSong(
    List<SongModel> playlist,
    SongModel song,
    List<SongModel>? shuffledPlaylist,
  ) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    final bool isPlaying = await _playerRepository.play(song.data);

    // Generar nueva lista shuffle
    final shufflePlaylist =
        shuffledPlaylist ?? _generateShufflePlaylist(playlist, song);
    // Si se generó una nueva lista shuffle, la canción será el índice 0
    final shuffleIndex = shuffledPlaylist != null
        ? shufflePlaylist.indexWhere((s) => s.id == song.id)
        : 0;

    emit(
      state.copyWith(
        playlist: playlist,
        shufflePlaylist: shufflePlaylist,
        currentIndex: state.isShuffleEnabled ? shuffleIndex : index,
        isPlaying: isPlaying,
      ),
    );
  }

  /// Avanza a la siguiente canción en la lista activa.
  /// 
  /// Comportamiento según modo de repetición:
  /// - RepeatMode.one: Repite la canción actual
  /// - RepeatMode.all/none: Avanza según lógica de navegación
  Future<void> nextSong() async {
    if (state.activePlaylist.isEmpty) return;

    int nextIndex;
    if (state.repeatMode == RepeatMode.one) {
      nextIndex = state.currentIndex;
    } else {
      nextIndex = _getNextIndex();
    }

    final bool isPlaying = await _playerRepository.play(
      state.activePlaylist[nextIndex].data,
    );
    emit(state.copyWith(currentIndex: nextIndex, isPlaying: isPlaying));
  }

  /// Retrocede a la canción anterior en la lista activa.
  /// 
  /// Comportamiento según modo de repetición:
  /// - RepeatMode.one: Repite la canción actual
  /// - RepeatMode.all/none: Retrocede según lógica de navegación
  Future<void> previousSong() async {
    if (state.activePlaylist.isEmpty) return;

    int previousIndex;
    if (state.repeatMode == RepeatMode.one) {
      previousIndex = state.currentIndex;
    } else {
      previousIndex = _getPreviousIndex();
    }

    final bool isPlaying = await _playerRepository.play(
      state.activePlaylist[previousIndex].data,
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
            } else if (state.repeatMode == RepeatMode.all) {
              await nextSong();
            } else if (state.repeatMode == RepeatMode.none) {
              // Solo avanzar si NO es la última canción
              if (state.currentIndex < state.activePlaylist.length - 1) {
                await nextSong();
              } else {
                // Es la última canción: volver al inicio pero sin reproducir
                await nextSong();
                final bool isPlaying = await _playerRepository.pause();
                emit(state.copyWith(isPlaying: isPlaying));
              }
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

  /// Alterna entre modo shuffle activado/desactivado.
  /// 
  /// Al activar shuffle:
  /// - Genera nueva lista aleatoria con canción actual como primera
  /// - Establece currentIndex = 0 (canción actual al inicio)
  /// 
  /// Al desactivar shuffle:
  /// - Vuelve a usar playlist original
  /// - Recalcula currentIndex según posición en lista original
  void toggleShuffle() {
    final newShuffleState = !state.isShuffleEnabled;

    if (newShuffleState) {
      // Activando shuffle: generar nueva lista shuffle y encontrar índice actual
      final currentSong = state.currentSong;
      if (currentSong != null) {
        final newShufflePlaylist = _generateShufflePlaylist(
          state.playlist,
          currentSong,
        );
        // La canción actual siempre será el índice 0 en la nueva lista shuffle
        const newCurrentIndex = 0;

        emit(
          state.copyWith(
            isShuffleEnabled: newShuffleState,
            shufflePlaylist: newShufflePlaylist,
            currentIndex: newCurrentIndex,
          ),
        );
      } else {
        emit(state.copyWith(isShuffleEnabled: newShuffleState));
      }
    } else {
      // Desactivando shuffle: encontrar índice en playlist original
      final currentSong = state.currentSong;
      if (currentSong != null) {
        final newCurrentIndex = state.playlist.indexWhere(
          (s) => s.id == currentSong.id,
        );
        emit(
          state.copyWith(
            isShuffleEnabled: newShuffleState,
            currentIndex: newCurrentIndex,
          ),
        );
      } else {
        emit(state.copyWith(isShuffleEnabled: newShuffleState));
      }
    }

    _savePlayerPreferences();
  }

  /// Alterna entre los modos de repetición en ciclo: none → one → all → none.
  /// 
  /// Modos de repetición:
  /// - RepeatMode.none: Reproduce secuencialmente, se detiene al final
  /// - RepeatMode.one: Repite la canción actual indefinidamente  
  /// - RepeatMode.all: Repite toda la playlist indefinidamente
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

  /// Calcula el índice de la siguiente canción en la lista activa.
  /// 
  /// Permite wrap-around para navegación manual (diferente del auto-advance).
  /// El auto-advance tiene su propia lógica en _startPositionUpdates.
  int _getNextIndex() {
    final activePlaylist = state.activePlaylist;
    if (activePlaylist.length <= 1) return state.currentIndex;

    if (state.currentIndex < activePlaylist.length - 1) {
      return state.currentIndex + 1;
    } else {
      // Para RepeatMode.none, permitir wrap-around en navegación manual
      // El auto-advance ya está manejado en _startPositionUpdates
      return 0;
    }
  }

  /// Calcula el índice de la canción anterior en la lista activa.
  /// 
  /// Permite wrap-around para navegación manual (diferente del auto-advance).
  /// El auto-advance tiene su propia lógica en _startPositionUpdates.
  int _getPreviousIndex() {
    final activePlaylist = state.activePlaylist;
    if (activePlaylist.length <= 1) return state.currentIndex;

    if (state.currentIndex > 0) {
      return state.currentIndex - 1;
    } else {
      // Para RepeatMode.none, permitir wrap-around en navegación manual
      // El auto-advance ya está manejado en _startPositionUpdates
      return activePlaylist.length - 1;
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

  void insertSongNext(SongModel song) {
    if (state.playlist.isEmpty) return;

    final newPlaylist = List<SongModel>.from(state.playlist);
    final insertIndex = state.currentIndex + 1;

    if (insertIndex < newPlaylist.length) {
      newPlaylist.insert(insertIndex, song);
    } else {
      newPlaylist.add(song);
    }

    emit(state.copyWith(playlist: newPlaylist));
  }

  void addToQueue(SongModel song) {
    final newPlaylist = List<SongModel>.from(state.playlist)..add(song);
    emit(state.copyWith(playlist: newPlaylist));
  }

  void removeFromQueue(SongModel song) {
    if (state.playlist.isEmpty) return;

    final songIndex = state.playlist.indexWhere((s) => s.id == song.id);
    if (songIndex == -1) return;

    final newPlaylist = List<SongModel>.from(state.playlist)
      ..removeAt(songIndex);

    // Adjust current index if necessary
    int newCurrentIndex = state.currentIndex;
    if (songIndex < state.currentIndex) {
      newCurrentIndex = state.currentIndex - 1;
    } else if (songIndex == state.currentIndex) {
      // If removing current song, pause playback
      _playerRepository.pause();
      if (newPlaylist.isNotEmpty) {
        // Play next song or adjust index
        if (newCurrentIndex >= newPlaylist.length) {
          newCurrentIndex = 0;
        }
        final nextSong = newPlaylist[newCurrentIndex];
        _playerRepository.play(nextSong.data);
      } else {
        newCurrentIndex = -1;
      }
    }

    emit(
      state.copyWith(
        playlist: newPlaylist,
        currentIndex: newCurrentIndex,
        isPlaying: newPlaylist.isNotEmpty && songIndex == state.currentIndex,
      ),
    );
  }

  /// Genera una nueva lista shuffle aleatoria.
  /// 
  /// Si se proporciona [currentSong], la coloca como primera en la lista
  /// para mantener continuidad en la reproducción. El resto de canciones
  /// se mezclan aleatoriamente.
  /// 
  /// [playlist] - Lista original de canciones
  /// [currentSong] - Canción que debe ser primera (opcional)
  /// 
  /// Returns: Lista mezclada con canción actual al inicio (si se proporciona)
  List<SongModel> _generateShufflePlaylist(
    List<SongModel> playlist, [
    SongModel? currentSong,
  ]) {
    if (playlist.isEmpty) return [];

    final shuffled = List.of(playlist);
    shuffled.shuffle();

    // Si hay una canción actual, asegurarse de que sea la primera
    if (currentSong != null) {
      final currentIndex = shuffled.indexWhere((s) => s.id == currentSong.id);
      if (currentIndex != -1) {
        // Mover la canción actual al inicio
        final current = shuffled.removeAt(currentIndex);
        shuffled.insert(0, current);
      }
    }

    return shuffled;
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
