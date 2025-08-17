import 'package:sonofy/data/models/playlist.dart';

class PlaylistsState {
  final List<Playlist> playlists;
  final Playlist? selectedPlaylist;
  final bool isLoading;
  final bool isCreating;
  final bool isDeleting;
  final String? error;

  PlaylistsState({
    required this.playlists,
    this.selectedPlaylist,
    this.isLoading = false,
    this.isCreating = false,
    this.isDeleting = false,
    this.error,
  });

  PlaylistsState.initial()
      : playlists = [],
        selectedPlaylist = null,
        isLoading = false,
        isCreating = false,
        isDeleting = false,
        error = null;

  PlaylistsState copyWith({
    List<Playlist>? playlists,
    Playlist? selectedPlaylist,
    bool? clearSelectedPlaylist,
    bool? isLoading,
    bool? isCreating,
    bool? isDeleting,
    String? error,
    bool? clearError,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      selectedPlaylist: (clearSelectedPlaylist ?? false)
          ? null 
          : selectedPlaylist ?? this.selectedPlaylist,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: (clearError ?? false) ? null : error ?? this.error,
    );
  }

  bool get hasPlaylists => playlists.isNotEmpty;
  int get playlistCount => playlists.length;
  bool get hasError => error != null;

  Playlist? getPlaylistById(String id) {
    try {
      return playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }
}