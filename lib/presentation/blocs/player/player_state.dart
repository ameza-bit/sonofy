import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';

enum RepeatMode { none, one, all }

class PlayerState {
  final List<SongModel> _playlist;
  final List<SongModel> _shufflePlaylist;
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
    required List<SongModel> playlist,
    required this.currentIndex,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.isSleepTimerActive,
    required this.waitForSongToFinish,
    required this.playbackSpeed,
    List<SongModel>? shufflePlaylist,
    this.sleepTimerDuration,
    this.sleepTimerRemaining,
  }) : _playlist = playlist,
       _shufflePlaylist = shufflePlaylist ?? _generateShufflePlaylist(playlist);

  PlayerState.initial()
    : _playlist = [],
      _shufflePlaylist = [],
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
    List<SongModel>? shufflePlaylist,
    Duration? sleepTimerDuration,
    Duration? sleepTimerRemaining,
  }) {
    return PlayerState(
      playlist: playlist ?? _playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
      waitForSongToFinish: waitForSongToFinish ?? this.waitForSongToFinish,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      shufflePlaylist: shufflePlaylist ?? _shufflePlaylist,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
    );
  }

  bool get hasSelectedSong =>
      activePlaylist.isNotEmpty &&
      currentIndex < activePlaylist.length &&
      currentIndex >= 0;

  SongModel? get currentSong =>
      hasSelectedSong ? activePlaylist[currentIndex] : null;

  List<SongModel> get playlist => _playlist;

  List<SongModel> get shufflePlaylist => _shufflePlaylist;

  List<SongModel> get activePlaylist {
    return isShuffleEnabled ? _shufflePlaylist : _playlist;
  }

  static List<SongModel> _generateShufflePlaylist(List<SongModel> playlist) {
    if (playlist.isEmpty) return [];
    final shuffled = List.of(playlist);
    shuffled.shuffle();
    return shuffled;
  }
}
