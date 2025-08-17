import 'package:sonofy/data/models/playlist.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getAllPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<Playlist> createPlaylist(String name);
  Future<Playlist> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String id);
  Future<Playlist> addSongToPlaylist(String playlistId, String songId);
  Future<Playlist> removeSongFromPlaylist(String playlistId, String songId);
  Future<Playlist> reorderSongsInPlaylist(String playlistId, List<String> newOrder);
}