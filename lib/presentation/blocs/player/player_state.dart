import 'package:on_audio_query_pluse/on_audio_query.dart';

class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isPlaying;

  PlayerState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
  });

  PlayerState.initial() : playlist = [], currentIndex = -1, isPlaying = false;

  PlayerState copyWith({
    List<SongModel>? playlist,
    int? currentIndex,
    bool? isPlaying,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  bool get hasSelectedSong =>
      playlist.isNotEmpty &&
      currentIndex < playlist.length &&
      currentIndex >= 0;

  SongModel? get currentSong => hasSelectedSong ? playlist[currentIndex] : null;
}
