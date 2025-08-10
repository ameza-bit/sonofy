import 'package:sonofy/data/models/song.dart';

abstract class SongsRepository {
  Future<List<Song>> getSongs();
  Future<Song> getSongById(String id);
  Future<void> addSong(Song song);
  Future<void> updateSong(Song song);
  Future<void> deleteSong(String id);
}
