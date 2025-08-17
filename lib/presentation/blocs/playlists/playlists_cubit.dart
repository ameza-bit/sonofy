import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/create_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/delete_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/get_all_playlists_usecase.dart';
import 'package:sonofy/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/update_playlist_usecase.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';

class PlaylistsCubit extends Cubit<PlaylistsState> {
  final GetAllPlaylistsUseCase _getAllPlaylistsUseCase;
  final CreatePlaylistUseCase _createPlaylistUseCase;
  final DeletePlaylistUseCase _deletePlaylistUseCase;
  final UpdatePlaylistUseCase _updatePlaylistUseCase;
  final AddSongToPlaylistUseCase _addSongToPlaylistUseCase;
  final RemoveSongFromPlaylistUseCase _removeSongFromPlaylistUseCase;

  PlaylistsCubit(
    this._getAllPlaylistsUseCase,
    this._createPlaylistUseCase,
    this._deletePlaylistUseCase,
    this._updatePlaylistUseCase,
    this._addSongToPlaylistUseCase,
    this._removeSongFromPlaylistUseCase,
  ) : super(PlaylistsState.initial()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      
      final playlists = await _getAllPlaylistsUseCase();
      
      emit(state.copyWith(
        playlists: playlists,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      emit(state.copyWith(isCreating: true, clearError: true));
      
      final newPlaylist = await _createPlaylistUseCase(name);
      final updatedPlaylists = [...state.playlists, newPlaylist];
      
      emit(state.copyWith(
        playlists: updatedPlaylists,
        isCreating: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isCreating: false,
      ));
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      emit(state.copyWith(isDeleting: true, clearError: true));
      
      await _deletePlaylistUseCase(playlistId);
      final updatedPlaylists = state.playlists
          .where((playlist) => playlist.id != playlistId)
          .toList();
      
      emit(state.copyWith(
        playlists: updatedPlaylists,
        isDeleting: false,
        clearSelectedPlaylist: state.selectedPlaylist?.id == playlistId,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isDeleting: false,
      ));
    }
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    try {
      emit(state.copyWith(clearError: true));
      
      final playlist = state.getPlaylistById(playlistId);
      if (playlist == null) {
        emit(state.copyWith(error: 'Playlist not found'));
        return;
      }
      
      final updatedPlaylist = playlist.rename(newName);
      await _updatePlaylistUseCase(updatedPlaylist);
      
      final updatedPlaylists = state.playlists
          .map((p) => p.id == playlistId ? updatedPlaylist : p)
          .toList();
      
      emit(state.copyWith(playlists: updatedPlaylists));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      emit(state.copyWith(clearError: true));
      
      final updatedPlaylist = await _addSongToPlaylistUseCase(playlistId, songId);
      final updatedPlaylists = state.playlists
          .map((p) => p.id == playlistId ? updatedPlaylist : p)
          .toList();
      
      emit(state.copyWith(playlists: updatedPlaylists));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      emit(state.copyWith(clearError: true));
      
      final updatedPlaylist = await _removeSongFromPlaylistUseCase(playlistId, songId);
      final updatedPlaylists = state.playlists
          .map((p) => p.id == playlistId ? updatedPlaylist : p)
          .toList();
      
      emit(state.copyWith(playlists: updatedPlaylists));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void selectPlaylist(String playlistId) {
    final playlist = state.getPlaylistById(playlistId);
    emit(state.copyWith(selectedPlaylist: playlist));
  }

  void clearSelectedPlaylist() {
    emit(state.copyWith(clearSelectedPlaylist: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}