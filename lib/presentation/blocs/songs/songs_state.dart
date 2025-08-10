import 'package:sonofy/data/models/song.dart';

class SongsState {
  final List<Song> songs;
  final Song? selectedSong;
  final String? error;

  SongsState({required this.songs, this.selectedSong, this.error});

  SongsState.initial() : songs = [], selectedSong = null, error = null;

  SongsState copyWith({List<Song>? songs, Song? selectedSong, String? error}) {
    return SongsState(
      songs: songs ?? this.songs,
      selectedSong: selectedSong ?? this.selectedSong,
      error: error ?? this.error,
    );
  }
}
