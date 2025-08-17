import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';

abstract class SongsRepository {
  Future<List<SongModel>> getSongsFromDevice();
  Future<String?> selectMusicFolder();
  Future<List<File>> getSongsFromFolder(String folderPath);

  // TODO(Armando): Add song sorting methods
  // Future<List<SongModel>> getSongsSortedBy(SortBy sortBy, SortOrder order);
  // enum SortBy { title, artist, album, dateAdded, duration }
  // enum SortOrder { ascending, descending }
}
