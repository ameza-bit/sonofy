import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

/// Utility class for converting audio files to SongModel objects
class Mp3FileConverter {
  Mp3FileConverter._();

  /// Cache for storing duration calculations to avoid re-reading
  static final Map<String, int> _durationCache = {};

  /// Converts a list of audio files to SongModel objects with actual duration
  static Future<List<SongModel>> convertFilesToSongModels(
    List<File> files,
  ) async {
    final List<SongModel> songModels = [];
    for (final file in files) {
      final songModel = await _convertFileToSongModel(file);
      songModels.add(songModel);
    }
    return songModels;
  }

  /// Converts audio files to SongModel objects with Stream for progressive loading
  static Stream<SongModel> convertFilesToSongModelsStream(
    List<File> files, {
    int concurrency = 3,
  }) async* {
    // Process files in batches for better performance
    for (int i = 0; i < files.length; i += concurrency) {
      final batch = files.skip(i).take(concurrency).toList();
      
      // Process batch in parallel
      final futures = batch.map(_convertFileToSongModel);
      final results = await Future.wait(futures);
      
      // Yield each result as it becomes available
      for (final songModel in results) {
        yield songModel;
      }
    }
  }

  /// Converts a single audio file to SongModel with actual duration
  static Future<SongModel> _convertFileToSongModel(File file) async {
    final fileName = file.path.split('/').last;
    final title = fileName.split('.').first;

    // Extract basic information from filename
    final String artistName = _extractArtistFromFileName(fileName);
    const String albumName = 'Local Files';
    final String songTitle = title;

    // Get actual duration from file metadata
    final int durationMs = await _getActualDurationFromFile(file);

    return SongModel({
      '_id': _createPersistentIdFromPath(file.path),
      '_data': file.path,
      '_display_name': fileName,
      '_display_name_wo_ext': title,
      'file_extension': fileName.split('.').last,
      'is_music': true,
      'title': songTitle,
      'artist': artistName,
      'album': albumName,
      '_size': file.lengthSync(),
      'duration': durationMs,
      'album_id': albumName.hashCode,
      'artist_id': artistName.hashCode,
      'date_added': DateTime.now().millisecondsSinceEpoch,
      'date_modified': file.lastModifiedSync().millisecondsSinceEpoch,
    });
  }

  /// Extracts artist name from filename using common patterns
  /// Supports formats: "Artist - Song.mp3", "Artist_Song.mp3"
  static String _extractArtistFromFileName(String fileName) {
    final nameWithoutExt = fileName.split('.').first;

    if (nameWithoutExt.contains(' - ')) {
      return nameWithoutExt.split(' - ').first.trim();
    } else if (nameWithoutExt.contains('_')) {
      final parts = nameWithoutExt.split('_');
      if (parts.length >= 2) {
        return parts.first.trim();
      }
    }

    return 'Unknown Artist';
  }

  /// Creates a persistent ID for local files based on file path
  /// This ensures the same file always gets the same ID across app sessions
  static int _createPersistentIdFromPath(String filePath) {
    // Use a hash of the file path to create a consistent ID
    // Add a large offset to avoid conflicts with on_audio_query_pluse IDs
    const int localFileIdOffset = 1000000;
    return filePath.hashCode.abs() + localFileIdOffset;
  }

  /// Gets actual duration from audio file using AudioPlayer
  /// Falls back to estimation if unable to read metadata
  static Future<int> _getActualDurationFromFile(File file) async {
    final filePath = file.path;
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;
    final cacheKey = '$filePath:$lastModified';

    // Check cache first
    if (_durationCache.containsKey(cacheKey)) {
      return _durationCache[cacheKey]!;
    }

    try {
      final player = AudioPlayer();
      await player.setSource(DeviceFileSource(filePath));

      // Wait a moment for the audio to be loaded
      await Future.delayed(const Duration(milliseconds: 500));

      final duration = await player.getDuration();
      await player.dispose();

      final durationMs = duration?.inMilliseconds ??
          _estimateDurationFromFileSize(file.lengthSync());

      // Cache the result
      _durationCache[cacheKey] = durationMs;
      
      return durationMs;
    } catch (e) {
      // Fallback to file size estimation if unable to read metadata
      final durationMs = _estimateDurationFromFileSize(file.lengthSync());
      _durationCache[cacheKey] = durationMs;
      return durationMs;
    }
  }

  /// Estimates audio duration based on file size (fallback method)
  /// Uses approximate calculation: MP3 at 128kbps ≈ 16KB/s
  /// This is a rough estimation and may vary based on actual bitrate
  static int _estimateDurationFromFileSize(int fileSizeBytes) {
    const int averageBytesPerSecond = 16000; // 128kbps / 8 = 16KB/s
    final int estimatedSeconds = fileSizeBytes ~/ averageBytesPerSecond;
    return estimatedSeconds * 1000; // Convert to milliseconds
  }
}
