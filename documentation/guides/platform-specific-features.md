# Funcionalidades Específicas por Plataforma

## 📖 Visión General

Sonofy implementa una arquitectura híbrida que optimiza la experiencia de usuario para cada plataforma, aprovechando las capacidades nativas de iOS y Android de manera diferenciada.

## 🎯 Estrategia de Implementación

### Principio de Diseño
- **iOS**: Máxima flexibilidad con selección manual de carpetas + acceso automático
- **Android**: Simplicidad con acceso automático completo via on_audio_query_pluse

### Beneficios
- **Experiencia optimizada**: Cada plataforma usa sus fortalezas nativas
- **Menor complejidad**: Android evita la gestión manual de archivos
- **Mejor rendimiento**: Sin dependencias innecesarias por plataforma
- **Mantenibilidad**: Código específico bien separado

## 🍎 Funcionalidades iOS

### Acceso a Música

#### Fuentes de Música
1. **Biblioteca del dispositivo** (on_audio_query_pluse)
   - Música de la app Música nativa
   - Archivos sincronizados con iTunes/Apple Music
   - Acceso automático con permisos

2. **Carpetas seleccionadas manualmente** (FilePicker)
   - Documentos, Downloads, iCloud Drive
   - Cualquier carpeta accesible al usuario
   - Escaneo recursivo de subcarpetas

#### Implementación Técnica

```dart
// SongsRepositoryImpl - iOS
@override
Future<String?> selectMusicFolder() async {
  if (Platform.isIOS) {
    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      return null;
    }
  }
  return null;
}

@override
Future<List<File>> getSongsFromFolder(String folderPath) async {
  if (Platform.isIOS) {
    final directory = Directory(folderPath);
    // Escaneo recursivo de archivos MP3
    final List<File> mp3Files = [];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && _isMp3File(entity.path)) {
        mp3Files.add(entity);
      }
    }
    return mp3Files;
  }
  return [];
}
```

#### Flujo de Usuario iOS

1. **Configuración inicial**
   - Usuario abre configuraciones
   - Ve sección "Música Local" disponible
   - Puede seleccionar carpetas adicionales

2. **Selección de carpeta**
   - Tap en "Seleccionar carpeta"
   - Se abre el picker nativo de iOS
   - Usuario navega y selecciona carpeta
   - App escanea automáticamente archivos MP3

3. **Biblioteca combinada**
   - Música del dispositivo + archivos de carpetas seleccionadas
   - Vista unificada en la biblioteca
   - Indicación visual del origen (device/local)

#### Permisos iOS

```xml
<!-- ios/Runner/Info.plist -->
<key>NSDocumentsFolderUsageDescription</key>
<string>Esta aplicación necesita acceso para importar música local</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>Esta aplicación necesita acceso para importar música local</string>
```

#### Integración Nativa de iPod Library

**Nueva funcionalidad**: Soporte completo para URLs `ipod-library://` usando MPMusicPlayerController nativo de iOS.

##### Arquitectura Dual de Reproducción
```dart
// PlayerRepositoryImpl - Sistema dual iOS
@override
Future<bool> play(String url) async {
  if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
    // Verificar protección DRM
    final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
    if (isDrmProtected) return false;
    
    // Usar reproductor nativo iOS para URLs iPod library
    final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
    if (success) _usingNativePlayer = true;
    return success;
  } else {
    // Usar AudioPlayers para archivos regulares
    await player.play(DeviceFileSource(url));
    return isPlaying();
  }
}
```

##### Funcionalidades del Reproductor Nativo
- **✅ Reproducir/pausar/parar** URLs iPod library
- **✅ Control de posición** (seek) con `MPMusicPlayerController.currentPlaybackTime`
- **✅ Posición actual** en tiempo real
- **✅ Duración total** de la canción
- **✅ Estados de reproducción** (playing/paused/stopped/interrupted/seeking)
- **✅ Verificación DRM** automática
- **✅ Reanudar después de pausa**
- **✅ Control de velocidad** (0.5x-2.0x) con `MPMusicPlayerController.currentPlaybackRate`

##### Method Channels Implementados
```swift
// AppDelegate.swift - Métodos nativos iOS
case "playWithMusicPlayer":     // Iniciar reproducción
case "pauseMusicPlayer":        // Pausar
case "resumeMusicPlayer":       // Reanudar
case "stopMusicPlayer":         // Detener
case "getMusicPlayerStatus":    // Estado actual
case "getCurrentPosition":      // Posición en segundos
case "getDuration":            // Duración total
case "seekToPosition":         // Cambiar posición
case "checkDrmProtection":     // Verificar DRM
case "setPlaybackSpeed":       // Control de velocidad
case "getPlaybackSpeed":       // Obtener velocidad actual
```

##### Permisos Adicionales iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppleMusicUsageDescription</key>
<string>Esta aplicación necesita acceso a tu biblioteca de música para reproducir canciones</string>
```

#### Dependencias iOS
- **on_audio_query_pluse**: Acceso a biblioteca nativa
- **file_picker**: Selección de carpetas
- **Mp3FileConverter**: Conversión y estimación de metadatos
- **MPMusicPlayerController**: Reproductor nativo para iPod library (iOS nativo)
- **IpodLibraryConverter**: Interfaz Flutter-iOS para Method Channels

## 🤖 Funcionalidades Android

### Acceso a Música

#### Fuente Única
**Solo on_audio_query_pluse** para acceso completo y automático a:
- Música de cualquier app (Spotify downloads, YouTube Music, etc.)
- Archivos MP3 en almacenamiento interno/externo
- Música en SD cards
- Archivos descargados de cualquier fuente

#### Implementación Técnica

```dart
// SongsRepositoryImpl - Android
@override
Future<String?> selectMusicFolder() async {
  if (Platform.isIOS) {
    // Lógica de iOS
  }
  // Android no soporta selección manual, retorna null
  return null;
}

@override
Future<List<File>> getSongsFromFolder(String folderPath) async {
  if (Platform.isIOS) {
    // Lógica de iOS
  }
  // Android no soporta escaneo de carpetas específicas, retorna lista vacía
  return [];
}

// Solo este método es funcional en Android
@override
Future<List<SongModel>> getSongsFromDevice() async {
  final bool canContinue = await _configureAudioQuery();
  return !canContinue ? [] : _audioQuery.querySongs();
}
```

#### Flujo de Usuario Android

1. **Acceso automático**
   - App se abre y solicita permisos de música
   - Escanea automáticamente toda la música del dispositivo
   - No requiere configuración manual

2. **Sin configuración**
   - No aparece sección "Música Local" en configuraciones
   - Experiencia simplificada
   - Todo automático y transparente

3. **Biblioteca completa**
   - Toda la música disponible automáticamente
   - Sin distinción entre fuentes
   - Acceso universal a archivos MP3

#### Permisos Android

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- Android 12 o inferior -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Android 13 o superior -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

#### Manejo de URLs iPod Library en Android

**Comportamiento**: Android no soporta URLs `ipod-library://` ya que son exclusivas del ecosistema Apple.

```dart
// PlayerRepositoryImpl - Comportamiento en Android
@override
Future<bool> play(String url) async {
  if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
    // Lógica iOS para iPod library
  } else {
    // Android siempre usa AudioPlayers, incluso para URLs iPod library
    // En Android, las URLs iPod library se tratarán como archivos regulares
    await player.play(DeviceFileSource(url));
    return isPlaying();
  }
}
```

**Resultado**: Las URLs `ipod-library://` en Android se pasan directamente a AudioPlayers, que las rechazará gracefully sin causar errores en la aplicación.

#### Dependencias Android
- **on_audio_query_pluse**: Único método de acceso a música
- ~~file_picker~~: No utilizado
- ~~Mp3FileConverter~~: No necesario (metadatos vienen de on_audio_query)
- ~~MPMusicPlayerController~~: No disponible en Android
- **IpodLibraryConverter**: Retorna `false` para todos los métodos (verificación de plataforma)

## 🔧 Implementación de la Lógica Condicional

### Use Cases Condicionales

```dart
class GetLocalSongsUseCase {
  Future<List<SongModel>> call() async {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (Platform.isAndroid) {
      return []; // Android no tiene canciones "locales" separadas
    }

    // Lógica específica de iOS
    try {
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;
      
      if (localPath == null || localPath.isEmpty) {
        return [];
      }
      
      final files = await _songsRepository.getSongsFromFolder(localPath);
      return Mp3FileConverter.convertFilesToSongModels(files);
    } catch (e) {
      return [];
    }
  }
}
```

### BLoC Condicional

```dart
class SongsCubit extends Cubit<SongsState> {
  final GetLocalSongsUseCase? _getLocalSongsUseCase; // Opcional

  Future<void> loadAllSongs() async {
    final deviceSongs = await _songsRepository.getSongsFromDevice();
    
    if (Platform.isIOS && _getLocalSongsUseCase != null) {
      // iOS: combinar canciones del dispositivo + locales
      final localSongs = await _getLocalSongsUseCase();
      final allSongs = [...deviceSongs, ...localSongs];
    } else {
      // Android: solo canciones del dispositivo
      final allSongs = deviceSongs;
    }
  }
}
```

### Inyección de Dependencias Condicional

```dart
// main.dart
Future<void> main() async {
  final songsRepository = SongsRepositoryImpl();
  final settingsRepository = SettingsRepositoryImpl();

  // Use Cases solo para iOS
  GetLocalSongsUseCase? getLocalSongsUseCase;
  SelectMusicFolderUseCase? selectMusicFolderUseCase;
  GetSongsFromFolderUseCase? getSongsFromFolderUseCase;

  if (Platform.isIOS) {
    getLocalSongsUseCase = GetLocalSongsUseCase(songsRepository, settingsRepository);
    selectMusicFolderUseCase = SelectMusicFolderUseCase(songsRepository);
    getSongsFromFolderUseCase = GetSongsFromFolderUseCase(songsRepository);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SongsCubit>(
          create: (context) => SongsCubit(songsRepository, getLocalSongsUseCase),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
            settingsRepository,
            selectMusicFolderUseCase,
            getSongsFromFolderUseCase,
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}
```

## 📱 Experiencia de Usuario Comparada

### 🍎 iOS: Flexibilidad Máxima

| Aspecto | Experiencia |
|---------|-------------|
| **Configuración** | Sección "Música Local" visible |
| **Selección** | Picker nativo para carpetas |
| **Fuentes** | Dispositivo + carpetas seleccionadas |
| **Control** | Usuario controla qué carpetas incluir |
| **Flexibilidad** | Alta - puede añadir/quitar fuentes |

#### Flujo Típico iOS
1. Usuario abre app → ve música del dispositivo
2. Va a configuraciones → selecciona carpeta adicional
3. App escanea → combina ambas fuentes
4. Biblioteca actualizada con música combinada

### 🤖 Android: Simplicidad Máxima

| Aspecto | Experiencia |
|---------|-------------|
| **Configuración** | Sin configuraciones adicionales |
| **Selección** | Automática, sin intervención |
| **Fuentes** | Solo dispositivo (pero completo) |
| **Control** | Sistema operativo maneja acceso |
| **Flexibilidad** | Ninguna - todo automático |

#### Flujo Típico Android
1. Usuario abre app → solicita permisos
2. Usuario acepta → acceso a toda la música
3. Biblioteca completa disponible inmediatamente

## 🧪 Testing por Plataforma

### iOS Testing
```dart
group('iOS Local Music Tests', () {
  test('should return songs from selected folder', () async {
    // Arrange
    when(() => Platform.isIOS).thenReturn(true);
    
    // Act & Assert
    final songs = await getLocalSongsUseCase();
    expect(songs, isNotEmpty);
  });
});
```

### Android Testing
```dart
group('Android Music Tests', () {
  test('should return empty list for local songs', () async {
    // Arrange
    when(() => Platform.isAndroid).thenReturn(true);
    
    // Act & Assert
    final localSongs = await getLocalSongsUseCase();
    expect(localSongs, isEmpty);
  });
  
  test('should get all music from device', () async {
    // Act & Assert
    final deviceSongs = await songsRepository.getSongsFromDevice();
    expect(deviceSongs, isNotEmpty);
  });
});
```

## 🔮 Extensiones Futuras

### Potenciales Mejoras iOS
- **Sincronización automática**: Detectar cambios en carpetas seleccionadas
- **Múltiples carpetas**: Seleccionar varias carpetas simultáneamente
- **Filtros avanzados**: Por tipo de archivo, fecha, tamaño
- **iCloud integration**: Mejor soporte para archivos en la nube

### Potenciales Mejoras Android
- **Mantener simplicidad**: Evitar complejidad innecesaria
- **Optimización de permisos**: Mejor gestión de Scoped Storage
- **Caché inteligente**: Optimizar queries de on_audio_query_pluse
- **Metadata mejorada**: Mejor extracción de información

## 📊 Tabla Comparativa Completa

| Funcionalidad | iOS | Android |
|---------------|-----|---------|
| **on_audio_query_pluse** | ✅ Música del dispositivo | ✅ Toda la música |
| **FilePicker** | ✅ Selección manual | ❌ No soportado |
| **Carpetas específicas** | ✅ Usuario selecciona | ❌ No necesario |
| **LocalMusicSection** | ✅ Visible en settings | ❌ Oculta |
| **Use Cases locales** | ✅ Funcionales | ❌ Retornan vacío |
| **URLs iPod Library** | ✅ Soporte nativo completo | ❌ Tratadas como archivos regulares |
| **MPMusicPlayerController** | ✅ Reproductor nativo | ❌ No disponible |
| **Method Channels** | ✅ 9 métodos implementados | ❌ Todos retornan false |
| **Verificación DRM** | ✅ Automática | ❌ No aplicable |
| **Control de posición** | ✅ Dual (AudioPlayers + nativo) | ✅ Solo AudioPlayers |
| **Arquitectura de reproducción** | 🔄 Dual (nativo + AudioPlayers) | 📱 Única (AudioPlayers) |
| **Complejidad UX** | Media (más opciones) | Baja (automático) |
| **Flexibilidad** | Alta | Baja |
| **Simplicidad** | Media | Alta |
| **Dependencias** | Múltiples | Mínimas |

### 🆕 Nuevas Capacidades v3.0.0 - iPod Library Integration

| Característica | iOS | Android | Notas |
|----------------|-----|---------|-------|
| **URLs `ipod-library://`** | ✅ Nativo | ⚠️ Fallback | iOS usa MPMusicPlayerController, Android usa AudioPlayers |
| **Control de slider** | ✅ Tiempo real | ✅ AudioPlayers | Posición actualizada correctamente |
| **Pausa/reanudar** | ✅ Nativo | ✅ AudioPlayers | Funcionalidad completa en ambas plataformas |
| **Seek/posición** | ✅ Nativo | ✅ AudioPlayers | Control preciso de posición |
| **DRM protection** | ✅ Verificación | ❌ N/A | Solo relevante para biblioteca iOS |

### 🆕 Nuevas Capacidades v3.3.0 - Control de Velocidad Nativo

| Característica | iOS | Android | Notas |
|----------------|-----|---------|-------|
| **Control de velocidad** | ✅ Nativo + AudioPlayers | ✅ AudioPlayers | iOS soporta ambos reproductores |
| **Rango de velocidad** | ✅ 0.5x-2.0x | ✅ 0.5x-2.0x | Mismo rango en ambas plataformas |
| **Persistencia** | ✅ SharedPreferences | ✅ SharedPreferences | Configuración guardada automáticamente |
| **Switching automático** | ✅ Dual player | ✅ AudioPlayers único | iOS detecta reproductor activo |
| **Method Channels** | ✅ setPlaybackSpeed/getPlaybackSpeed | ❌ N/A | Solo relevante para reproductor nativo |

Esta implementación híbrida aprovecha las fortalezas de cada plataforma mientras mantiene la arquitectura limpia y el código mantenible. La nueva integración de iPod Library en iOS proporciona soporte nativo completo para la biblioteca de música del dispositivo, y ahora incluye control total de velocidad de reproducción, manteniendo la simplicidad en Android.