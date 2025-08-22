import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/services/preferences.dart';

/// Modos de repetición para el reproductor.
/// 
/// - [none]: Reproduce secuencialmente y se detiene al final
/// - [one]: Repite la canción actual indefinidamente
/// - [all]: Repite toda la playlist indefinidamente
enum RepeatMode { none, one, all }

/// Estado del reproductor de música que maneja dos listas de reproducción.
/// 
/// Características principales:
/// - Mantiene playlist original y versión shuffle separadas
/// - activePlaylist devuelve la lista apropiada según isShuffleEnabled
/// - currentIndex se refiere siempre a la lista activa
/// - Shuffle inteligente coloca canción actual al inicio
class PlayerState {
  /// Lista original de canciones en orden normal
  final List<SongModel> _playlist;
  
  /// Lista de canciones mezcladas aleatoriamente
  final List<SongModel> _shufflePlaylist;
  
  /// Índice de la canción actual en la lista activa
  final int currentIndex;
  
  /// Si la música está reproduciéndose actualmente
  final bool isPlaying;
  
  /// Si el modo shuffle está activado
  final bool isShuffleEnabled;
  
  /// Modo de repetición actual
  final RepeatMode repeatMode;
  
  /// Si el temporizador de sueño está activo
  final bool isSleepTimerActive;
  
  /// Si debe esperar a que termine la canción antes de pausar
  final bool waitForSongToFinish;
  
  /// Velocidad de reproducción (1.0 = normal)
  final double playbackSpeed;
  
  /// Duración total del temporizador de sueño
  final Duration? sleepTimerDuration;
  
  /// Tiempo restante del temporizador de sueño
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

  /// Indica si hay una canción seleccionada válida.
  bool get hasSelectedSong =>
      activePlaylist.isNotEmpty &&
      currentIndex < activePlaylist.length &&
      currentIndex >= 0;

  /// Canción actualmente seleccionada en la lista activa.
  SongModel? get currentSong =>
      hasSelectedSong ? activePlaylist[currentIndex] : null;

  /// Lista original de canciones (acceso de solo lectura).
  List<SongModel> get playlist => _playlist;

  /// Lista shuffle actual (acceso de solo lectura).
  List<SongModel> get shufflePlaylist => _shufflePlaylist;

  /// Lista de reproducción activa según el estado de shuffle.
  /// 
  /// Returns:
  /// - _shufflePlaylist si isShuffleEnabled = true
  /// - _playlist si isShuffleEnabled = false
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
