import 'dart:io';
import 'package:flutter/services.dart';

class AudioPlayerConverter {
  static const MethodChannel _channel = MethodChannel('ipod_library_converter');
  
  // Callbacks para eventos del Control Center
  static Function()? _onControlCenterNext;
  static Function()? _onControlCenterPrevious;

  static bool get _isIOS => Platform.isIOS;

  static void _setupLogReceiver() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'logFromIOS') {
        call.arguments as String? ?? 'Unknown iOS log';
      } else if (call.method == 'onControlCenterNext') {
        _onControlCenterNext?.call();
      } else if (call.method == 'onControlCenterPrevious') {
        _onControlCenterPrevious?.call();
      }
    });
  }
  
  /// Configura los callbacks para los eventos del Control Center de iOS
  static void setupControlCenterCallbacks({
    Function()? onNext,
    Function()? onPrevious,
  }) {
    if (!_isIOS) return;
    
    _onControlCenterNext = onNext;
    _onControlCenterPrevious = onPrevious;
    _setupLogReceiver();
  }

  static Future<bool> isDrmProtected(String ipodUrl) async {
    if (!_isIOS) {
      // Android doesn't have iPod Library, so no DRM concerns
      return false;
    }

    _setupLogReceiver();

    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      if (songId == null) return false;

      final result = await _channel.invokeMethod('checkDrmProtection', {
        'songId': songId,
      });

      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static String? _extractSongIdFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['id'];
  }

  static bool isIpodLibraryUrl(String url) {
    return url.startsWith('ipod-library://');
  }

  static Future<bool> playWithNativeMusicPlayer(String ipodUrl) async {
    if (!_isIOS) {
      // Android doesn't support MPMusicPlayerController
      return false;
    }

    _setupLogReceiver();

    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      if (songId == null) return false;

      final result = await _channel.invokeMethod('playWithMusicPlayer', {
        'songId': songId,
      });

      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> pauseNativeMusicPlayer() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('pauseMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> stopNativeMusicPlayer() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('stopMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getNativeMusicPlayerStatus() async {
    if (!_isIOS) return 'stopped';

    try {
      final result = await _channel.invokeMethod('getMusicPlayerStatus');
      return result as String? ?? 'stopped';
    } catch (e) {
      return 'error';
    }
  }

  static Future<bool> resumeNativeMusicPlayer() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('resumeMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<Duration> getCurrentPosition() async {
    if (!_isIOS) return Duration.zero;

    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      final seconds = result as double? ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (e) {
      return Duration.zero;
    }
  }

  static Future<Duration> getDuration() async {
    if (!_isIOS) return Duration.zero;

    try {
      final result = await _channel.invokeMethod('getDuration');
      final seconds = result as double? ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (e) {
      return Duration.zero;
    }
  }

  static Future<bool> seekToPosition(Duration position) async {
    if (!_isIOS) return false;

    try {
      final positionSeconds = position.inMilliseconds / 1000.0;
      final result = await _channel.invokeMethod('seekToPosition', {
        'position': positionSeconds,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setPlaybackSpeed(double speed) async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('setPlaybackSpeed', {
        'speed': speed,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> setEqualizerBand(int bandIndex, double gain) async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('setEqualizerBand', {
        'bandIndex': bandIndex,
        'gain': gain,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setEqualizerEnabled(bool enabled) async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('setEqualizerEnabled', {
        'enabled': enabled,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // MÉTODOS PARA REPRODUCCIÓN NATIVA DE MP3
  // ==========================================

  /// Reproduce un archivo MP3/audio local usando AVAudioPlayer nativo
  /// 
  /// [filePath] - Ruta completa al archivo de audio local
  /// Returns: true si la reproducción comenzó exitosamente
  static Future<bool> playMP3WithNativePlayer(String filePath) async {
    if (!_isIOS) {
      return false;
    }

    _setupLogReceiver();

    try {
      final result = await _channel.invokeMethod('playMP3WithNativePlayer', {
        'filePath': filePath,
      });

      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la duración real de un archivo MP3/audio usando metadatos nativos
  /// 
  /// [filePath] - Ruta completa al archivo de audio
  /// Returns: Duración en segundos como double
  static Future<double> getMP3Duration(String filePath) async {
    if (!_isIOS) return 0.0;

    try {
      final result = await _channel.invokeMethod('getMP3Duration', {
        'filePath': filePath,
      });
      return result as double? ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Pausa el reproductor nativo de archivos MP3
  static Future<bool> pauseNativeMP3Player() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('pauseNativeMP3Player');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Detiene el reproductor nativo de archivos MP3
  static Future<bool> stopNativeMP3Player() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('stopNativeMP3Player');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Reanuda el reproductor nativo de archivos MP3
  static Future<bool> resumeNativeMP3Player() async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('resumeNativeMP3Player');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el estado del reproductor nativo de MP3
  static Future<String> getNativeMP3PlayerStatus() async {
    if (!_isIOS) return 'stopped';

    try {
      final result = await _channel.invokeMethod('getNativeMP3PlayerStatus');
      return result as String? ?? 'stopped';
    } catch (e) {
      return 'error';
    }
  }

  /// Obtiene la posición actual de reproducción del archivo MP3
  static Future<Duration> getCurrentMP3Position() async {
    if (!_isIOS) return Duration.zero;

    try {
      final result = await _channel.invokeMethod('getCurrentMP3Position');
      final seconds = result as double? ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Busca a una posición específica en el archivo MP3
  static Future<bool> seekToMP3Position(Duration position) async {
    if (!_isIOS) return false;

    try {
      final positionSeconds = position.inMilliseconds / 1000.0;
      final result = await _channel.invokeMethod('seekToMP3Position', {
        'position': positionSeconds,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Establece la velocidad de reproducción del archivo MP3
  static Future<bool> setMP3PlaybackSpeed(double speed) async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('setMP3PlaybackSpeed', {
        'speed': speed,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si una ruta es un archivo de audio local (no iPod Library)
  static bool isLocalAudioFile(String path) {
    if (isIpodLibraryUrl(path)) return false;
    
    final extension = path.toLowerCase().split('.').last;
    const supportedExtensions = ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'];
    return supportedExtensions.contains(extension);
  }

  /// Actualiza la información del Control Center con metadatos desde Flutter
  static Future<bool> updateNowPlayingInfo({
    required String title,
    required String artist,
    required double duration,
    required double currentTime,
    required bool isPlaying,
    required Uint8List? artwork,
  }) async {
    if (!_isIOS) return false;

    try {
      final result = await _channel.invokeMethod('updateNowPlayingInfo', {
        'title': title,
        'artist': artist,
        'duration': duration,
        'currentTime': currentTime,
        'isPlaying': isPlaying,
        'artwork': artwork,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
