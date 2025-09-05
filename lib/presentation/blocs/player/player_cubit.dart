import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/player_preferences.dart';
import 'package:sonofy/data/repositories/player_repository_impl.dart';
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
class PlayerCubit extends Cubit<PlayerState> with WidgetsBindingObserver {
  final PlayerRepository _playerRepository;
  final SettingsRepository _settingsRepository;
  StreamController<int>? _positionController;
  Timer? _sleepTimer;
  StreamSubscription<PlayerEvent>? _playerEventsSubscription;

  PlayerCubit(this._playerRepository, this._settingsRepository)
    : super(PlayerState.initial()) {
    _initializePositionStream();
    _initializePlaybackSpeed();
    _subscribeToPlayerEvents();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializePlaybackSpeed() {
    final savedSpeed = _settingsRepository.getSettings().playbackSpeed;
    emit(state.copyWith(playbackSpeed: savedSpeed));
    _playerRepository.setPlaybackSpeed(savedSpeed);
    _initializeEqualizer();
    _initializeVolume();
  }

  void _initializeEqualizer() {
    final settings = _settingsRepository.getSettings();
    final equalizerSettings = settings.equalizerSettings;

    // Aplicar configuración del ecualizador al PlayerRepository
    _playerRepository.setEqualizerEnabled(equalizerSettings.isEnabled);
    for (int i = 0; i < equalizerSettings.bands.length; i++) {
      _playerRepository.setEqualizerBand(i, equalizerSettings.bands[i].gain);
    }
  }

  Future<void> _initializeVolume() async {
    try {
      final currentVolume = await _playerRepository.getVolume();
      emit(state.copyWith(volume: currentVolume));
    } catch (e) {
      // Si hay error obteniendo el volumen, usar valor por defecto
      emit(state.copyWith(volume: 0.5));
    }
  }

  void _subscribeToPlayerEvents() {
    _playerEventsSubscription = _playerRepository.playerEvents.listen((event) {
      switch (event) {
        case PlayEvent():
          if (!state.isPlaying) {
            emit(state.copyWith(isPlaying: true));
          }
          break;
        case PauseEvent():
          if (state.isPlaying) {
            emit(state.copyWith(isPlaying: false));
          }
          break;
        case NextEvent():
          nextSong();
          break;
        case PreviousEvent():
          previousSong();
          break;
        case SeekEvent():
          // La posición se actualizará automáticamente por el stream de posición
          break;
      }
    });
  }

  /// Maneja los cambios de estado del ciclo de vida de la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    
    print('🔄 [PlayerCubit] App lifecycle changed to: $lifecycleState');
    
    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        // La app volvió al foreground - sincronizar estado del reproductor
        print('📱 [PlayerCubit] App resumed - syncing player state');
        _syncPlayerStateOnResume();
        break;
      case AppLifecycleState.paused:
        print('📱 [PlayerCubit] App paused');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // App en background o siendo cerrada
        print('📱 [PlayerCubit] App in background/hidden/detached');
        break;
    }
  }

  /// Sincroniza el estado del reproductor cuando la app vuelve del background
  Future<void> _syncPlayerStateOnResume() async {
    print('🔄 [PlayerCubit] Starting sync on resume...');
    await _syncNativePlayerState(forceSync: true);
  }

  /// Sincroniza el estado del reproductor nativo periódicamente
  Future<void> _syncNativePlayerStateIfNeeded() async {
    // Solo sincronizar cada 2 segundos para no sobrecargar
    if (_lastSyncTime != null && 
        DateTime.now().difference(_lastSyncTime!).inMilliseconds < 2000) {
      return;
    }
    
    await _syncNativePlayerState(forceSync: false);
  }

  DateTime? _lastSyncTime;

  /// Método centralizado para sincronizar el estado del reproductor nativo
  Future<void> _syncNativePlayerState({required bool forceSync}) async {
    if (_playerRepository is! PlayerRepositoryImpl) return;
    
    final repo = _playerRepository as PlayerRepositoryImpl;
    
    // Verificar si estamos usando reproductor nativo
    if (!repo.isUsingNativePlayer) return;
    
    if (forceSync) {
      print('🔄 [PlayerCubit] Force syncing native player state...');
      print('🎵 [PlayerCubit] Current UI state - isPlaying: ${state.isPlaying}');
    }
    
    await _playerRepository.syncNativePlayerState();
    _lastSyncTime = DateTime.now();
    
    // También actualizar el MediaItem con la información actual
    final currentSong = state.currentSong;
    if (currentSong != null && forceSync) {
      print('🎵 [PlayerCubit] Updating MediaItem for: ${currentSong.title}');
      repo.updateCurrentMediaItem(
        currentSong.title,
        currentSong.artist ?? currentSong.composer ?? 'Unknown Artist',
        null, // TODO(dev): Agregar artwork URI si está disponible
      );
    }
    
    // Verificar y actualizar el estado de reproducción en el UI
    final isCurrentlyPlaying = _playerRepository.isPlaying();
    
    if (forceSync) {
      print('🎵 [PlayerCubit] Repository says isPlaying: $isCurrentlyPlaying');
    }
    
    if (state.isPlaying != isCurrentlyPlaying) {
      if (forceSync) {
        print('🔄 [PlayerCubit] UI state mismatch! Updating UI: ${state.isPlaying} → $isCurrentlyPlaying');
      }
      emit(state.copyWith(isPlaying: isCurrentlyPlaying));
    } else if (forceSync) {
      print('✅ [PlayerCubit] UI state is in sync');
    }
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
    final bool isPlaying = await _playerRepository.playTrack(song.data);

    // Generar nueva lista shuffle
    final shufflePlaylist =
        shuffledPlaylist ?? _generateShufflePlaylist(playlist, song);
    // Si se generó una nueva lista shuffle, la canción será el índice 0
    final shuffleIndex = shuffledPlaylist != null
        ? shufflePlaylist.indexWhere((s) => s.id == song.id)
        : 0;

    // Actualizar MediaItem para AudioService
    _updateAudioServiceMediaItem(song);

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

    final bool isPlaying = await _playerRepository.playTrack(
      state.activePlaylist[nextIndex].data,
    );

    // Actualizar MediaItem para AudioService
    _updateAudioServiceMediaItem(state.activePlaylist[nextIndex]);

    emit(state.copyWith(currentIndex: nextIndex, isPlaying: isPlaying));
  }

  /// Retrocede a la canción anterior en la lista activa.
  ///
  /// Comportamiento según modo de repetición:
  /// - RepeatMode.one: Repite la canción actual
  /// - RepeatMode.all/none: Retrocede según lógica de navegación
  ///
  /// Comportamiento según posición actual:
  /// - Si la canción lleva más de 5 segundos: reinicia desde el inicio
  /// - Si la canción lleva menos de 5 segundos: va a la canción anterior
  Future<void> previousSong() async {
    if (state.activePlaylist.isEmpty) return;

    // Obtener la posición actual de la canción
    final currentPosition = await _playerRepository.getCurrentPosition();
    final currentPositionMs = currentPosition?.inMilliseconds ?? 0;
    const fiveSecondsInMs = 5 * 1000; // 5 segundos en milisegundos

    // Si han pasado más de 5 segundos, reiniciar la canción desde el inicio
    if (currentPositionMs > fiveSecondsInMs) {
      await _playerRepository.seekToPosition(Duration.zero);
      return;
    }

    // Si han pasado menos de 5 segundos, ir a la canción anterior
    int previousIndex;
    if (state.repeatMode == RepeatMode.one) {
      previousIndex = state.currentIndex;
    } else {
      previousIndex = _getPreviousIndex();
    }

    final bool isPlaying = await _playerRepository.playTrack(
      state.activePlaylist[previousIndex].data,
    );

    // Actualizar MediaItem para AudioService
    _updateAudioServiceMediaItem(state.activePlaylist[previousIndex]);

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

  Timer? _positionTimer;

  int _controlCenterUpdateCounter = 0;

  Future<void> _startPositionUpdates() async {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final position = await _playerRepository.getCurrentPosition();
      final currentPositionMs = position?.inMilliseconds ?? 0;

      if (!_positionController!.isClosed) {
        _positionController!.add(currentPositionMs);
      }

      // Sincronización continua del estado del reproductor nativo
      await _syncNativePlayerStateIfNeeded();

      // Actualizar Control Center para archivos locales menos frecuentemente (cada 2 segundos)
      _controlCenterUpdateCounter++;
      if (_controlCenterUpdateCounter >= 4 && state.isPlaying && state.currentSong != null) {
        _controlCenterUpdateCounter = 0;
        final currentSong = state.currentSong!;
        final duration = Duration(milliseconds: currentSong.duration ?? 0);
        
        await (_playerRepository as PlayerRepositoryImpl).updateNowPlayingMetadata(
          currentSong.title,
          currentSong.artist ?? currentSong.composer ?? 'Unknown Artist',
          duration,
          position,
        );
      }

      if (state.isPlaying) {
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
            await _playerRepository.pauseTrack();
            emit(state.copyWith(isPlaying: false));
            stopSleepTimer();
            return;
          }

          if (isNearEnd && state.hasSelectedSong) {
            if (state.repeatMode == RepeatMode.one) {
              await _playerRepository.seekToPosition(Duration.zero);
            } else if (state.repeatMode == RepeatMode.all) {
              await nextSong();
            } else if (state.repeatMode == RepeatMode.none) {
              // Solo avanzar si NO es la última canción
              if (state.currentIndex < state.activePlaylist.length - 1) {
                await nextSong();
              } else {
                // Es la última canción: volver al inicio pero sin reproducir
                await nextSong();
                final bool isPlaying = await _playerRepository.pauseTrack();
                emit(state.copyWith(isPlaying: isPlaying));
              }
            }
          }
        }
      }
    });
  }

  Stream<int> getCurrentSongPosition() {
    return _positionController?.stream ?? const Stream.empty();
  }

  Future<void> seekTo(Duration position) async {
    final bool isPlaying = await _playerRepository.seekToPosition(position);
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
    await _playerRepository.pauseTrack();
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

  /// Activa el modo de avance rápido (doble velocidad)
  Future<void> startSeekForward() async {
    if (!state.hasSelectedSong) return;

    await _playerRepository.setPlaybackSpeed(2.0);
    emit(state.copyWith(playbackSpeed: 2.0));
  }

  /// Desactiva el modo de avance rápido (vuelve a velocidad normal)
  Future<void> stopSeekForward() async {
    if (!state.hasSelectedSong) return;

    // Volver a la velocidad normal (1.0)
    await _playerRepository.setPlaybackSpeed(1.0);
    emit(state.copyWith(playbackSpeed: 1.0));
  }

  /// Establece el volumen del sistema
  Future<bool> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    final success = await _playerRepository.setVolume(clampedVolume);
    if (success) {
      emit(state.copyWith(volume: clampedVolume));
    }
    return success;
  }

  /// Obtiene el volumen actual del sistema
  Future<double> getVolume() async {
    return _playerRepository.getVolume();
  }

  /// Incrementa el volumen en la cantidad especificada
  Future<void> increaseVolume(double increment) async {
    final newVolume = (state.volume + increment).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  /// Decrementa el volumen en la cantidad especificada
  Future<void> decreaseVolume(double decrement) async {
    final newVolume = (state.volume - decrement).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  /// Incrementa la velocidad de reproducción según niveles predefinidos
  Future<void> increaseSpeed() async {
    const speedLevels = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIndex = speedLevels.indexOf(state.playbackSpeed);
    if (currentIndex == -1) {
      // Si no está en los niveles predefinidos, encontrar el más cercano
      currentIndex = speedLevels.indexWhere(
        (speed) => speed >= state.playbackSpeed,
      );
      if (currentIndex == -1) currentIndex = speedLevels.length - 1;
    }

    if (currentIndex < speedLevels.length - 1) {
      await setPlaybackSpeed(speedLevels[currentIndex + 1]);
    }
  }

  /// Decrementa la velocidad de reproducción según niveles predefinidos
  Future<void> decreaseSpeed() async {
    const speedLevels = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIndex = speedLevels.indexOf(state.playbackSpeed);
    if (currentIndex == -1) {
      // Si no está en los niveles predefinidos, encontrar el más cercano
      currentIndex = speedLevels.lastIndexWhere(
        (speed) => speed <= state.playbackSpeed,
      );
      if (currentIndex == -1) currentIndex = 0;
    }

    if (currentIndex > 0) {
      await setPlaybackSpeed(speedLevels[currentIndex - 1]);
    }
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
      _playerRepository.pauseTrack();
      if (newPlaylist.isNotEmpty) {
        // Play next song or adjust index
        if (newCurrentIndex >= newPlaylist.length) {
          newCurrentIndex = 0;
        }
        final nextSong = newPlaylist[newCurrentIndex];
        _playerRepository.playTrack(nextSong.data);
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

  void _updateAudioServiceMediaItem(SongModel song) {
    // Cast del PlayerRepository a PlayerRepositoryImpl para acceder a updateCurrentMediaItem
    final playerImpl = _playerRepository as PlayerRepositoryImpl;
    playerImpl.updateCurrentMediaItem(
      song.title,
      song.artist ?? song.composer ?? 'Unknown Artist',
      null, // TODO(dev): Agregar artwork URI si está disponible
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _positionController?.close();
    _positionTimer?.cancel();
    _sleepTimer?.cancel();
    _playerEventsSubscription?.cancel();
    return super.close();
  }
}
