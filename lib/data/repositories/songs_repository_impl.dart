import 'dart:io';
import 'package:flutter/foundation.dart';
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
    // Solo iOS soporta selección manual de carpetas
    if (!kIsWeb && Platform.isIOS) {
      try {
        final String? selectedDirectory = await FilePicker.platform
            .getDirectoryPath();
        return selectedDirectory;
      } catch (e) {
        return null;
      }
    }
    // Android no soporta selección manual, retorna null
    return null;
  }

  @override
  Future<List<File>> getSongsFromFolder(String folderPath) async {
    // Solo iOS soporta escaneo de carpetas específicas
    if (!kIsWeb && Platform.isIOS) {
      try {
        final directory = Directory(folderPath);
        if (!directory.existsSync()) {
          return [];
        }

        final List<File> audioFiles = [];
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File && _isAudioFile(entity.path)) {
            audioFiles.add(entity);
          }
        }

        return audioFiles;
      } catch (e) {
        return [];
      }
    }
    // Android no soporta escaneo de carpetas específicas, retorna lista vacía
    return [];
  }

  bool _isAudioFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a'].contains(extension);
  }
}
