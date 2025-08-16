import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';

/// Utility class for converting MP3 files to SongModel objects
class Mp3FileConverter {
  Mp3FileConverter._();

  /// Converts a list of MP3 files to SongModel objects with estimated duration
  static List<SongModel> convertFilesToSongModels(List<File> files) {
    return files.map(_convertFileToSongModel).toList();
  }

  /// Converts a single MP3 file to SongModel with estimated duration
  static SongModel _convertFileToSongModel(File file) {
    final fileName = file.path.split('/').last;
    final title = fileName.split('.').first;
    
    // Extract basic information from filename
    final String artistName = _extractArtistFromFileName(fileName);
    const String albumName = 'Local Files';
    final String songTitle = title;
    
    // Calculate estimated duration based on file size
    final int durationMs = _estimateDurationFromFileSize(file.lengthSync());

    return SongModel({
      '_id': file.hashCode,
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

  /// Estimates MP3 duration based on file size
  /// Uses approximate calculation: MP3 at 128kbps ≈ 16KB/s
  /// This is a rough estimation and may vary based on actual bitrate
  static int _estimateDurationFromFileSize(int fileSizeBytes) {
    const int averageBytesPerSecond = 16000; // 128kbps / 8 = 16KB/s
    final int estimatedSeconds = fileSizeBytes ~/ averageBytesPerSecond;
    return estimatedSeconds * 1000; // Convert to milliseconds
  }
}