import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class IpodLibraryConverter {
  static final Map<String, String> _cache = {};
  static const String _cachePrefix = 'ipod_audio_';
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
    _setupLogReceiver(); // Setup log receiver
    
    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      if (songId == null) return false;
      
      print('🔍 Checking DRM for song ID: $songId');
      
      final result = await _channel.invokeMethod('checkDrmProtection', {
        'songId': songId,
      });
      
      print('✅ DRM check result: $result');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ DRM check error: $e');
      return false;
    }
  }

  static Future<String?> convertIpodUrlToFile(String ipodUrl) async {
    _setupLogReceiver(); // Setup log receiver
    
    if (!ipodUrl.startsWith('ipod-library://')) {
      return ipodUrl;
    }

    if (_cache.containsKey(ipodUrl)) {
      final cachedPath = _cache[ipodUrl]!;
      if (File(cachedPath).existsSync()) {
        print('📁 Using cached file: $cachedPath');
        return cachedPath;
      } else {
        _cache.remove(ipodUrl);
      }
    }

    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      print('🔍 Extracted song ID: $songId');
      if (songId == null) return null;

      final tempDir = await getTemporaryDirectory();
      final fileName = '$_cachePrefix$songId.m4a';
      final tempFilePath = '${tempDir.path}/$fileName';

      print('📱 Calling iOS exportAudio method...');
      final result = await _channel.invokeMethod('exportAudio', {
        'songId': songId,
        'outputPath': tempFilePath,
      });

      print('📱 iOS export result: $result');

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (File(tempFilePath).existsSync()) {
          _cache[ipodUrl] = tempFilePath;
          print('✅ File exported successfully: $tempFilePath');
          return tempFilePath;
        } else {
          print('❌ File not found at: $tempFilePath');
        }
      }

      print('❌ Export failed');
      return null;
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  static String? _extractSongIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final id = uri.queryParameters['id'];
    return id;
  }

  static Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains(_cachePrefix)) {
          await file.delete();
        }
      }

      _cache.clear();
    } catch (e) {
      // Ignore errors during cache cleanup
    }
  }

  static bool isIpodLibraryUrl(String url) {
    return url.startsWith('ipod-library://');
  }
  
  static Future<bool> playWithNativeMusicPlayer(String ipodUrl) async {
    _setupLogReceiver();
    
    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      if (songId == null) return false;
      
      print('🎵 Playing with native iOS music player...');
      
      final result = await _channel.invokeMethod('playWithMusicPlayer', {
        'songId': songId,
      });
      
      print('🎵 Native player result: $result');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ Native player error: $e');
      return false;
    }
  }
  
  static Future<bool> pauseNativeMusicPlayer() async {
    try {
      final result = await _channel.invokeMethod('pauseMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ Pause error: $e');
      return false;
    }
  }
  
  static Future<bool> stopNativeMusicPlayer() async {
    try {
      final result = await _channel.invokeMethod('stopMusicPlayer');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ Stop error: $e');
      return false;
    }
  }
  
  static Future<String> getNativeMusicPlayerStatus() async {
    try {
      final result = await _channel.invokeMethod('getMusicPlayerStatus');
      return result as String? ?? 'stopped';
    } catch (e) {
      print('❌ Status error: $e');
      return 'error';
    }
  }
}
