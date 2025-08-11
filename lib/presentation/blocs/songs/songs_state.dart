import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongsState {
  final List<SongModel> songs;
  final bool isLoading;
  final String? error;

  SongsState({required this.songs, this.isLoading = false, this.error});

  SongsState.initial() : songs = [], isLoading = false, error = null;

  SongsState copyWith({
    List<SongModel>? songs,
    bool? isLoading,
    String? error,
  }) {
    return SongsState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
