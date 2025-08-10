import 'package:sonofy/data/models/song.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';

final class SongsRepositoryImpl implements SongsRepository {
  @override
  Future<List<Song>> getSongsFromDevice() async {
    return [Song.empty(), Song.empty(), Song.empty()];
  }
}
