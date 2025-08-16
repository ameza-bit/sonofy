# Repositorios - API de Datos

## 📖 Visión General

Los repositorios en Sonofy implementan el patrón Repository para abstraer el acceso a datos y proporcionar una interfaz limpia entre la lógica de negocio y las fuentes de datos. Cada repositorio maneja un dominio específico de datos.

## 🎵 PlayerRepository

### Interfaz (`domain/repositories/player_repository.dart`)

```dart
abstract class PlayerRepository {
  /// Reproduce una canción desde una URL local o iPod library
  Future<bool> play(String url);
  
  /// Pausa la reproducción actual
  Future<bool> pause();
  
  /// Alterna entre play y pause
  Future<bool> togglePlayPause();
  
  /// Busca a una posición específica en la canción
  Future<bool> seek(Duration position);
  
  /// Obtiene la posición actual de reproducción
  Future<Duration?> getCurrentPosition();
  
  /// Obtiene la duración total de la canción actual
  Future<Duration?> getDuration();
  
  /// Verifica si está reproduciendo actualmente
  bool isPlaying();
}
```

### Implementación (`data/repositories/player_repository_impl.dart`)

```dart
final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;

  @override
  bool isPlaying() {
    if (_usingNativePlayer && Platform.isIOS) {
      // Para reproductor nativo, asumir playing cuando activo
      // UI debe verificar estado con getNativeMusicPlayerStatus()
      return true;
    }
    return player.state == PlayerState.playing;
  }

  @override
  Future<bool> play(String url) async {
    await player.stop();
    await IpodLibraryConverter.stopNativeMusicPlayer();
    _usingNativePlayer = false;

    if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
      // Verificar protección DRM
      final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
      if (isDrmProtected) return false;

      // Usar reproductor nativo iOS para URLs iPod library
      final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
      if (success) _usingNativePlayer = true;
      return success;
    } else {
      // Usar AudioPlayers para archivos regulares (y iPod URLs en Android)
      await player.play(DeviceFileSource(url));
      return isPlaying();
    }
  }

  @override
  Future<bool> pause() async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      return false;
    } else {
      await player.pause();
    }
    return isPlaying();
  }

  @override
  Future<bool> togglePlayPause() async {
    if (_usingNativePlayer && Platform.isIOS) {
      final status = await IpodLibraryConverter.getNativeMusicPlayerStatus();
      if (status == 'playing') {
        await IpodLibraryConverter.pauseNativeMusicPlayer();
        return false;
      } else if (status == 'paused') {
        await IpodLibraryConverter.resumeNativeMusicPlayer();
        return true;
      } else {
        return status == 'playing';
      }
    } else if (isPlaying()) {
      await player.pause();
    } else {
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<bool> seek(Duration position) async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.seekToPosition(position);
      await IpodLibraryConverter.resumeNativeMusicPlayer();
      return isPlaying();
    } else {
      await player.seek(position);
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.getCurrentPosition();
    } else {
      return player.getCurrentPosition();
    }
  }

  @override
  Future<Duration?> getDuration() async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.getDuration();
    } else {
      return player.getDuration();
    }
  }
}
```

#### Dependencias Externas
- **audioplayers**: `^6.5.0` - Reproducción de audio multiplataforma
- **IpodLibraryConverter**: Interfaz Flutter-iOS para Method Channels
- **MPMusicPlayerController**: Reproductor nativo iOS (iOS framework nativo)

#### Arquitectura Dual de Reproducción

##### 🍎 iOS - Sistema Dual
- **URLs `ipod-library://`**: Usa MPMusicPlayerController nativo
- **Archivos locales (.mp3)**: Usa AudioPlayers
- **Switching automático**: Basado en detección de URL
- **Verificación DRM**: Automática para archivos protegidos

##### 🤖 Android - Sistema Único
- **Todos los archivos**: Usa AudioPlayers únicamente
- **URLs `ipod-library://`**: Tratadas como archivos regulares (fallback graceful)
- **Sin Method Channels**: IpodLibraryConverter retorna false para todo

#### Casos de Uso
1. **Reproducir canción**: `setPlayingSong()` en PlayerCubit
2. **Control de reproducción**: Botones play/pause en UI
3. **Navegación**: Siguiente/anterior en playlist
4. **Seek**: Control manual de posición
5. **🆕 iPod Library**: Reproducción nativa de biblioteca iOS
6. **🆕 Verificación DRM**: Protección automática contra archivos protegidos

#### Manejo de Errores
- **Archivos inexistentes**: Retorna false en operaciones
- **Formatos no soportados**: AudioPlayers maneja automáticamente
- **Permisos**: Gestionado por la implementación del plugin
- **🆕 URLs iPod library en Android**: Fallback graceful a AudioPlayers
- **🆕 Archivos DRM protegidos**: Detección y rechazo automático
- **🆕 Method Channel failures**: Retorno seguro false sin crashes

## 📚 SongsRepository

### Interfaz (`domain/repositories/songs_repository.dart`)

```dart
abstract class SongsRepository {
  /// Obtiene todas las canciones disponibles en el dispositivo
  Future<List<SongModel>> getSongsFromDevice();
  
  /// Permite al usuario seleccionar una carpeta de música
  Future<String?> selectMusicFolder();
  
  /// Obtiene archivos MP3 de una carpeta específica
  Future<List<File>> getSongsFromFolder(String folderPath);
}
```

### Implementación (`data/repositories/songs_repository_impl.dart`)

```dart
final class SongsRepositoryImpl implements SongsRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> _configureAudioQuery() async {
    await _audioQuery.setLogConfig(
      LogConfig(logType: LogType.DEBUG, showDetailedLog: true),
    );

    return _checkAndRequestPermissions();
  }

  Future<bool> _checkAndRequestPermissions({bool retry = false}) async {
    return _audioQuery.checkAndRequest(retryRequest: retry);
  }

  @override
  Future<List<SongModel>> getSongsFromDevice() async {
    final bool canContinue = await _configureAudioQuery();

    if (!canContinue) {
      return []; // Sin permisos, retorna lista vacía
    }

    return _audioQuery.querySongs();
  }

  @override
  Future<String?> selectMusicFolder() async {
    // Solo iOS soporta selección manual de carpetas
    if (Platform.isIOS) {
      try {
        final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
        return selectedDirectory;
      } catch (e) {
        return null;
      }
    }
    // Android no soporta selección manual, retorna null
    return null;
  }

  @override
  Future<List<File>> getSongsFromFolder(String folderPath) async {
    // Solo iOS soporta escaneo de carpetas específicas
    if (Platform.isIOS) {
      try {
        final directory = Directory(folderPath);
        if (!directory.existsSync()) {
          return [];
        }

        final List<File> mp3Files = [];
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File && _isMp3File(entity.path)) {
            mp3Files.add(entity);
          }
        }

        return mp3Files;
      } catch (e) {
        return [];
      }
    }
    // Android no soporta escaneo de carpetas específicas, retorna lista vacía
    return [];
  }

  bool _isMp3File(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'mp3';
  }
}
```

#### Dependencias Externas
- **on_audio_query_pluse**: `^2.9.4` - Consulta de metadata musical (Ambas plataformas)
- **file_picker**: `^10.3.1` - Selección de archivos y carpetas (Solo iOS)

#### Comportamiento Específico por Plataforma

##### 🍎 iOS
- **getSongsFromDevice()**: Accede a música usando on_audio_query_pluse
- **selectMusicFolder()**: Usa FilePicker.platform.getDirectoryPath()
- **getSongsFromFolder()**: Escanea carpetas seleccionadas recursivamente
- **Experiencia**: Combina música del dispositivo + carpetas seleccionadas manualmente

##### 🤖 Android
- **getSongsFromDevice()**: Accede a toda la música usando on_audio_query_pluse
- **selectMusicFolder()**: Siempre retorna null (no soportado)
- **getSongsFromFolder()**: Siempre retorna lista vacía (no soportado)
- **Experiencia**: Solo música del dispositivo, acceso automático y completo

#### Modelo de Datos
```dart
// SongModel es proporcionado por on_audio_query_pluse
class SongModel {
  final int id;
  final String title;
  final String? artist;
  final String? composer;
  final String data; // Ruta del archivo
  final int duration;
  // ... más propiedades
}
```

#### Gestión de Permisos
1. **Configuración inicial**: Establece configuración de logging
2. **Solicitud de permisos**: Automática al primer acceso
3. **Manejo de rechazo**: Retorna lista vacía sin errores
4. **Reintentos**: Capacidad de reintento si es necesario

#### Casos de Uso
1. **Carga inicial**: Obtener biblioteca al iniciar la app
2. **Actualización**: Refrescar biblioteca tras cambios  
3. **Búsqueda**: Base para funciones de búsqueda futuras
4. **Importación local (iOS)**: Seleccionar y escanear carpetas de música
5. **Acceso automático (Android)**: Toda la música via on_audio_query_pluse

## ⚙️ SettingsRepository

### Interfaz (`domain/repositories/settings_repository.dart`)

```dart
abstract class SettingsRepository {
  /// Obtiene las configuraciones actuales
  Future<Settings> getSettings();
  
  /// Guarda las configuraciones
  Future<void> saveSettings(Settings settings);
  
  /// Restaura configuraciones por defecto
  Future<void> resetSettings();
}
```

### Implementación (`data/repositories/settings_repository_impl.dart`)

```dart
final class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';

  @override
  Future<Settings> getSettings() async {
    final prefs = Preferences.instance;
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      return settingsFromJson(settingsJson);
    }
    
    return Settings(); // Configuraciones por defecto
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    final prefs = Preferences.instance;
    final settingsJson = settingsToJson(settings);
    await prefs.setString(_settingsKey, settingsJson);
  }

  @override
  Future<void> resetSettings() async {
    final prefs = Preferences.instance;
    await prefs.remove(_settingsKey);
  }
}
```

#### Dependencias Externas
- **shared_preferences**: `^2.5.3` - Persistencia local

#### Modelo de Datos
```dart
class Settings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;
  final Language language;
  final bool biometricEnabled;
  final String? localMusicPath;

  Settings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF5C42FF),
    this.fontSize = 1.0,
    this.language = Language.spanish,
    this.biometricEnabled = false,
    this.localMusicPath,
  });

  // Serialización JSON
  factory Settings.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  // Inmutabilidad
  Settings copyWith({...});
}
```

#### Configuraciones Disponibles

| Configuración | Tipo | Por Defecto | Descripción |
|---------------|------|-------------|-------------|
| `themeMode` | `ThemeMode` | `system` | Modo de tema (claro/oscuro/sistema) |
| `primaryColor` | `Color` | `0xFF5C42FF` | Color primario personalizable |
| `fontSize` | `double` | `1.0` | Factor de escalado de fuente |
| `language` | `Language` | `spanish` | Idioma de la aplicación |
| `biometricEnabled` | `bool` | `false` | Autenticación biométrica |
| `localMusicPath` | `String?` | `null` | Ruta de carpeta de música local |

#### Casos de Uso
1. **Carga inicial**: Aplicar configuraciones al iniciar
2. **Cambios de tema**: Alternar modo claro/oscuro
3. **Personalización**: Cambiar color primario
4. **Accesibilidad**: Ajustar tamaño de fuente
5. **Localización**: Cambiar idioma
6. **Seguridad**: Configurar autenticación
7. **Música local**: Gestionar ruta de carpeta de música importada

## 🔧 Patrones de Implementación

### Gestión de Errores Consistente

```dart
// Patrón común en todos los repositorios
Future<T> operationWithErrorHandling<T>() async {
  try {
    // Operación principal
    return await _performOperation();
  } catch (e) {
    // Log del error
    debugPrint('Error in repository operation: $e');
    
    // Retorno seguro
    return _getDefaultValue<T>();
  }
}
```

### Inicialización Lazy

```dart
// Los repositorios se inicializan solo cuando se necesitan
class RepositoryImpl implements Repository {
  Service? _service;
  
  Service get service {
    _service ??= Service();
    return _service!;
  }
}
```

### Configuración de Dependencias

```dart
// main.dart - Inyección de dependencias
Future<void> main() async {
  // Inicialización de servicios compartidos
  await Preferences.init();
  
  // Instanciación de repositorios
  final SettingsRepository settingsRepository = SettingsRepositoryImpl();
  final SongsRepository songsRepository = SongsRepositoryImpl();
  final PlayerRepository playerRepository = PlayerRepositoryImpl();

  // Inyección en BLoCs
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(settingsRepository),
        ),
        // ...
      ],
      child: const MainApp(),
    ),
  );
}
```

## 🧪 Testing de Repositorios

### Mocks para Testing

```dart
// Mock para PlayerRepository
class MockPlayerRepository extends Mock implements PlayerRepository {}

// Mock para SongsRepository  
class MockSongsRepository extends Mock implements SongsRepository {}

// Mock para SettingsRepository
class MockSettingsRepository extends Mock implements SettingsRepository {}
```

### Ejemplo de Test

```dart
group('PlayerRepository Tests', () {
  late MockPlayerRepository mockPlayerRepository;
  late PlayerCubit playerCubit;

  setUp(() {
    mockPlayerRepository = MockPlayerRepository();
    playerCubit = PlayerCubit(mockPlayerRepository);
  });

  test('should return true when play is successful', () async {
    // Arrange
    when(() => mockPlayerRepository.play(any()))
        .thenAnswer((_) async => true);

    // Act
    final result = await mockPlayerRepository.play('test_url');

    // Assert
    expect(result, true);
    verify(() => mockPlayerRepository.play('test_url')).called(1);
  });
});
```

## 📱 Consideraciones de Plataforma

### Android
- **Permisos**: `READ_EXTERNAL_STORAGE` para acceso a archivos
- **Scoped Storage**: Compatibilidad con Android 10+
- **Audio Focus**: Manejo automático por audioplayers

### iOS
- **Permisos**: `NSMediaLibraryUsageDescription` en Info.plist
- **Background Audio**: Configuración en capabilities
- **AVAudioSession**: Manejo automático por audioplayers

### Multiplataforma
- **Rutas de archivos**: Uso de URIs consistentes
- **Formatos soportados**: Dependiente de la plataforma
- **Rendimiento**: Optimizado para cada sistema

## 🔮 Extensiones Futuras

### PlayerRepository
- **Streaming**: Soporte para URLs remotas
- **Ecualizador**: Control de audio avanzado
- **Efectos**: Reverb, echo, etc.
- **Visualización**: Datos para visualizadores de audio

### SongsRepository
- **Filtros avanzados**: Por género, año, etc.
- **Metadata extendida**: Letra, carátulas de alta resolución
- **Caché inteligente**: Optimización de consultas
- **Sincronización**: Con servicios en la nube

### SettingsRepository
- **Backup en nube**: Sincronización de configuraciones
- **Perfiles**: Múltiples configuraciones de usuario
- **Configuraciones avanzadas**: Por canción/álbum
- **Exportar/Importar**: Configuraciones compartibles

Los repositorios proporcionan una base sólida y extensible para el manejo de datos en Sonofy, manteniendo la separación de responsabilidades y facilitando el testing y mantenimiento del código.