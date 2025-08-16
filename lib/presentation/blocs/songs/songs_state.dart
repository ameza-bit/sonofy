import 'package:on_audio_query_pluse/on_audio_query.dart';

class SongsState {
  final List<SongModel> songs;
  final List<SongModel> localSongs;
  final List<SongModel> deviceSongs;
  final bool isLoading;
  final bool isLoadingLocal;
  final String? error;

  SongsState({
    required this.songs,
    required this.localSongs,
    required this.deviceSongs,
    this.isLoading = false,
    this.isLoadingLocal = false,
    this.error,
  });

  SongsState.initial()
    : songs = [],
      localSongs = [],
      deviceSongs = [],
      isLoading = false,
      isLoadingLocal = false,
      error = null;

  SongsState copyWith({
    List<SongModel>? songs,
    List<SongModel>? localSongs,
    List<SongModel>? deviceSongs,
    bool? isLoading,
    bool? isLoadingLocal,
    String? error,
  }) {
    return SongsState(
      songs: songs ?? this.songs,
      localSongs: localSongs ?? this.localSongs,
      deviceSongs: deviceSongs ?? this.deviceSongs,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocal: isLoadingLocal ?? this.isLoadingLocal,
      error: error ?? this.error,
    );
  }

  // Getters de conveniencia
  bool get hasLocalSongs => localSongs.isNotEmpty;
  bool get hasDeviceSongs => deviceSongs.isNotEmpty;
  int get totalSongs => songs.length;
  int get localSongsCount => localSongs.length;
  int get deviceSongsCount => deviceSongs.length;

  List<SongModel> get orderedSongs {
    final combined = [...localSongs, ...deviceSongs];
    combined.sort((a, b) => a.title.compareTo(b.title));
    return combined;
  }
}
