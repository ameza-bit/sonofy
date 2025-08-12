# Patrones de Diseño en Sonofy

## 🎯 Visión General

Sonofy implementa varios patrones de diseño reconocidos para mantener un código limpio, escalable y mantenible. Esta documentación detalla los patrones utilizados y su implementación específica en el proyecto.

## 🏗️ Patrones Arquitectónicos

### 1. Clean Architecture
**Propósito**: Separar responsabilidades en capas bien definidas.

**Implementación**:
```dart
// Estructura de capas
lib/
├── presentation/  # UI y gestión de estado local
├── domain/        # Lógica de negocio y contratos
├── data/          # Implementaciones y acceso a datos
└── core/          # Utilidades compartidas
```

**Beneficios**:
- Testabilidad mejorada
- Independencia de frameworks
- Mantenibilidad a largo plazo

### 2. Repository Pattern
**Propósito**: Abstraer el acceso a datos y centralizar la lógica de obtención.

**Implementación**:
```dart
// Interfaz (Domain Layer)
abstract class PlayerRepository {
  Future<bool> play(String url);
  Future<bool> pause();
  bool isPlaying();
}

// Implementación (Data Layer)
final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  
  @override
  Future<bool> play(String url) async {
    await player.play(DeviceFileSource(url));
    return isPlaying();
  }
}
```

**Beneficios**:
- Abstracción de fuentes de datos
- Fácil intercambio de implementaciones
- Testing simplificado con mocks

## 🔄 Patrones de Gestión de Estado

### 1. BLoC (Business Logic Component) Pattern
**Propósito**: Separar la lógica de negocio de la UI y gestionar estado de forma predecible.

**Implementación**:
```dart
// Cubit para simplicidad
class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository;

  PlayerCubit(this._playerRepository) : super(PlayerState.initial());

  Future<void> setPlayingSong(List<SongModel> playlist, SongModel song) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    final bool isPlaying = await _playerRepository.play(song.data);
    emit(state.copyWith(
      playlist: playlist,
      currentIndex: index,
      isPlaying: isPlaying,
    ));
  }
}

// Estado inmutable
class PlayerState {
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isPlaying;

  const PlayerState({
    required this.playlist,
    required this.currentIndex,
    required this.isPlaying,
  });

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
}
```

**Beneficios**:
- Estado predecible y unidireccional
- Fácil testing de lógica de negocio
- Separación clara UI/lógica

### 2. Provider Pattern (via BLoC)
**Propósito**: Inyección de dependencias y compartir estado entre widgets.

**Implementación**:
```dart
// Configuración en main.dart
MultiBlocProvider(
  providers: [
    BlocProvider<PlayerCubit>(
      create: (context) => PlayerCubit(playerRepository),
    ),
    BlocProvider<SongsCubit>(
      create: (context) => SongsCubit(songsRepository),
    ),
  ],
  child: const MainApp(),
)

// Uso en widgets
class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        // UI que reacciona al estado
      },
    );
  }
}
```

## 🎨 Patrones de Presentación

### 1. Builder Pattern
**Propósito**: Construcción flexible de widgets complejos.

**Implementación**:
```dart
// BlocBuilder para reconstrucción reactiva
BlocBuilder<PlayerCubit, PlayerState>(
  buildWhen: (previous, current) {
    // Control granular de reconstrucción
    return previous.isPlaying != current.isPlaying;
  },
  builder: (context, state) {
    return IconButton(
      icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
    );
  },
)
```

### 2. Factory Pattern
**Propósito**: Creación de objetos complejos de forma controlada.

**Implementación**:
```dart
// Factory para temas dinámicos
class MainTheme {
  static ThemeData createLightTheme(Color primaryColor) =>
      _createLightTheme(primaryColor);
      
  static ThemeData createDarkTheme(Color primaryColor) =>
      _createDarkTheme(primaryColor);
}

// Factory para modelos desde JSON
class Settings {
  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
    primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
    // ...
  );
}
```

### 3. Strategy Pattern
**Propósito**: Algoritmos intercambiables para diferentes contextos.

**Implementación**:
```dart
// Diferentes estrategias de transición
class PageTransition {
  Page<T> fadeTransition<T>() {
    return CustomTransitionPage<T>(
      child: page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
  
  Page<T> slideTransition<T>() {
    return CustomTransitionPage<T>(
      child: page,
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(/* ... */);
      },
    );
  }
}
```

## 🔧 Patrones de Utilidad

### 1. Extension Pattern
**Propósito**: Añadir funcionalidad a clases existentes sin modificarlas.

**Implementación**:
```dart
// Extensiones para BuildContext
extension ThemeExtensions on BuildContext {
  Color get musicWhite => const Color(0xFFF8F9FA);
  Color get musicDeepBlack => const Color(0xFF0A0A0A);
  
  double scaleText(double size) {
    final settings = read<SettingsCubit>().state.settings;
    return size * settings.fontSize;
  }
}

// Extensiones para responsive design
extension ResponsiveExtensions on BuildContext {
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && 
                       MediaQuery.of(context).size.width < 1200;
}
```

### 2. Observer Pattern
**Propósito**: Notificar cambios de estado a múltiples observadores.

**Implementación**:
```dart
// BLoC implementa Observer pattern internamente
// Múltiples widgets pueden observar el mismo Cubit
BlocListener<PlayerCubit, PlayerState>(
  listener: (context, state) {
    // Reaccionar a cambios de estado
    if (state.isPlaying) {
      // Actualizar notificación del sistema
    }
  },
  child: BlocBuilder<PlayerCubit, PlayerState>(
    builder: (context, state) {
      // UI que refleja el estado
    },
  ),
)
```

### 3. Singleton Pattern
**Propósito**: Garantizar una única instancia global de servicios.

**Implementación**:
```dart
// Servicio de preferencias como singleton
class Preferences {
  static SharedPreferences? _preferences;
  
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get instance {
    assert(_preferences != null, 'Preferences not initialized');
    return _preferences!;
  }
}
```

## 🎭 Patrones de Composición

### 1. Decorator Pattern
**Propósito**: Añadir funcionalidad a widgets de forma dinámica.

**Implementación**:
```dart
// Hero widget como decorator
Hero(
  tag: 'player_container',
  child: Material(
    type: MaterialType.transparency,
    child: BottomClipperContainer(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        children: [
          const PlayerSlider(),
          const PlayerControl(),
        ],
      ),
    ),
  ),
)
```

### 2. Composite Pattern
**Propósito**: Tratar objetos individuales y composiciones de manera uniforme.

**Implementación**:
```dart
// Widgets compuestos que actúan como widgets individuales
class SongCard extends StatelessWidget {
  // Compuesto por múltiples widgets simples
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: QueryArtworkWidget(/* ... */),
        title: Text(song.title),
        subtitle: Text(song.artist),
        trailing: IconButton(/* ... */),
        onTap: () => _playSong(),
      ),
    );
  }
}
```

## 📏 Principios SOLID Aplicados

### Single Responsibility Principle (SRP)
```dart
// Cada cubit tiene una responsabilidad específica
class PlayerCubit extends Cubit<PlayerState> {
  // Solo maneja estado del reproductor
}

class SongsCubit extends Cubit<SongsState> {
  // Solo maneja estado de la biblioteca
}
```

### Open/Closed Principle (OCP)
```dart
// Abierto para extensión, cerrado para modificación
abstract class PlayerRepository {
  // Interfaz estable
}

// Nuevas implementaciones sin modificar existentes
class WebPlayerRepositoryImpl implements PlayerRepository {
  // Nueva implementación para web
}
```

### Liskov Substitution Principle (LSP)
```dart
// Cualquier implementación de PlayerRepository 
// puede sustituir a otra sin romper la funcionalidad
final PlayerRepository repo = PlayerRepositoryImpl(); // o cualquier otra implementación
final cubit = PlayerCubit(repo); // Funciona con cualquier implementación
```

### Interface Segregation Principle (ISP)
```dart
// Interfaces específicas y cohesivas
abstract class PlayerRepository {
  // Solo métodos relacionados con reproducción
}

abstract class SongsRepository {
  // Solo métodos relacionados con canciones
}
```

### Dependency Inversion Principle (DIP)
```dart
// Dependencia de abstracciones, no concreciones
class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository; // Abstracción, no implementación
}
```

## 🎯 Beneficios de los Patrones Implementados

### ✅ Mantenibilidad
- Código organizado y predecible
- Cambios localizados sin efectos colaterales
- Fácil identificación de responsabilidades

### ✅ Testabilidad
- Dependencias inyectables fáciles de mockear
- Lógica de negocio aislada de UI
- Estados inmutables verificables

### ✅ Escalabilidad
- Nuevas características sin modificar existentes
- Patrones reutilizables en diferentes contextos
- Arquitectura preparada para crecimiento

### ✅ Legibilidad
- Código autodocumentado por patrones conocidos
- Convenciones consistentes en todo el proyecto
- Separación clara de responsabilidades

Estos patrones trabajan en conjunto para crear una base sólida que facilita el desarrollo, mantenimiento y evolución continua de Sonofy.