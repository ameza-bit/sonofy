import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl extends BaseAudioHandler
    implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;

  // Simulación de estado del ecualizador (AudioPlayers no tiene soporte nativo)
  final List<double> _equalizerBands = [0.0, 0.0, 0.0]; // Bass, Mid, Treble
  bool _equalizerEnabled = false;

  // Estado actual para AudioService
  String? _currentUrl;
  Duration _currentPosition = Duration.zero;

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
      }
      _updatePlaybackState(success);
      return success;
    } else {
      // Use audioplayers for regular files (and iPod URLs on Android)
      await player.play(DeviceFileSource(url));
      final playing = isPlaying();
      _updatePlaybackState(playing);
      return playing;
    }
  }

  @override
  Future<bool> pauseTrack() async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      _updatePlaybackState(false);
      return false;
    } else {
      await player.pause();
    }
    final playing = isPlaying();
    _updatePlaybackState(playing);
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

    _updatePlaybackState(finalState);
    return finalState;
  }

  @override
  Future<bool> seekToPosition(Duration position) async {
    _currentPosition = position;

    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.seekToPosition(position);
      await IpodLibraryConverter.resumeNativeMusicPlayer();
      final playing = isPlaying();
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

  // AudioService BaseAudioHandler methods - estos se llaman desde las notificaciones
  @override
  Future<void> play() async {
    if (_currentUrl != null) {
      final success = await playTrackInternal(_currentUrl!);
      _updatePlaybackState(success);
    }
  }

  @override
  Future<void> pause() async {
    await pauseTrackInternal();
    _updatePlaybackState(false);
  }

  @override
  Future<void> skipToNext() async {
    // Este método será llamado desde la notificación
    // El PlayerCubit manejará la lógica de navegación
    _updatePlaybackState(isPlaying());
  }

  @override
  Future<void> skipToPrevious() async {
    // Este método será llamado desde la notificación
    // El PlayerCubit manejará la lógica de navegación
    _updatePlaybackState(isPlaying());
  }

  @override
  Future<void> seek(Duration position) async {
    // Llama al método seek del repository (que retorna bool)
    await _seekToPosition(position);
    _currentPosition = position;
    _updatePlaybackState(isPlaying());
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
}
