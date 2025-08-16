import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';

class GetAllSongsUseCase {
  final SongsRepository _songsRepository;
  final SettingsRepository _settingsRepository;

  GetAllSongsUseCase(this._songsRepository, this._settingsRepository);

  Future<List<SongModel>> call() async {
    // Obtener canciones del dispositivo
    final deviceSongs = await _songsRepository.getSongsFromDevice();
    
    // Obtener canciones de la carpeta local
    final localSongs = await _getLocalSongs();
    
    // Combinar ambas listas (puedes implementar tu lógica aquí)
    final allSongs = <SongModel>[];
    allSongs.addAll(deviceSongs);
    allSongs.addAll(localSongs);
    
    return allSongs;
  }

  Future<List<SongModel>> _getLocalSongs() async {
    try {
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;
      
      if (localPath == null || localPath.isEmpty) {
        return [];
      }
      
      final files = await _songsRepository.getSongsFromFolder(localPath);
      
      // Convertir archivos a SongModel
      return _convertFilesToSongModel(files);
    } catch (e) {
      return [];
    }
  }

  List<SongModel> _convertFilesToSongModel(List<File> files) {
    return files.map((file) {
      final fileName = file.path.split('/').last;
      final title = fileName.split('.').first;
      
      // Extraer información básica del nombre del archivo
      final String artistName = _extractArtistFromFileName(fileName);
      final String albumName = 'Local Files';
      final String songTitle = title;
      
      // Calcular duración estimada basada en el tamaño del archivo
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
    }).toList();
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