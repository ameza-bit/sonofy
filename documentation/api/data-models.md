# Modelos de Datos

## 📖 Visión General

Los modelos de datos en Sonofy representan las entidades principales de la aplicación de manera inmutable y type-safe. Cada modelo incluye serialización JSON, métodos de comparación y funcionalidades para crear copias modificadas.

## ⚙️ Settings Model

### Definición (`data/models/setting.dart`)

```dart
class Settings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;
  final Language language;
  final bool biometricEnabled;

  Settings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF5C42FF),
    this.fontSize = 1.0,
    this.language = Language.spanish,
    this.biometricEnabled = false,
  });

  /// Constructor desde JSON
  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
    primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
    fontSize: (json['fontSize'] ?? 1.0).toDouble(),
    language: Language.values[json['language'] ?? 0],
    biometricEnabled: json['biometricEnabled'] ?? false,
  );

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'isDarkMode': themeMode.index,
    'primaryColor': primaryColor.toARGB32(),
    'fontSize': fontSize,
    'language': language.index,
    'biometricEnabled': biometricEnabled,
  };

  /// Crear copia con modificaciones
  Settings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
    Language? language,
    bool? biometricEnabled,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.themeMode == themeMode &&
        other.primaryColor == primaryColor &&
        other.fontSize == fontSize &&
        other.language == language &&
        other.biometricEnabled == biometricEnabled;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    primaryColor,
    fontSize,
    language,
    biometricEnabled,
  );

  @override
  String toString() {
    return 'Settings('
        'themeMode: $themeMode, '
        'primaryColor: $primaryColor, '
        'fontSize: $fontSize, '
        'language: $language, '
        'biometricEnabled: $biometricEnabled'
        ')';
  }
}
```

### Propiedades Detalladas

#### `themeMode` - ThemeMode
**Descripción**: Controla el modo de tema de la aplicación.

**Valores Posibles**:
- `ThemeMode.system` - Sigue la configuración del sistema
- `ThemeMode.light` - Tema claro fijo
- `ThemeMode.dark` - Tema oscuro fijo

**Uso**:
```dart
// Cambiar a tema oscuro
final newSettings = settings.copyWith(themeMode: ThemeMode.dark);

// Aplicar en MaterialApp
MaterialApp(
  themeMode: settings.themeMode,
  // ...
)
```

#### `primaryColor` - Color
**Descripción**: Color primario personalizable que se aplica a toda la interfaz.

**Color por Defecto**: `Color(0xFF5C42FF)` (Púrpura/Violeta)

**Uso**:
```dart
// Cambiar color primario
final newSettings = settings.copyWith(
  primaryColor: const Color(0xFF2196F3), // Azul
);

// Aplicar en tema
theme: MainTheme.createLightTheme(settings.primaryColor)
```

#### `fontSize` - double
**Descripción**: Factor de escalado para el tamaño de fuente global.

**Valores**:
- `0.8` - Pequeño
- `1.0` - Normal (por defecto)
- `1.2` - Grande
- `1.4` - Extra grande

**Uso**:
```dart
// Aplicar escalado
TextStyle(
  fontSize: 16 * settings.fontSize, // 16px escalado
)

// Con extensión
extension ThemeExtensions on BuildContext {
  double scaleText(double size) {
    final settings = read<SettingsCubit>().state.settings;
    return size * settings.fontSize;
  }
}
```

#### `language` - Language (Enum)
**Descripción**: Idioma de la aplicación.

**Valores**:
```dart
enum Language {
  spanish,
  english;

  String get code {
    switch (this) {
      case Language.spanish:
        return 'es';
      case Language.english:
        return 'en';
    }
  }

  String get displayName {
    switch (this) {
      case Language.spanish:
        return 'Español';
      case Language.english:
        return 'English';
    }
  }
}
```

#### `biometricEnabled` - bool
**Descripción**: Indica si la autenticación biométrica está habilitada.

**Estado**: Preparado para implementación futura

**Uso Planificado**:
```dart
if (settings.biometricEnabled) {
  // Solicitar autenticación biométrica
  await BiometricAuth.authenticate();
}
```

### Serialización JSON

#### Funciones Helper
```dart
/// Convierte JSON string a Settings
Settings settingsFromJson(String str) => Settings.fromJson(json.decode(str));

/// Convierte Settings a JSON string
String settingsToJson(Settings data) => json.encode(data.toJson());
```

#### Ejemplo de JSON
```json
{
  "isDarkMode": 0,
  "primaryColor": 6055167,
  "fontSize": 1.2,
  "language": 0,
  "biometricEnabled": false
}
```

#### Manejo de Migración
```dart
factory Settings.fromJson(Map<String, dynamic> json) => Settings(
  // Valores por defecto para retrocompatibilidad
  themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
  primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
  fontSize: (json['fontSize'] ?? 1.0).toDouble(),
  language: Language.values[json['language'] ?? 0],
  biometricEnabled: json['biometricEnabled'] ?? false, // Nuevo campo
);
```

## 🎵 SongModel (Externo)

### Fuente
El `SongModel` es proporcionado por el paquete `on_audio_query_pluse` y representa una canción en el dispositivo.

### Propiedades Principales
```dart
class SongModel {
  final int id;                    // ID único de la canción
  final String title;              // Título de la canción
  final String? artist;            // Artista
  final String? composer;          // Compositor
  final String? album;             // Álbum
  final String? genre;             // Género musical
  final String data;               // Ruta del archivo
  final int duration;              // Duración en milisegundos
  final int size;                  // Tamaño del archivo
  final String? dateAdded;         // Fecha de adición
  final String? dateModified;      // Fecha de modificación
  // ... más propiedades
}
```

### Uso en la Aplicación
```dart
// Obtener información de la canción
final songName = song.title;
final artistName = song.artist ?? song.composer ?? 'Artista Desconocido';
final durationText = DurationFormat.format(Duration(milliseconds: song.duration));

// Reproducir canción
await playerRepository.play(song.data); // Usar la ruta del archivo

// Mostrar carátula
QueryArtworkWidget(
  id: song.id,
  type: ArtworkType.AUDIO,
  // ...
)
```

### Extensiones Personalizadas
```dart
extension SongModelExtensions on SongModel {
  /// Obtiene el nombre del artista con fallback
  String get displayArtist => artist ?? composer ?? 'Artista Desconocido';
  
  /// Convierte duración a formato legible
  String get formattedDuration {
    final duration = Duration(milliseconds: this.duration);
    return DurationFormat.format(duration);
  }
  
  /// Verifica si la canción tiene carátula
  bool get hasArtwork => true; // on_audio_query maneja esto internamente
  
  /// Obtiene el nombre para mostrar
  String get displayName => title.isNotEmpty ? title : 'Canción Sin Título';
}
```

## 📱 Estados de BLoC

### PlayerState
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

  /// Canción actualmente seleccionada
  SongModel? get currentSong {
    if (playlist.isEmpty || currentIndex < 0 || currentIndex >= playlist.length) {
      return null;
    }
    return playlist[currentIndex];
  }

  /// Verifica si hay una siguiente canción
  bool get hasNext => currentIndex < playlist.length - 1;
  
  /// Verifica si hay una canción anterior
  bool get hasPrevious => currentIndex > 0;
  
  /// Verifica si la playlist está vacía
  bool get isEmpty => playlist.isEmpty;
}
```

### SongsState
```dart
class SongsState {
  final List<SongModel> songs;
  final bool isLoading;
  final String? errorMessage;

  /// Verifica si hay canciones cargadas
  bool get hasSongs => songs.isNotEmpty;
  
  /// Verifica si hay un error
  bool get hasError => errorMessage != null;
  
  /// Número total de canciones
  int get totalSongs => songs.length;
}
```

### SettingsState
```dart
class SettingsState {
  final Settings settings;
  final bool isLoading;
  final String? errorMessage;

  /// Verifica si las configuraciones están listas
  bool get isReady => !isLoading && errorMessage == null;
  
  /// Verifica si hay un error
  bool get hasError => errorMessage != null;
}
```

## 🔄 Patrones de Inmutabilidad

### copyWith Pattern
```dart
// Patrón estándar para modificaciones inmutables
final updatedSettings = currentSettings.copyWith(
  primaryColor: Colors.blue,
  fontSize: 1.2,
);

// Solo se modifican los campos especificados
assert(updatedSettings.themeMode == currentSettings.themeMode);
assert(updatedSettings.primaryColor == Colors.blue);
assert(updatedSettings.fontSize == 1.2);
```

### Comparación de Objetos
```dart
// Implementación completa de igualdad
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true; // Misma referencia
  return other is Settings &&
      other.themeMode == themeMode &&
      other.primaryColor == primaryColor &&
      other.fontSize == fontSize &&
      other.language == language &&
      other.biometricEnabled == biometricEnabled;
}

@override
int get hashCode => Object.hash(
  themeMode,
  primaryColor,
  fontSize,
  language,
  biometricEnabled,
);
```

## 🎯 Validaciones y Constraints

### Settings Validation
```dart
extension SettingsValidation on Settings {
  /// Valida que el factor de fuente esté en rango válido
  bool get isValidFontSize => fontSize >= 0.5 && fontSize <= 2.0;
  
  /// Valida que el color primario no sea transparente
  bool get isValidPrimaryColor => primaryColor.alpha == 255;
  
  /// Valida que todas las configuraciones sean válidas
  bool get isValid => isValidFontSize && isValidPrimaryColor;
  
  /// Normaliza valores fuera de rango
  Settings normalized() {
    return copyWith(
      fontSize: fontSize.clamp(0.5, 2.0),
      primaryColor: primaryColor.withAlpha(255),
    );
  }
}
```

### SongModel Validation
```dart
extension SongModelValidation on SongModel {
  /// Verifica si el archivo existe
  bool get fileExists => File(data).existsSync();
  
  /// Verifica si la duración es válida
  bool get hasValidDuration => duration > 0;
  
  /// Verifica si tiene información mínima requerida
  bool get hasMinimumInfo => title.isNotEmpty || data.isNotEmpty;
}
```

## 🔮 Extensiones Futuras

### Configuraciones Avanzadas
```dart
class AdvancedSettings {
  final EqualizerSettings equalizer;
  final PlaybackSettings playback;
  final NetworkSettings network;
  final CacheSettings cache;
  
  // Configuraciones más específicas
}

class EqualizerSettings {
  final List<double> bandLevels;
  final String presetName;
  final bool enabled;
}
```

### Metadata Extendida
```dart
class ExtendedSongModel {
  final SongModel baseSong;
  final String? lyrics;
  final List<String> tags;
  final double rating;
  final int playCount;
  final DateTime? lastPlayed;
  final Color? dominantColor; // Para temas dinámicos
}
```

### Estados Complejos
```dart
class PlaybackState {
  final SongModel? currentSong;
  final Duration position;
  final Duration duration;
  final PlaybackMode mode; // repeat, shuffle, etc.
  final double volume;
  final List<AudioEffect> effects;
}
```

Los modelos de datos proporcionan una base sólida y type-safe para toda la información que maneja Sonofy, con patrones consistentes de inmutabilidad, serialización y validación que facilitan el desarrollo y mantenimiento de la aplicación.