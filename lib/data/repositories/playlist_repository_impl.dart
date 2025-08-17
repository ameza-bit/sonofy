import 'dart:convert';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

final class PlaylistRepositoryImpl implements PlaylistRepository {
  static const String _playlistsKey = 'playlists';

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    try {
      final playlistsJson = Preferences.pref.getString(_playlistsKey);
      if (playlistsJson == null || playlistsJson.isEmpty) {
        return [];
      }

      final List<dynamic> playlistsList = jsonDecode(playlistsJson);
      return playlistsList
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final playlists = await getAllPlaylists();
    try {
      return playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Playlist> createPlaylist(String name) async {
    final playlists = await getAllPlaylists();
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      songIds: [],
    );

    playlists.add(newPlaylist);
    await _savePlaylists(playlists);
    return newPlaylist;
  }

  @override
  Future<Playlist> updatePlaylist(Playlist playlist) async {
    final playlists = await getAllPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    
    if (index == -1) {
      throw Exception('Playlist not found');
    }

    playlists[index] = playlist;
    await _savePlaylists(playlists);
    return playlist;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    final playlists = await getAllPlaylists();
    playlists.removeWhere((playlist) => playlist.id == id);
    await _savePlaylists(playlists);
  }

  @override
  Future<Playlist> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final updatedPlaylist = playlist.addSong(songId);
    return updatePlaylist(updatedPlaylist);
  }

  @override
  Future<Playlist> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final updatedPlaylist = playlist.removeSong(songId);
    return updatePlaylist(updatedPlaylist);
  }

  @override
  Future<Playlist> reorderSongsInPlaylist(String playlistId, List<String> newOrder) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist not found');
    }

    final updatedPlaylist = playlist.reorderSongs(newOrder);
    return updatePlaylist(updatedPlaylist);
  }

  Future<void> _savePlaylists(List<Playlist> playlists) async {
    final playlistsJson = jsonEncode(
      playlists.map((playlist) => playlist.toJson()).toList(),
    );
    await Preferences.pref.setString(_playlistsKey, playlistsJson);
  }
}