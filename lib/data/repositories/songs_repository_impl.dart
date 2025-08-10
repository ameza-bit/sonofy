import 'package:sonofy/data/models/song.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';

final class SongsRepositoryImpl implements SongsRepository {
  @override
  Future<void> addSong(Song song) {
    // TODO(Armando): implement addSong
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSong(String id) {
    // TODO(Armando): implement deleteSong
    throw UnimplementedError();
  }

  @override
  Future<Song> getSongById(String id) {
    // TODO(Armando): implement getSongById
    throw UnimplementedError();
  }

  @override
  Future<List<Song>> getSongs() {
    // TODO(Armando): implement getSongs
    throw UnimplementedError();
  }

  @override
  Future<void> updateSong(Song song) {
    // TODO(Armando): implement updateSong
    throw UnimplementedError();
  }
}
