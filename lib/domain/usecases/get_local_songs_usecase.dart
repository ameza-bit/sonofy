import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';

class GetLocalSongsUseCase {
  final SongsRepository _songsRepository;
  final SettingsRepository _settingsRepository;

  GetLocalSongsUseCase(this._songsRepository, this._settingsRepository);

  Future<List<SongModel>> call() async {
    try {
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;

      if (localPath == null || localPath.isEmpty) {
        return [];
      }

      final files = await _songsRepository.getSongsFromFolder(localPath);

      // Convertir archivos a SongModel con metadatos
      return await _convertFilesToSongModel(files);
    } catch (e) {
      return [];
    }
  }

  Future<List<SongModel>> _convertFilesToSongModel(List<File> files) async {
    final List<SongModel> songs = [];

    for (final file in files) {
      try {
        final fileName = file.path.split('/').last;
        final title = fileName.split('.').first;

        // Extraer información básica del nombre del archivo
        final String artistName = _extractArtistFromFileName(fileName);
        final String albumName = 'Local Files';
        final String songTitle = title;

        // Calcular duración estimada basada en el tamaño del archivo
        final int durationMs = _estimateDurationFromFileSize(file.lengthSync());

        final song = SongModel({
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

        songs.add(song);
      } catch (e) {
        // Si falla completamente, crear una entrada básica
        final fileName = file.path.split('/').last;
        final title = fileName.split('.').first;

        final song = SongModel({
          '_id': file.hashCode,
          '_data': file.path,
          '_display_name': fileName,
          '_display_name_wo_ext': title,
          'file_extension': fileName.split('.').last,
          'is_music': true,
          'title': title,
          'artist': 'Unknown Artist',
          'album': 'Local Files',
          '_size': file.lengthSync(),
          'duration': _estimateDurationFromFileSize(file.lengthSync()),
          'album_id': null,
          'artist_id': null,
          'date_added': DateTime.now().millisecondsSinceEpoch,
          'date_modified': file.lastModifiedSync().millisecondsSinceEpoch,
        });

        songs.add(song);
      }
    }

    return songs;
  }

  String _extractArtistFromFileName(String fileName) {
    // Intentar extraer artista del nombre del archivo
    // Formatos comunes: "Artista - Canción.mp3", "Artista_Canción.mp3"
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

  int _estimateDurationFromFileSize(int fileSizeBytes) {
    // Estimación aproximada: MP3 a 128kbps ≈ 16KB/s
    // Esta es una estimación muy aproximada
    const int averageBytesPerSecond = 16000; // 128kbps / 8 = 16KB/s
    final int estimatedSeconds = fileSizeBytes ~/ averageBytesPerSecond;
    return estimatedSeconds * 1000; // Convertir a milisegundos
  }
}
