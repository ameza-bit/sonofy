import 'package:flutter/services.dart';

class IpodLibraryConverter {
  static const MethodChannel _channel = MethodChannel('ipod_library_converter');
  
  static void _setupLogReceiver() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'logFromIOS') {
        final message = call.arguments as String? ?? 'Unknown iOS log';
        print('🍎 iOS: $message');
      }
    });
  }
  
  static Future<bool> isDrmProtected(String ipodUrl) async {
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
    try {
      final result = await _channel.invokeMethod('pauseMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> stopNativeMusicPlayer() async {
    try {
      final result = await _channel.invokeMethod('stopMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<String> getNativeMusicPlayerStatus() async {
    try {
      final result = await _channel.invokeMethod('getMusicPlayerStatus');
      return result as String? ?? 'stopped';
    } catch (e) {
      return 'error';
    }
  }
}
