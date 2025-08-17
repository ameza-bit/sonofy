import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';

enum RepeatMode { none, one, all }

class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final bool isSleepTimerActive;
  final bool waitForSongToFinish;
  final double playbackSpeed;
  final Duration? sleepTimerDuration;
  final Duration? sleepTimerRemaining;

  PlayerState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.isSleepTimerActive,
    required this.waitForSongToFinish,
    required this.playbackSpeed,
    this.sleepTimerDuration,
    this.sleepTimerRemaining,
  });

  PlayerState.initial()
    : playlist = [],
      currentIndex = -1,
      isPlaying = false,
      isShuffleEnabled = Preferences.playerPreferences.isShuffleEnabled,
      repeatMode = Preferences.playerPreferences.repeatMode,
      sleepTimerDuration = null,
      sleepTimerRemaining = null,
      playbackSpeed = 1.0,
      isSleepTimerActive = false,
      waitForSongToFinish = false;

  PlayerState copyWith({
    List<SongModel>? playlist,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    bool? isSleepTimerActive,
    bool? waitForSongToFinish,
    double? playbackSpeed,
    Duration? sleepTimerDuration,
    Duration? sleepTimerRemaining,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
      waitForSongToFinish: waitForSongToFinish ?? this.waitForSongToFinish,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
    );
  }

  bool get hasSelectedSong =>
      playlist.isNotEmpty &&
      currentIndex < playlist.length &&
      currentIndex >= 0;

  SongModel? get currentSong => hasSelectedSong ? playlist[currentIndex] : null;
}
