import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongsState {
  final List<SongModel> songs;
  final SongModel? selectedSong;
  final String? error;

  SongsState({required this.songs, this.selectedSong, this.error});

  SongsState.initial() : songs = [], selectedSong = null, error = null;

  SongsState copyWith({List<SongModel>? songs, SongModel? selectedSong, String? error}) {
    return SongsState(
      songs: songs ?? this.songs,
      selectedSong: selectedSong ?? this.selectedSong,
      error: error ?? this.error,
    );
  }
}
