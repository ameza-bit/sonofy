import 'package:on_audio_query_pluse/on_audio_query.dart';

class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;

  PlayerState({required this.playlist, required this.currentIndex});

  PlayerState.initial() : playlist = [], currentIndex = -1;

  PlayerState copyWith({List<SongModel>? playlist, int? currentIndex}) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  bool get hasSelectedSong =>
      playlist.isNotEmpty &&
      currentIndex < playlist.length &&
      currentIndex >= 0;

  SongModel? get currentSong => hasSelectedSong ? playlist[currentIndex] : null;
}
