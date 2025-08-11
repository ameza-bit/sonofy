import 'package:on_audio_query_pluse/on_audio_query.dart';

abstract class SongsRepository {
  Future<List<SongModel>> getSongsFromDevice();
}
