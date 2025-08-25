import 'dart:io';
import 'package:flutter/services.dart';

class IpodLibraryConverter {
  static const MethodChannel _channel = MethodChannel('ipod_library_converter');

  static bool get _isIOS => Platform.isIOS;

  static void _setupLogReceiver() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'logFromIOS') {
        call.arguments as String? ?? 'Unknown iOS log';
      }
    });
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

  static Future<double> getPlaybackSpeed() async {
    if (!_isIOS) return 1.0;

    try {
      final result = await _channel.invokeMethod('getPlaybackSpeed');
      return result as double? ?? 1.0;
    } catch (e) {
      return 1.0;
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
}
