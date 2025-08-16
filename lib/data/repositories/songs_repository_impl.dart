import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';

final class SongsRepositoryImpl implements SongsRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> _configureAudioQuery() async {
    await _audioQuery.setLogConfig(
      LogConfig(logType: LogType.DEBUG, showDetailedLog: true),
    );

    return _checkAndRequestPermissions();
  }

  Future<bool> _checkAndRequestPermissions({bool retry = false}) async {
    return _audioQuery.checkAndRequest(retryRequest: retry);
  }

  @override
  Future<List<SongModel>> getSongsFromDevice() async {
    final bool canContinue = await _configureAudioQuery();
    return !canContinue ? [] : _audioQuery.querySongs();
  }

  @override
  Future<String?> selectMusicFolder() async {
    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<File>> getSongsFromFolder(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      if (!directory.existsSync()) {
        return [];
      }

      final List<File> mp3Files = [];
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && _isMp3File(entity.path)) {
          mp3Files.add(entity);
        }
      }

      return mp3Files;
    } catch (e) {
      return [];
    }
  }

  bool _isMp3File(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'mp3';
  }
}
