import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/audio_player_converter.dart';
import 'package:sonofy/core/utils/native_audio_player.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;

  // Estado específico para reproducción nativa
  bool _nativePlayerIsPlaying = false;
  bool _usingNativeAndroidPlayer = false;

  // Simulación de estado del ecualizador (AudioPlayers no tiene soporte nativo)
  final List<double> _equalizerBands = [0.0, 0.0, 0.0]; // Bass, Mid, Treble
  bool _equalizerEnabled = false;

  // Estado actual
  String? _currentUrl;

  // Stream para comunicar eventos al PlayerCubit
  final StreamController<PlayerEvent> _eventsController =
      StreamController<PlayerEvent>.broadcast();

  @override
  Stream<PlayerEvent> get playerEvents => _eventsController.stream;

  @override
  bool isPlaying() {
    if (_usingNativePlayer && Platform.isIOS) {
      return _nativePlayerIsPlaying;
    }
    if (_usingNativeAndroidPlayer && Platform.isAndroid) {
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
    await NativeAudioPlayer.stopTrack();
    _usingNativePlayer = false;
    _usingNativeAndroidPlayer = false;

    if (Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(url)) {
        // iPod Library URLs - usar MPMusicPlayerController
        final isDrmProtected = await AudioPlayerConverter.isDrmProtected(url);
        if (isDrmProtected) {
          return false;
        }

        final success = await AudioPlayerConverter.playWithNativeMusicPlayer(
          url,
        );
        if (success) {
          _usingNativePlayer = true;
          _nativePlayerIsPlaying = true;
        }
        return success;
      } else if (AudioPlayerConverter.isLocalAudioFile(url)) {
        final success = await AudioPlayerConverter.playMP3WithNativePlayer(url);
        if (success) {
          _usingNativePlayer = true;
          _nativePlayerIsPlaying = true;
        }
        return success;
      }
    } else if (Platform.isAndroid) {
      if (NativeAudioPlayer.isLocalAudioFile(url)) {
        final success = await NativeAudioPlayer.playTrack(url);
        if (success) {
          _usingNativeAndroidPlayer = true;
          _nativePlayerIsPlaying = true;
        }
        return success;
      }
    }

    _usingNativePlayer = false;
    _usingNativeAndroidPlayer = false;
    _nativePlayerIsPlaying = false;
    await player.play(DeviceFileSource(url));
    final playing = isPlaying();
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
      return success;
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      final success = await NativeAudioPlayer.resumeTrack();
      _nativePlayerIsPlaying = success;
      return success;
    } else {
      await player.resume();
      final playing = isPlaying();
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
      return false;
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      await NativeAudioPlayer.pauseTrack();
      _nativePlayerIsPlaying = false;
      return false;
    } else {
      await player.pause();
    }
    final playing = isPlaying();
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
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      if (_nativePlayerIsPlaying) {
        await NativeAudioPlayer.pauseTrack();
        finalState = false;
      } else {
        await NativeAudioPlayer.resumeTrack();
        finalState = true;
      }
      _nativePlayerIsPlaying = finalState;
    } else if (isPlaying()) {
      await player.pause();
      finalState = isPlaying();
    } else {
      await player.resume();
      finalState = isPlaying();
    }

    return finalState;
  }

  @override
  Future<bool> seekToPosition(Duration position) async {

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
      return playing;
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      await NativeAudioPlayer.seekToPosition(position);
      final playing = isPlaying();
      return playing;
    } else {
      await player.seek(position);
      await player.resume();
    }
    final playing = isPlaying();
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
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      position = await NativeAudioPlayer.getCurrentPosition();
    } else {
      position = await player.getCurrentPosition();
    }

    return position;
  }

  @override
  Future<Duration?> getDuration() async {
    if (_usingNativePlayer && Platform.isIOS) {
      if (AudioPlayerConverter.isIpodLibraryUrl(_currentUrl!)) {
        return AudioPlayerConverter.getDuration();
      } else if (_currentUrl != null) {
        final durationSeconds = await AudioPlayerConverter.getMP3Duration(
          _currentUrl!,
        );
        return Duration(milliseconds: (durationSeconds * 1000).round());
      }
      return null;
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      return NativeAudioPlayer.getDuration();
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
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      return NativeAudioPlayer.setPlaybackSpeed(speed);
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


  /// Actualiza el Control Center con metadatos de la canción actual
  Future<void> updateNowPlayingMetadata(
    String title,
    String artist,
    Duration? duration,
    Duration? currentPosition,
    Uint8List? artwork,
  ) async {
    if (_usingNativePlayer &&
        Platform.isIOS &&
        AudioPlayerConverter.isLocalAudioFile(_currentUrl ?? '')) {
      // Para archivos locales en iOS, usar el método nativo
      await AudioPlayerConverter.updateNowPlayingInfo(
        title: title,
        artist: artist,
        duration: (duration?.inMilliseconds ?? 0) / 1000.0,
        currentTime: (currentPosition?.inMilliseconds ?? 0) / 1000.0,
        isPlaying: isPlaying(),
        artwork: artwork,
      );
    }
  }

  /// Resincroniza el estado del reproductor nativo
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
    } else if (_usingNativeAndroidPlayer && Platform.isAndroid) {
      final isCurrentlyPlaying = await NativeAudioPlayer.isPlaying();
      _nativePlayerIsPlaying = isCurrentlyPlaying;
    }
  }

  void dispose() {
    _eventsController.close();
  }
}
