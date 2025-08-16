import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

class IpodLibraryConverter {
  static final Map<String, String> _cache = {};
  static const String _cachePrefix = 'ipod_audio_';

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

      final OnAudioQuery audioQuery = OnAudioQuery();

      final song = await _getSongById(audioQuery, songId);
      if (song == null) return null;

      final Uint8List? audioData = await audioQuery.queryArtwork(
        song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.PNG,
      );

      if (audioData == null) {
        return song.data;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          '$_cachePrefix${song.id}.${_getFileExtension(song.data)}';
      final tempFile = File('${tempDir.path}/$fileName');

      if (File(song.data).existsSync()) {
        await File(song.data).copy(tempFile.path);
        _cache[ipodUrl] = tempFile.path;
        return tempFile.path;
      }

      return song.data;
    } catch (e) {
      return null;
    }
  }

  static String? _extractSongIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final id = uri.queryParameters['id'];
    return id;
  }

  static Future<SongModel?> _getSongById(
    OnAudioQuery audioQuery,
    String songId,
  ) async {
    try {
      final songs = await audioQuery.querySongs();
      return songs.firstWhere(
        (song) => song.id.toString() == songId,
        orElse: () => songs.first,
      );
    } catch (e) {
      return null;
    }
  }

  static String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : 'm4a';
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
