import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class IpodLibraryConverter {
  static final Map<String, String> _cache = {};
  static const String _cachePrefix = 'ipod_audio_';
  static const MethodChannel _channel = MethodChannel('ipod_library_converter');

  static Future<String?> convertIpodUrlToFile(String ipodUrl) async {
    if (!ipodUrl.startsWith('ipod-library://')) {
      return ipodUrl;
    }

    if (_cache.containsKey(ipodUrl)) {
      final cachedPath = _cache[ipodUrl]!;
      if (File(cachedPath).existsSync()) {
        return cachedPath;
      } else {
        _cache.remove(ipodUrl);
      }
    }

    try {
      final songId = _extractSongIdFromUrl(ipodUrl);
      if (songId == null) return null;

      final tempDir = await getTemporaryDirectory();
      final fileName = '$_cachePrefix$songId.m4a';
      final tempFilePath = '${tempDir.path}/$fileName';

      final result = await _channel.invokeMethod('exportAudio', {
        'songId': songId,
        'outputPath': tempFilePath,
      });

      if (result == true && File(tempFilePath).existsSync()) {
        _cache[ipodUrl] = tempFilePath;
        return tempFilePath;
      }

      return null;
    } catch (e) {
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
}
