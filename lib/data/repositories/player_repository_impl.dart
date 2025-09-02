import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl extends BaseAudioHandler
    implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;
  bool _isPaused = false;

  // Simulación de estado del ecualizador (AudioPlayers no tiene soporte nativo)
  final List<double> _equalizerBands = [0.0, 0.0, 0.0]; // Bass, Mid, Treble
  bool _equalizerEnabled = false;

  // Estado actual para AudioService
  String? _currentUrl;
  Duration _currentPosition = Duration.zero;

  // Stream para comunicar eventos al PlayerCubit
  final StreamController<PlayerEvent> _eventsController =
      StreamController<PlayerEvent>.broadcast();

  // Constructor para inicializar listeners
  PlayerRepositoryImpl() {
    _setupAudioPlayersListeners();
    _setupIosCallbacks();
  }

  @override
  Stream<PlayerEvent> get playerEvents => _eventsController.stream;

  void _setupAudioPlayersListeners() {
    // Listener para cambios de estado del reproductor
    player.onPlayerStateChanged.listen((PlayerState state) {
      if (!_usingNativePlayer) {
        final playing = state == PlayerState.playing;
        _isPaused = !playing;
        _updatePlaybackStateWithCurrentPosition(playing);
      }
    });

    // Listener para cambios de posición
    player.onPositionChanged.listen((Duration position) {
      if (!_usingNativePlayer) {
        _currentPosition = position;
        _updatePlaybackStateWithCurrentPosition(isPlaying());
      }
    });

    // Listener para cuando termina una canción
    player.onPlayerComplete.listen((_) {
      if (!_usingNativePlayer && !_eventsController.isClosed) {
        _eventsController.add(NextEvent());
      }
    });
  }

  void _setupIosCallbacks() {
    // Configurar callbacks para eventos de iOS
    IpodLibraryConverter.setPlaybackStateChangedCallback(() {
      if (_usingNativePlayer && !_eventsController.isClosed) {
        // Actualizar estado cuando iOS notifique cambios
        _updatePlaybackStateWithCurrentPosition(isPlaying());
      }
    });

    IpodLibraryConverter.setNowPlayingItemChangedCallback(() {
      if (_usingNativePlayer && !_eventsController.isClosed) {
        // Notificar cambio de canción
        _eventsController.add(NowPlayingItemChangedEvent());
      }
    });
  }

  @override
  bool isPlaying() {
    if (_usingNativePlayer && Platform.isIOS) {
      // For native player, we need to check async, but this is sync
      // Return true when using native player - UI should call status check
      return true;
    }
    return player.state == PlayerState.playing;
  }

  @override
  Future<bool> playTrack(String url) async {
    _currentUrl = url;
    await player.stop();
    await IpodLibraryConverter.stopNativeMusicPlayer();
    _usingNativePlayer = false;
    _isPaused = false;

    if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
      // Check if DRM protected
      final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
      if (isDrmProtected) {
        return false;
      }

      // Use native iOS music player for iPod library URLs
      final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
      if (success) {
        _usingNativePlayer = true;
        // Set a default MediaItem for iPod library tracks
        // The actual metadata will be updated by PlayerCubit when available
        await _setDefaultMediaItem();
      }
      await _updatePlaybackStateWithCurrentPosition(success);
      return success;
    } else {
      // Use audioplayers for regular files (and iPod URLs on Android)
      await player.play(DeviceFileSource(url));
      final playing = isPlaying();
      // Set a default MediaItem for regular files
      // The actual metadata will be updated by PlayerCubit when available
      await _setDefaultMediaItem();
      await _updatePlaybackStateWithCurrentPosition(playing);
      return playing;
    }
  }

  @override
  Future<bool> resumeTrack() async {
    if (_currentUrl == null) return false;

    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.resumeNativeMusicPlayer();
      final playing = isPlaying();
      _isPaused = !playing;
      await _updatePlaybackStateWithCurrentPosition(playing);
      return playing;
    } else {
      await player.resume();
      final playing = isPlaying();
      _isPaused = !playing;
      await _updatePlaybackStateWithCurrentPosition(playing);
      return playing;
    }
  }

  @override
  Future<bool> pauseTrack() async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      _isPaused = true;
      await _updatePlaybackStateWithCurrentPosition(false);
      return false;
    } else {
      await player.pause();
      _isPaused = true;
    }
    final playing = isPlaying();
    await _updatePlaybackStateWithCurrentPosition(playing);
    return playing;
  }

  @override
  Future<bool> togglePlayPause() async {
    bool finalState;

    if (_usingNativePlayer && Platform.isIOS) {
      final status = await IpodLibraryConverter.getNativeMusicPlayerStatus();
      if (status == 'playing') {
        await IpodLibraryConverter.pauseNativeMusicPlayer();
        finalState = false;
      } else if (status == 'paused') {
        await IpodLibraryConverter.resumeNativeMusicPlayer();
        finalState = true;
      } else {
        finalState = status == 'playing';
      }
    } else if (isPlaying()) {
      await player.pause();
      finalState = isPlaying();
    } else {
      await player.resume();
      finalState = isPlaying();
    }

    await _updatePlaybackStateWithCurrentPosition(finalState);
    return finalState;
  }

  @override
  Future<bool> seekToPosition(Duration position) async {
    _currentPosition = position;

    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.seekToPosition(position);
      await IpodLibraryConverter.resumeNativeMusicPlayer();
      final playing = isPlaying();
      await _updatePlaybackStateWithCurrentPosition(playing);
      return playing;
    } else {
      await player.seek(position);
      await player.resume();
    }
    final playing = isPlaying();
    await _updatePlaybackStateWithCurrentPosition(playing);
    return playing;
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    Duration? position;
    if (_usingNativePlayer && Platform.isIOS) {
      position = await IpodLibraryConverter.getCurrentPosition();
    } else {
      position = await player.getCurrentPosition();
    }

    if (position != null) {
      _currentPosition = position;
    }
    return position;
  }

  @override
  Future<Duration?> getDuration() async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.getDuration();
    } else {
      return player.getDuration();
    }
  }

  @override
  Future<bool> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;

    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.setPlaybackSpeed(speed);
    } else {
      await player.setPlaybackRate(speed);
      return true;
    }
  }

  @override
  double getPlaybackSpeed() {
    if (_usingNativePlayer && Platform.isIOS) {
      // For native player, we return the stored speed since getPlaybackSpeed is async
      // but this method needs to be sync. The actual speed should be synced when setting.
      return _playbackSpeed;
    }
    return _playbackSpeed;
  }

  @override
  Future<bool> setEqualizerBand(int bandIndex, double gain) async {
    if (bandIndex >= 0 && bandIndex < _equalizerBands.length) {
      _equalizerBands[bandIndex] = gain;

      // TODO(Armando): Aplicar filtros de audio reales cuando esté disponible
      // Por ahora solo guardamos el estado

      if (_usingNativePlayer && Platform.isIOS) {
        // Usar ecualizador nativo de iOS
        return IpodLibraryConverter.setEqualizerBand(bandIndex, gain);
      } else {
        // TODO(Armando): Aplicar filtros con AudioPlayers cuando tenga soporte
        // Por ahora retornamos true para mantener la funcionalidad de UI
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<double>> getEqualizerBands() async {
    return List<double>.from(_equalizerBands);
  }

  @override
  Future<bool> setEqualizerEnabled(bool enabled) async {
    _equalizerEnabled = enabled;

    if (_usingNativePlayer && Platform.isIOS) {
      // Usar ecualizador nativo de iOS
      return IpodLibraryConverter.setEqualizerEnabled(enabled);
    } else {
      // TODO(Armando): Activar/desactivar filtros de AudioPlayers
      return true;
    }
  }

  @override
  Future<bool> isEqualizerEnabled() async {
    return _equalizerEnabled;
  }

  @override
  Future<bool> setVolume(double volume) async {
    try {
      // Asegurar que el volumen esté en el rango correcto (0.0 - 1.0)
      final clampedVolume = volume.clamp(0.0, 1.0);
      await VolumeController.instance.setVolume(clampedVolume);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<double> getVolume() async {
    try {
      return await VolumeController.instance.getVolume();
    } catch (e) {
      return 0.5; // Valor por defecto en caso de error
    }
  }

  // AudioService BaseAudioHandler methods - estos se llaman desde las notificaciones
  @override
  Future<void> play() async {
    if (_currentUrl != null) {
      bool success;
      if (_isPaused) {
        // Si estaba pausado, reanudar sin reiniciar
        success = await resumeTrack();
      } else {
        // Si no había nada reproduciéndose, iniciar desde el principio
        success = await playTrackInternal(_currentUrl!);
      }
      await _updatePlaybackStateWithCurrentPosition(success);
      if (!_eventsController.isClosed) {
        _eventsController.add(PlayEvent());
      }
    }
  }

  @override
  Future<void> pause() async {
    await pauseTrackInternal();
    await _updatePlaybackStateWithCurrentPosition(false);
    if (!_eventsController.isClosed) {
      _eventsController.add(PauseEvent());
    }
  }

  @override
  Future<void> skipToNext() async {
    // Si está usando el reproductor nativo, ejecutar navegación nativa
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.skipToNext();
    }
    
    // Actualizar estado y notificar
    await _updatePlaybackStateWithCurrentPosition(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(NextEvent());
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Si está usando el reproductor nativo, ejecutar navegación nativa
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.skipToPrevious();
    }
    
    // Actualizar estado y notificar
    await _updatePlaybackStateWithCurrentPosition(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(PreviousEvent());
    }
  }

  @override
  Future<void> seek(Duration position) async {
    // Llama al método seek del repository (que retorna bool)
    await _seekToPosition(position);
    _currentPosition = position;
    await _updatePlaybackStateWithCurrentPosition(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(SeekEvent(position));
    }
  }

  Future<void> _seekToPosition(Duration position) async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.seekToPosition(position);
      await IpodLibraryConverter.resumeNativeMusicPlayer();
    } else {
      await player.seek(position);
      await player.resume();
    }
  }

  // Métodos auxiliares para AudioService que llamarán a los métodos del repository
  Future<bool> playTrackInternal(String url) async {
    return playTrack(url);
  }

  Future<bool> pauseTrackInternal() async {
    return pauseTrack();
  }

  Future<void> _updatePlaybackStateWithCurrentPosition(bool playing) async {
    final currentPosition = await getCurrentPosition() ?? _currentPosition;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: playing,
        updatePosition: currentPosition,
        speed: _playbackSpeed,
      ),
    );
  }

  Future<void> updateCurrentMediaItem(String title, String artist, String? artUri, {String? album}) async {
    // Get duration if available
    final duration = await getDuration();
    
    mediaItem.add(
      MediaItem(
        id: _currentUrl ?? '',
        album: album ?? '',
        title: title,
        artist: artist,
        artUri: artUri != null ? Uri.parse(artUri) : null,
        duration: duration,
      ),
    );
  }

  Future<void> _setDefaultMediaItem() async {
    if (_currentUrl != null) {
      // Get duration if available
      final duration = await getDuration();
      
      mediaItem.add(
        MediaItem(
          id: _currentUrl!,
          title: 'Unknown Track',
          artist: 'Unknown Artist',
          duration: duration,
        ),
      );
    }
  }

  // Cerrar el StreamController al destruir la instancia
  void dispose() {
    _eventsController.close();
  }
}
