import 'dart:io' show Platform;

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

    if (!canContinue || Platform.isIOS) {
      final dummySong = SongModel({
        'title': 'Permission Denied',
        'artist': 'Unknown',
        'album': 'Unknown',
        'duration': 0,
        'file_extension': 'unknown',
        'is_alarm': false,
        'is_audiobook': false,
        'is_music': false,
        'is_notification': false,
        'is_podcast': false,
        'is_ringtone': false,
      });
      return [
        dummySong,
        dummySong,
        dummySong,
        dummySong,
        dummySong,
        dummySong,
        dummySong,
      ];
    }

    return _audioQuery.querySongs();
  }
}
