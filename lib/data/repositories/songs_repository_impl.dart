import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/functions.dart' show getMusicFolderPath;
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
        // Siempre devolver la ruta de la carpeta Music de la app
        final String musicFolderPath = await getMusicFolderPath();

        if (kDebugMode) {
          print('Music folder path: $musicFolderPath');
        }

        return musicFolderPath;
      } catch (e) {
        if (kDebugMode) {
          print('Error getting Music folder: $e');
        }
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
        // Usar siempre la carpeta Music de la app
        final String musicFolderPath = await getMusicFolderPath();
        final directory = Directory(musicFolderPath);

        if (!directory.existsSync()) {
          if (kDebugMode) {
            print('Music directory does not exist: $musicFolderPath');
          }
          return [];
        }

        final List<File> audioFiles = [];
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File && _isAudioFile(entity.path)) {
            audioFiles.add(entity);
          }
        }

        if (kDebugMode) {
          print('Found ${audioFiles.length} audio files in Music folder');
        }

        return audioFiles;
      } catch (e) {
        if (kDebugMode) {
          print('Error scanning Music folder: $e');
        }
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

  /// Inicializa la carpeta Music en el directorio de la app (llamar desde main)
  Future<void> initializeMusicFolder() async {
    if (!kIsWeb && Platform.isIOS) {
      await getMusicFolderPath();
      if (kDebugMode) {
        print('Music folder initialized');
      }
    }
  }
}
