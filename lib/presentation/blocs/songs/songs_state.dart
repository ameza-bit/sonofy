import 'package:on_audio_query_pluse/on_audio_query.dart';

/// Clase de estado para manejar datos de biblioteca musical y estados de carga
/// 
/// Este estado soporta múltiples escenarios de carga:
/// - Canciones del dispositivo (acceso a biblioteca nativa)
/// - Canciones locales (acceso al sistema de archivos en iOS)
/// - Carga progresiva con seguimiento de progreso en tiempo real
/// 
/// Características:
/// - Múltiples estados de carga para diferentes fuentes de datos
/// - Seguimiento de progreso para operaciones de carga progresiva
/// - Propiedades computadas para conveniencia de UI
/// - Separación entre canciones del dispositivo y locales para iOS
class SongsState {
  /// Lista combinada de todas las canciones (dispositivo + locales)
  final List<SongModel> songs;
  
  /// Canciones de directorios locales (solo iOS)
  final List<SongModel> localSongs;
  
  /// Canciones de la biblioteca musical nativa del dispositivo
  final List<SongModel> deviceSongs;
  
  /// Estado de carga para obtención inicial de datos
  final bool isLoading;
  
  /// Estado de carga solo para canciones locales
  final bool isLoadingLocal;
  
  /// Estado de carga para operaciones progresivas
  final bool isLoadingProgressive;
  
  /// Número de elementos cargados durante operaciones progresivas
  final int loadedCount;
  
  /// Número total de elementos a cargar durante operaciones progresivas
  final int totalCount;
  
  /// Mensaje de error si alguna operación falla
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

  // Getters de conveniencia para componentes de UI
  
  /// Si hay canciones locales cargadas
  bool get hasLocalSongs => localSongs.isNotEmpty;
  
  /// Si hay canciones del dispositivo cargadas
  bool get hasDeviceSongs => deviceSongs.isNotEmpty;
  
  /// Número total de canciones en la lista combinada
  int get totalSongs => songs.length;
  
  /// Número de canciones locales
  int get localSongsCount => localSongs.length;
  
  /// Número de canciones del dispositivo
  int get deviceSongsCount => deviceSongs.length;
  
  /// Porcentaje de progreso (0.0 a 1.0) para operaciones de carga progresiva
  double get progressPercent => totalCount > 0 ? loadedCount / totalCount : 0.0;

  List<SongModel> get orderedSongs {
    final combined = [...localSongs, ...deviceSongs];
    combined.sort((a, b) => a.title.compareTo(b.title));
    return combined;
  }
}
