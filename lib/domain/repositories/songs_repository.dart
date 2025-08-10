import 'package:sonofy/data/models/song.dart';

abstract class SongsRepository {
  Future<List<Song>> getSongsFromDevice();
}
