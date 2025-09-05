import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/audio_player_converter.dart';

final class PlayerRepositoryImpl extends BaseAudioHandler implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;
  bool _isPaused = false;
  
  // Estado específico para reproducción nativa
  bool _nativePlayerIsPlaying = false;

  // Simulación de estado del ecualizador (AudioPlayers no tiene soporte nativo)
  final List<double> _equalizerBands = [0.0, 0.0, 0.0]; // Bass, Mid, Treble
  bool _equalizerEnabled = false;

  // Estado actual para AudioService
  String? _currentUrl;
  Duration _currentPosition = Duration.zero;

  // Stream para comunicar eventos al PlayerCubit
  final StreamController<PlayerEvent> _eventsController = StreamController<PlayerEvent>.broadcast();

  @override
  Stream<PlayerEvent> get playerEvents => _eventsController.stream;

  @override
  bool isPlaying() {
    if (_usingNativePlayer && Platform.isIOS) {
      return _nativePlayerIsPlaying;
    }
    return player.state == PlayerState.playing;
  }

  /// Getter para verificar si se está usando el reproductor nativo
  bool get isUsingNativePlayer => _usingNativePlayer;

  @override
  Future<bool> playTrack(String url) async {
    _currentUrl = url;
    await player.stop();
    await AudioPlayerConverter.stopNativeMusicPlayer();
    await AudioPlayerConverter.stopNativeMP3Player();
    _usingNativePlayer = false;
    _isPaused = false;

    if (Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(url)) {
        // iPod Library URLs - usar MPMusicPlayerController
        final isDrmProtected = await AudioPlayerConverter.isDrmProtected(url);
        if (isDrmProtected) {
          return false;
        }

        final success = await AudioPlayerConverter.playWithNativeMusicPlayer(url);
        if (success) {
          _usingNativePlayer = true;
          _nativePlayerIsPlaying = true;
        }
        _updatePlaybackState(success);
        return success;
      } else if (AudioPlayerConverter.isLocalAudioFile(url)) {
        final success = await AudioPlayerConverter.playMP3WithNativePlayer(url);
        if (success) {
          _usingNativePlayer = true;
          _nativePlayerIsPlaying = true;
        }
        _updatePlaybackState(success);
        return success;
      }
    }
    
    _usingNativePlayer = false;
    _nativePlayerIsPlaying = false;
    await player.play(DeviceFileSource(url));
    final playing = isPlaying();
    _updatePlaybackState(playing);
    return playing;
  }

  @override
  Future<bool> resumeTrack() async {
    if (_currentUrl == null) return false;

    if (_usingNativePlayer && Platform.isIOS) {
      bool success;
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        success = await AudioPlayerConverter.resumeNativeMusicPlayer();
      } else {
        success = await AudioPlayerConverter.resumeNativeMP3Player();
      }
      _nativePlayerIsPlaying = success;
      _isPaused = !success;
      _updatePlaybackState(success);
      return success;
    } else {
      await player.resume();
      final playing = isPlaying();
      _isPaused = !playing;
      _updatePlaybackState(playing);
      return playing;
    }
  }

  @override
  Future<bool> pauseTrack() async {
    if (_usingNativePlayer && Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        await AudioPlayerConverter.pauseNativeMusicPlayer();
      } else {
        await AudioPlayerConverter.pauseNativeMP3Player();
      }
      _nativePlayerIsPlaying = false;
      _isPaused = true;
      _updatePlaybackState(false);
      return false;
    } else {
      await player.pause();
      _isPaused = true;
    }
    final playing = isPlaying();
    _updatePlaybackState(playing);
    return playing;
  }

  @override
  Future<bool> togglePlayPause() async {
    bool finalState;

    if (_usingNativePlayer && Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        if (_nativePlayerIsPlaying) {
          await AudioPlayerConverter.pauseNativeMusicPlayer();
          finalState = false;
        } else {
          await AudioPlayerConverter.resumeNativeMusicPlayer();
          finalState = true;
        }
      } else {
        if (_nativePlayerIsPlaying) {
          await AudioPlayerConverter.pauseNativeMP3Player();
          finalState = false;
        } else {
          await AudioPlayerConverter.resumeNativeMP3Player();
          finalState = true;
        }
      }
      _nativePlayerIsPlaying = finalState;
    } else if (isPlaying()) {
      await player.pause();
      finalState = isPlaying();
    } else {
      await player.resume();
      finalState = isPlaying();
    }

    _updatePlaybackState(finalState);
    return finalState;
  }

  @override
  Future<bool> seekToPosition(Duration position) async {
    _currentPosition = position;

    if (_usingNativePlayer && Platform.isIOS) {
      bool playing;
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        await AudioPlayerConverter.seekToPosition(position);
        await AudioPlayerConverter.resumeNativeMusicPlayer();
        playing = isPlaying();
      } else {
        await AudioPlayerConverter.seekToMP3Position(position);
        playing = isPlaying();
      }
      _updatePlaybackState(playing);
      return playing;
    } else {
      await player.seek(position);
      await player.resume();
    }
    final playing = isPlaying();
    _updatePlaybackState(playing);
    return playing;
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    Duration? position;
    if (_usingNativePlayer && Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        position = await AudioPlayerConverter.getCurrentPosition();
      } else {
        position = await AudioPlayerConverter.getCurrentMP3Position();
      }
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
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        return AudioPlayerConverter.getDuration();
      } else if (_currentUrl != null) {
        final durationSeconds = await AudioPlayerConverter.getMP3Duration(_currentUrl!);
        return Duration(milliseconds: (durationSeconds * 1000).round());
      }
      return null;
    } else {
      return player.getDuration();
    }
  }

  @override
  Future<bool> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;

    if (_usingNativePlayer && Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        return AudioPlayerConverter.setPlaybackSpeed(speed);
      } else {
        return AudioPlayerConverter.setMP3PlaybackSpeed(speed);
      }
    } else {
      await player.setPlaybackRate(speed);
      return true;
    }
  }

  @override
  double getPlaybackSpeed() {
    // Para ambos reproductores nativos, retornamos la velocidad almacenada
    // ya que este método necesita ser sincrónico pero los métodos nativos son async
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
        return AudioPlayerConverter.setEqualizerBand(bandIndex, gain);
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
      return AudioPlayerConverter.setEqualizerEnabled(enabled);
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
        success = await resumeTrack();
      } else {
        success = await playTrack(_currentUrl!);
      }
      _updatePlaybackState(success);
      if (!_eventsController.isClosed) {
        _eventsController.add(PlayEvent());
      }
    }
  }

  @override
  Future<void> pause() async {
    await pauseTrack();
    _updatePlaybackState(false);
    if (!_eventsController.isClosed) {
      _eventsController.add(PauseEvent());
    }
  }

  @override
  Future<void> skipToNext() async {
    // Este método será llamado desde la notificación
    // El PlayerCubit manejará la lógica de navegación
    _updatePlaybackState(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(NextEvent());
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Este método será llamado desde la notificación
    // El PlayerCubit manejará la lógica de navegación
    _updatePlaybackState(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(PreviousEvent());
    }
  }

  @override
  Future<void> seek(Duration position) async {
    // Llama al método seek del repository (que retorna bool)
    await _seekToPosition(position);
    _currentPosition = position;
    _updatePlaybackState(isPlaying());
    if (!_eventsController.isClosed) {
      _eventsController.add(SeekEvent(position));
    }
  }

  Future<void> _seekToPosition(Duration position) async {
    await seekToPosition(position);
  }


  void _updatePlaybackState(bool playing) {
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
        updatePosition: _currentPosition,
        speed: _playbackSpeed,
      ),
    );
  }

  void updateCurrentMediaItem(String title, String artist, String? artUri) {
    mediaItem.add(
      MediaItem(
        id: _currentUrl ?? '',
        album: '',
        title: title,
        artist: artist,
        artUri: artUri != null ? Uri.parse(artUri) : null,
      ),
    );
  }

  /// Actualiza el Control Center con metadatos de la canción actual
  Future<void> updateNowPlayingMetadata(String title, String artist, Duration? duration, Duration? currentPosition) async {
    if (_usingNativePlayer && Platform.isIOS && AudioPlayerConverter.isLocalAudioFile(_currentUrl ?? '')) {
      // Para archivos locales en iOS, usar el método nativo
      await AudioPlayerConverter.updateNowPlayingInfo(
        title: title,
        artist: artist,
        duration: (duration?.inMilliseconds ?? 0) / 1000.0,
        currentTime: (currentPosition?.inMilliseconds ?? 0) / 1000.0,
        isPlaying: isPlaying(),
      );
    }
  }

  /// Resincroniza el estado del reproductor nativo con AudioService
  /// Debe llamarse cuando la app vuelve del background
  @override
  Future<void> syncNativePlayerState() async {
    if (_usingNativePlayer && Platform.isIOS && _currentUrl != null) {
      String status;
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        status = await AudioPlayerConverter.getNativeMusicPlayerStatus();
      } else {
        status = await AudioPlayerConverter.getNativeMP3PlayerStatus();
      }
      
      final isCurrentlyPlaying = status == 'playing';
      _nativePlayerIsPlaying = isCurrentlyPlaying;
      _updatePlaybackState(isCurrentlyPlaying);
    }
  }


  void dispose() {
    _eventsController.close();
  }
}
