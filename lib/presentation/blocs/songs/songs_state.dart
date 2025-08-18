import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongsState {
  final List<SongModel> songs;
  final List<SongModel> localSongs;
  final List<SongModel> deviceSongs;
  final bool isLoading;
  final bool isLoadingLocal;
  final bool isLoadingProgressive;
  final int loadedCount;
  final int totalCount;
  final String? error;

  SongsState({
    required this.songs,
    required this.localSongs,
    required this.deviceSongs,
    this.isLoading = false,
    this.isLoadingLocal = false,
    this.isLoadingProgressive = false,
    this.loadedCount = 0,
    this.totalCount = 0,
    this.error,
  });

  SongsState.initial()
    : songs = [],
      localSongs = [],
      deviceSongs = [],
      isLoading = false,
      isLoadingLocal = false,
      isLoadingProgressive = false,
      loadedCount = 0,
      totalCount = 0,
      error = null;

  SongsState copyWith({
    List<SongModel>? songs,
    List<SongModel>? localSongs,
    List<SongModel>? deviceSongs,
    bool? isLoading,
    bool? isLoadingLocal,
    bool? isLoadingProgressive,
    int? loadedCount,
    int? totalCount,
    String? error,
  }) {
    return SongsState(
      songs: songs ?? this.songs,
      localSongs: localSongs ?? this.localSongs,
      deviceSongs: deviceSongs ?? this.deviceSongs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocal: isLoadingLocal ?? this.isLoadingLocal,
      isLoadingProgressive: isLoadingProgressive ?? this.isLoadingProgressive,
      loadedCount: loadedCount ?? this.loadedCount,
      totalCount: totalCount ?? this.totalCount,
      error: error ?? this.error,
    );
  }

  // Getters de conveniencia
  bool get hasLocalSongs => localSongs.isNotEmpty;
  bool get hasDeviceSongs => deviceSongs.isNotEmpty;
  int get totalSongs => songs.length;
  int get localSongsCount => localSongs.length;
  int get deviceSongsCount => deviceSongs.length;
  double get progressPercent => totalCount > 0 ? loadedCount / totalCount : 0.0;

  List<SongModel> get orderedSongs {
    final combined = [...localSongs, ...deviceSongs];
    combined.sort((a, b) => a.title.compareTo(b.title));
    return combined;
  }
}
