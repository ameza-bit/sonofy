import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/data/models/song.dart';
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
  Future<List<Song>> getSongsFromDevice() async {
    final bool canContinue = await _configureAudioQuery();

    if (!canContinue) {
      return [];
    }

    await _audioQuery.querySongs().then((value) {
      print('Canciones encontradas: ${value.length}');
    });

    return [Song.empty(), Song.empty(), Song.empty()];
  }
}
