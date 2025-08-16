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
      
      // Convertir archivos a SongModel
      return _convertFilesToSongModel(files);
    } catch (e) {
      return [];
    }
  }

  List<SongModel> _convertFilesToSongModel(List<File> files) {
    return files.map((file) {
      final fileName = file.path.split('/').last;
      final title = fileName.replaceAll('.mp3', '');
      
      return SongModel({
        '_id': file.hashCode,
        '_data': file.path,
        '_display_name': fileName,
        'title': title,
        'artist': 'Unknown Artist',
        'album': 'Local Files',
        '_size': file.lengthSync(),
        'duration': null,
        'album_id': null,
        'artist_id': null,
        'date_added': DateTime.now().millisecondsSinceEpoch,
        'date_modified': file.lastModifiedSync().millisecondsSinceEpoch,
      });
    }).toList();
  }
}