import 'package:on_audio_query_pluse/on_audio_query.dart';

enum RepeatMode { none, one, all }

class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;

  PlayerState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.repeatMode,
  });

  PlayerState.initial() 
      : playlist = [], 
        currentIndex = -1, 
        isPlaying = false,
        isShuffleEnabled = false,
        repeatMode = RepeatMode.none;

  PlayerState copyWith({
    List<SongModel>? playlist,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  bool get hasSelectedSong =>
      playlist.isNotEmpty &&
      currentIndex < playlist.length &&
      currentIndex >= 0;

  SongModel? get currentSong => hasSelectedSong ? playlist[currentIndex] : null;
}
