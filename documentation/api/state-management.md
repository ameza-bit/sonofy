# Gestión de Estado - BLoC y Cubits

## 📖 Visión General

Sonofy utiliza el patrón BLoC (Business Logic Component) implementado a través de Cubits para una gestión de estado predecible y escalable. Cada Cubit maneja un dominio específico de la aplicación y mantiene su estado de forma inmutable.

## 🎵 PlayerCubit

### Estado (`presentation/blocs/player/player_state.dart`)

```dart
class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isPlaying;

  const PlayerState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
  });

  /// Constructor para estado inicial
  factory PlayerState.initial() => const PlayerState(
    playlist: [],
    currentIndex: 0,
    isPlaying: false,
  );

  /// Getter para canción actual
  SongModel? get currentSong {
    if (playlist.isEmpty || currentIndex < 0 || currentIndex >= playlist.length) {
      return null;
    }
    return playlist[currentIndex];
  }

  /// Método para crear copias inmutables
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerState &&
        listEquals(other.playlist, playlist) &&
        other.currentIndex == currentIndex &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => Object.hash(playlist, currentIndex, isPlaying);
}
```

### Cubit (`presentation/blocs/player/player_cubit.dart`)

```dart
class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository;

  PlayerCubit(this._playerRepository) : super(PlayerState.initial());

  /// Establece una nueva canción para reproducir
  Future<void> setPlayingSong(List<SongModel> playlist, SongModel song) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    final bool isPlaying = await _playerRepository.play(song.data);
    emit(
      state.copyWith(
        playlist: playlist,
        currentIndex: index,
        isPlaying: isPlaying,
      ),
    );
  }

  /// Reproduce la siguiente canción en la playlist
  Future<void> nextSong() async {
    var currentIndex = state.currentIndex;
    if (currentIndex < state.playlist.length - 1) {
      currentIndex = currentIndex + 1;
    } else {
      currentIndex = 0; // Volver al principio
    }
    final bool isPlaying = await _playerRepository.play(
      state.playlist[currentIndex].data,
    );
    emit(state.copyWith(currentIndex: currentIndex, isPlaying: isPlaying));
  }

  /// Reproduce la canción anterior en la playlist
  Future<void> previousSong() async {
    var currentIndex = state.currentIndex;
    if (currentIndex > 0) {
      currentIndex = currentIndex - 1;
    } else {
      currentIndex = state.playlist.length - 1; // Ir al final
    }
    final bool isPlaying = await _playerRepository.play(
      state.playlist[currentIndex].data,
    );
    emit(state.copyWith(currentIndex: currentIndex, isPlaying: isPlaying));
  }

  /// Alterna entre reproducir y pausar
  Future<void> togglePlayPause() async {
    final bool isPlaying = await _playerRepository.togglePlayPause();
    emit(state.copyWith(isPlaying: isPlaying));
  }
}
```

#### Casos de Uso del PlayerCubit

1. **Reproducir canción**: Cuando el usuario selecciona una canción
2. **Control de reproducción**: Play/pause desde controles
3. **Navegación**: Siguiente/anterior en playlist
4. **Estado visual**: Actualizar UI según estado de reproducción

#### Uso en UI

```dart
// Escuchar cambios de estado
BlocBuilder<PlayerCubit, PlayerState>(
  builder: (context, state) {
    return IconButton(
      icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
    );
  },
)

// Responder a cambios específicos
BlocListener<PlayerCubit, PlayerState>(
  listener: (context, state) {
    if (state.currentSong != null) {
      // Actualizar notificación del sistema
    }
  },
  child: PlayerControls(),
)
```

## 📚 SongsCubit

### Estado (`presentation/blocs/songs/songs_state.dart`)

```dart
class SongsState {
  final List<SongModel> songs;
  final bool isLoading;
  final String? errorMessage;

  const SongsState({
    required this.songs,
    required this.isLoading,
    this.errorMessage,
  });

  /// Constructor para estado inicial
  factory SongsState.initial() => const SongsState(
    songs: [],
    isLoading: true,
    errorMessage: null,
  );

  /// Constructor para estado de carga
  factory SongsState.loading() => const SongsState(
    songs: [],
    isLoading: true,
    errorMessage: null,
  );

  /// Constructor para estado exitoso
  factory SongsState.loaded(List<SongModel> songs) => SongsState(
    songs: songs,
    isLoading: false,
    errorMessage: null,
  );

  /// Constructor para estado de error
  factory SongsState.error(String message) => SongsState(
    songs: const [],
    isLoading: false,
    errorMessage: message,
  );

  /// Método para crear copias inmutables
  SongsState copyWith({
    List<SongModel>? songs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SongsState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongsState &&
        listEquals(other.songs, songs) &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(songs, isLoading, errorMessage);
}
```

### Cubit (`presentation/blocs/songs/songs_cubit.dart`)

```dart
class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;

  SongsCubit(this._songsRepository) : super(SongsState.initial()) {
    _loadSongs(); // Carga automática al instanciar
  }

  /// Carga todas las canciones del dispositivo
  Future<void> loadSongs() async {
    emit(SongsState.loading());
    await _loadSongs();
  }

  /// Recarga la biblioteca de canciones
  Future<void> refreshSongs() async {
    await loadSongs();
  }

  /// Método privado para cargar canciones
  Future<void> _loadSongs() async {
    try {
      final songs = await _songsRepository.getSongsFromDevice();
      emit(SongsState.loaded(songs));
    } catch (e) {
      emit(SongsState.error('Error al cargar canciones: ${e.toString()}'));
    }
  }
}
```

#### Casos de Uso del SongsCubit

1. **Carga inicial**: Obtener biblioteca al iniciar la app
2. **Actualización**: Refrescar biblioteca tras cambios
3. **Manejo de errores**: Mostrar estados de error
4. **Estados de carga**: Indicadores visuales durante carga

#### Uso en UI

```dart
// Mostrar lista de canciones
BlocBuilder<SongsCubit, SongsState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (state.errorMessage != null) {
      return Text('Error: ${state.errorMessage}');
    }
    
    return ListView.builder(
      itemCount: state.songs.length,
      itemBuilder: (context, index) {
        return SongCard(song: state.songs[index]);
      },
    );
  },
)
```

## ⚙️ SettingsCubit

### Estado (`presentation/blocs/settings/settings_state.dart`)

```dart
class SettingsState {
  final Settings settings;
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    required this.settings,
    required this.isLoading,
    this.errorMessage,
  });

  /// Constructor para estado inicial
  factory SettingsState.initial() => SettingsState(
    settings: Settings(), // Configuraciones por defecto
    isLoading: true,
    errorMessage: null,
  );

  /// Constructor para estado cargado
  factory SettingsState.loaded(Settings settings) => SettingsState(
    settings: settings,
    isLoading: false,
    errorMessage: null,
  );

  /// Constructor para estado de error
  factory SettingsState.error(String message, Settings settings) => SettingsState(
    settings: settings,
    isLoading: false,
    errorMessage: message,
  );

  /// Método para crear copias inmutables
  SettingsState copyWith({
    Settings? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.settings == settings &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(settings, isLoading, errorMessage);
}
```

### Cubit (`presentation/blocs/settings/settings_cubit.dart`)

```dart
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsState.initial()) {
    _loadSettings(); // Carga automática al instanciar
  }

  /// Carga las configuraciones guardadas
  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    await _loadSettings();
  }

  /// Actualiza el modo de tema
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final updatedSettings = state.settings.copyWith(themeMode: themeMode);
    await _saveSettings(updatedSettings);
  }

  /// Actualiza el color primario
  Future<void> updatePrimaryColor(Color primaryColor) async {
    final updatedSettings = state.settings.copyWith(primaryColor: primaryColor);
    await _saveSettings(updatedSettings);
  }

  /// Actualiza el tamaño de fuente
  Future<void> updateFontSize(double fontSize) async {
    final updatedSettings = state.settings.copyWith(fontSize: fontSize);
    await _saveSettings(updatedSettings);
  }

  /// Actualiza el idioma
  Future<void> updateLanguage(Language language) async {
    final updatedSettings = state.settings.copyWith(language: language);
    await _saveSettings(updatedSettings);
  }

  /// Actualiza configuración biométrica
  Future<void> updateBiometricEnabled(bool enabled) async {
    final updatedSettings = state.settings.copyWith(biometricEnabled: enabled);
    await _saveSettings(updatedSettings);
  }

  /// Restaura configuraciones por defecto
  Future<void> resetSettings() async {
    try {
      await _settingsRepository.resetSettings();
      emit(SettingsState.loaded(Settings()));
    } catch (e) {
      emit(SettingsState.error(
        'Error al restaurar configuraciones: ${e.toString()}',
        state.settings,
      ));
    }
  }

  /// Método privado para cargar configuraciones
  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsState.loaded(settings));
    } catch (e) {
      emit(SettingsState.error(
        'Error al cargar configuraciones: ${e.toString()}',
        Settings(),
      ));
    }
  }

  /// Método privado para guardar configuraciones
  Future<void> _saveSettings(Settings settings) async {
    try {
      await _settingsRepository.saveSettings(settings);
      emit(SettingsState.loaded(settings));
    } catch (e) {
      emit(SettingsState.error(
        'Error al guardar configuraciones: ${e.toString()}',
        state.settings,
      ));
    }
  }
}
```

#### Casos de Uso del SettingsCubit

1. **Cambio de tema**: Alternar entre claro/oscuro
2. **Personalización**: Cambiar color primario
3. **Accesibilidad**: Ajustar tamaño de fuente
4. **Localización**: Cambiar idioma
5. **Seguridad**: Configurar autenticación biométrica

#### Uso en UI

```dart
// Escuchar cambios que afectan el tema
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (previous, current) {
    return previous.settings.themeMode != current.settings.themeMode ||
           previous.settings.primaryColor != current.settings.primaryColor ||
           previous.settings.fontSize != current.settings.fontSize;
  },
  builder: (context, state) {
    return MaterialApp(
      theme: MainTheme.createLightTheme(state.settings.primaryColor),
      darkTheme: MainTheme.createDarkTheme(state.settings.primaryColor),
      themeMode: state.settings.themeMode,
      // ...
    );
  },
)

// Switch para configuración biométrica
BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, state) {
    return Switch(
      value: state.settings.biometricEnabled,
      onChanged: (value) {
        context.read<SettingsCubit>().updateBiometricEnabled(value);
      },
    );
  },
)
```

## 🔄 Comunicación Entre Cubits

### Patrón Observer
```dart
// Escuchar cambios en un Cubit desde otro
class PlayerCubit extends Cubit<PlayerState> {
  late final StreamSubscription _settingsSubscription;

  PlayerCubit(this._playerRepository, SettingsCubit settingsCubit) 
      : super(PlayerState.initial()) {
    // Reaccionar a cambios en configuraciones
    _settingsSubscription = settingsCubit.stream.listen((settingsState) {
      // Aplicar configuraciones al reproductor
    });
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel();
    return super.close();
  }
}
```

### Eventos Globales
```dart
// Para eventos que afectan múltiples Cubits
class GlobalEvents {
  static final _controller = StreamController<GlobalEvent>.broadcast();
  static Stream<GlobalEvent> get stream => _controller.stream;
  static void emit(GlobalEvent event) => _controller.add(event);
}

abstract class GlobalEvent {}
class SongChanged extends GlobalEvent {
  final SongModel song;
  SongChanged(this.song);
}
```

## 🎯 Optimizaciones de Rendimiento

### BuildWhen para Reconstrucciones Selectivas
```dart
BlocBuilder<PlayerCubit, PlayerState>(
  buildWhen: (previous, current) {
    // Solo reconstruir cuando cambia el estado de reproducción
    return previous.isPlaying != current.isPlaying;
  },
  builder: (context, state) {
    return PlayPauseButton(isPlaying: state.isPlaying);
  },
)
```

### BlocSelector para Propiedades Específicas
```dart
BlocSelector<PlayerCubit, PlayerState, bool>(
  selector: (state) => state.isPlaying,
  builder: (context, isPlaying) {
    return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
  },
)
```

### Lazy Loading de Estados
```dart
class SongsCubit extends Cubit<SongsState> {
  SongsCubit(this._songsRepository) : super(SongsState.initial());
  
  // No cargar automáticamente, solo cuando se necesite
  Future<void> loadWhenNeeded() async {
    if (state.songs.isEmpty && !state.isLoading) {
      await loadSongs();
    }
  }
}
```

## 🧪 Testing de Cubits

### Configuración de Tests
```dart
group('PlayerCubit Tests', () {
  late MockPlayerRepository mockPlayerRepository;
  late PlayerCubit playerCubit;

  setUp(() {
    mockPlayerRepository = MockPlayerRepository();
    playerCubit = PlayerCubit(mockPlayerRepository);
  });

  tearDown(() {
    playerCubit.close();
  });

  blocTest<PlayerCubit, PlayerState>(
    'emits [playing] when setPlayingSong is called',
    build: () {
      when(() => mockPlayerRepository.play(any()))
          .thenAnswer((_) async => true);
      return playerCubit;
    },
    act: (cubit) => cubit.setPlayingSong([mockSong], mockSong),
    expect: () => [
      PlayerState(
        playlist: [mockSong],
        currentIndex: 0,
        isPlaying: true,
      ),
    ],
  );
});
```

## 📱 Consideraciones de Plataforma

### Persistencia de Estado
- **Android**: Manejo automático de lifecycle
- **iOS**: Preservación durante app switching
- **Web**: Compatibilidad con navegador

### Rendimiento
- **Estados inmutables**: Previene mutaciones accidentales
- **Comparaciones eficientes**: Implementación de == y hashCode
- **Reconstrucciones mínimas**: BuildWhen selectivo

La gestión de estado en Sonofy proporciona una base sólida para una experiencia de usuario fluida y predecible, con separación clara de responsabilidades y facilidad para testing y mantenimiento.