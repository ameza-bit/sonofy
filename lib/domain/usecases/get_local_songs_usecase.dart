import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/mp3_file_converter.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';

class GetLocalSongsUseCase {
  final SongsRepository _songsRepository;
  final SettingsRepository _settingsRepository;

  GetLocalSongsUseCase(this._songsRepository, this._settingsRepository);

  Future<List<SongModel>> call() async {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (Platform.isAndroid) {
      return []; // Android no tiene canciones "locales" separadas
    }

    try {
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;

      if (localPath == null || localPath.isEmpty) {
        return [];
      }

      final files = await _songsRepository.getSongsFromFolder(localPath);

      // Convert files to SongModel using utility
      return Mp3FileConverter.convertFilesToSongModels(files);
    } catch (e) {
      return [];
    }
  }
}
