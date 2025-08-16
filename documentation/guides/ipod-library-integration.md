# Integración iPod Library - Documentación Técnica

## 📖 Visión General

La integración iPod Library permite a Sonofy reproducir directamente música de la biblioteca nativa de iOS usando URLs `ipod-library://` a través del reproductor nativo `MPMusicPlayerController`.

## 🎯 Objetivos de la Implementación

### Problema Original
- **AudioPlayers** no es compatible con URLs `ipod-library://item/item.movpkg?id=`
- Los archivos `.movpkg` son contenedores especiales de Apple que no se pueden exportar
- AVAssetExportSession falló para convertir estos archivos

### Solución Implementada
- **Reproductor dual**: MPMusicPlayerController para iPod Library + AudioPlayers para archivos regulares
- **Method Channels** para comunicación Flutter ↔ iOS nativo
- **Detección automática** del tipo de archivo
- **Verificación DRM** para archivos protegidos

## 🏗️ Arquitectura Técnica

### Diagrama de Flujo

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Flutter UI    │───▶│ PlayerRepository │───▶│ IpodLibraryConverter│
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                                          │
                                                          ▼
                        ┌──────────────────┐    ┌─────────────────────┐
                        │   AudioPlayers   │    │   Method Channel    │
                        │   (.mp3 files)   │    │  (ipod-library://)  │
                        └──────────────────┘    └─────────────────────┘
                                                          │
                                                          ▼
                                                ┌─────────────────────┐
                                                │   AppDelegate.swift │
                                                │ MPMusicPlayerController│
                                                └─────────────────────┘
```

### Componentes Principales

#### 1. PlayerRepositoryImpl
**Ubicación**: `lib/data/repositories/player_repository_impl.dart`

```dart
final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;

  @override
  Future<bool> play(String url) async {
    if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
      // Usar reproductor nativo iOS
      final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
      if (success) _usingNativePlayer = true;
      return success;
    } else {
      // Usar AudioPlayers
      await player.play(DeviceFileSource(url));
      return isPlaying();
    }
  }
}
```

#### 2. IpodLibraryConverter
**Ubicación**: `lib/core/utils/ipod_library_converter.dart`

```dart
class IpodLibraryConverter {
  static const MethodChannel _channel = MethodChannel('ipod_library_converter');
  
  static bool isIpodLibraryUrl(String url) {
    return url.startsWith('ipod-library://');
  }
  
  static Future<bool> playWithNativeMusicPlayer(String ipodUrl) async {
    if (!Platform.isIOS) return false;
    
    final songId = _extractSongIdFromUrl(ipodUrl);
    final result = await _channel.invokeMethod('playWithMusicPlayer', {
      'songId': songId,
    });
    return result as bool? ?? false;
  }
}
```

#### 3. AppDelegate.swift
**Ubicación**: `ios/Runner/AppDelegate.swift`

```swift
@main
@objc class AppDelegate: FlutterAppDelegate {
  private var musicPlayer: MPMusicPlayerController?
  
  private func playWithMusicPlayer(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let songId = extractSongId(from: call) else {
      result(false)
      return
    }
    
    let player = MPMusicPlayerController.applicationMusicPlayer
    let query = MPMediaQuery.songs()
    let predicate = MPMediaPropertyPredicate(value: NSNumber(value: songId), 
                                           forProperty: MPMediaItemPropertyPersistentID)
    query.addFilterPredicate(predicate)
    
    guard let mediaItems = query.items, !mediaItems.isEmpty else {
      result(false)
      return
    }
    
    let collection = MPMediaItemCollection(items: mediaItems)
    player.setQueue(with: collection)
    player.play()
    result(true)
  }
}
```

## 🔧 Method Channels Implementados

### Flutter → iOS

| Método | Parámetros | Retorno | Descripción |
|--------|-----------|---------|-------------|
| `playWithMusicPlayer` | `songId: String` | `bool` | Inicia reproducción |
| `pauseMusicPlayer` | - | `bool` | Pausa reproducción |
| `resumeMusicPlayer` | - | `bool` | Reanuda reproducción |
| `stopMusicPlayer` | - | `bool` | Detiene reproducción |
| `getMusicPlayerStatus` | - | `String` | Estado actual |
| `getCurrentPosition` | - | `double` | Posición en segundos |
| `getDuration` | - | `double` | Duración en segundos |
| `seekToPosition` | `position: double` | `bool` | Cambiar posición |
| `checkDrmProtection` | `songId: String` | `bool` | Verificar DRM |

### iOS → Flutter (Logging)

| Método | Parámetros | Descripción |
|--------|-----------|-------------|
| `logFromIOS` | `message: String` | Envía logs de iOS a Flutter Console |

## 🔒 Verificación DRM

### Funcionalidad
La verificación DRM previene intentos de reproducción de archivos protegidos que causarían errores.

### Implementación iOS
```swift
private func checkDrmProtection(call: FlutterMethodCall, result: @escaping FlutterResult) {
  guard let mediaItem = findMediaItem(songId: songId) else {
    result(true) // Assume protected if not found
    return
  }
  
  let isProtected = mediaItem.value(forProperty: MPMediaItemPropertyHasProtectedAsset) as? Bool ?? false
  let hasAssetUrl = mediaItem.assetURL != nil
  
  result(isProtected || !hasAssetUrl)
}
```

### Uso en Flutter
```dart
final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
if (isDrmProtected) {
  // No intentar reproducir, mostrar mensaje de error
  return false;
}
```

## 📱 Manejo de Estados

### Estados del Reproductor

| Estado iOS | Estado Flutter | Comportamiento |
|------------|----------------|----------------|
| `playing` | `true` | Reproduciendo normalmente |
| `paused` | `false` | Pausado, puede reanudar |
| `stopped` | `false` | Detenido, reinicia desde inicio |
| `interrupted` | `false` | Interrumpido por llamada/notificación |
| `seeking` | `true` | Cambiando posición |

### Lógica de Switching
```dart
@override
bool isPlaying() {
  if (_usingNativePlayer && Platform.isIOS) {
    // Para reproductor nativo, asumir playing cuando activo
    // UI debe verificar estado con getNativeMusicPlayerStatus()
    return true;
  }
  return player.state == PlayerState.playing;
}
```

## 🎮 Controles Implementados

### Play/Pause/Resume
```dart
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
    }
  }
  // Fallback a AudioPlayers...
}
```

### Seek (Cambio de Posición)
```dart
@override
Future<bool> seek(Duration position) async {
  if (_usingNativePlayer && Platform.isIOS) {
    await IpodLibraryConverter.seekToPosition(position);
    await IpodLibraryConverter.resumeNativeMusicPlayer();
  } else {
    await player.seek(position);
    await player.resume();
  }
  return isPlaying();
}
```

### Posición y Duración
```dart
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
```

## 🛡️ Manejo de Errores

### Estrategias de Fallback

#### iOS
```dart
static Future<bool> playWithNativeMusicPlayer(String ipodUrl) async {
  if (!Platform.isIOS) return false;
  
  try {
    final songId = _extractSongIdFromUrl(ipodUrl);
    if (songId == null) return false;
    
    final result = await _channel.invokeMethod('playWithMusicPlayer', {
      'songId': songId,
    });
    return result as bool? ?? false;
  } catch (e) {
    // Log error pero no crash
    return false;
  }
}
```

#### Android
```dart
@override
Future<bool> play(String url) async {
  if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
    // Lógica iOS
  } else {
    // Android trata iPod URLs como archivos regulares
    // AudioPlayers manejará el error gracefully
    await player.play(DeviceFileSource(url));
    return isPlaying();
  }
}
```

## 🔄 Logging y Debugging

### Sistema de Logging
```swift
private func logToFlutter(_ message: String) {
  DispatchQueue.main.async {
    self.logChannel?.invokeMethod("logFromIOS", arguments: message)
  }
}
```

### Ejemplos de Logs
```
🍎 iOS: 📱 Method channel setup complete
🍎 iOS: 🎵 Starting MPMusicPlayerController playback
🍎 iOS: 🔍 Setting up music player for song ID: 5133594294061748202
🍎 iOS: ✅ Found 1 item(s), setting queue...
🍎 iOS: 🎵 Music player started!
🍎 iOS: ⏱️ Current position: 45.2 seconds
```

## 🧪 Testing

### Unit Tests
```dart
group('iPod Library Integration Tests', () {
  test('should detect iPod library URLs correctly', () {
    expect(IpodLibraryConverter.isIpodLibraryUrl('ipod-library://item/item.movpkg?id=123'), true);
    expect(IpodLibraryConverter.isIpodLibraryUrl('/path/to/file.mp3'), false);
  });

  test('should extract song ID from URL', () {
    const url = 'ipod-library://item/item.movpkg?id=5133594294061748202';
    final songId = IpodLibraryConverter._extractSongIdFromUrl(url);
    expect(songId, '5133594294061748202');
  });
});
```

### Integration Tests
```dart
testWidgets('should play iPod library file on iOS', (WidgetTester tester) async {
  // Arrange
  const ipodUrl = 'ipod-library://item/item.movpkg?id=123';
  
  // Act
  final success = await playerRepository.play(ipodUrl);
  
  // Assert
  expect(success, true);
  expect(playerRepository.isPlaying(), true);
});
```

## 🚀 Optimizaciones Futuras

### Funcionalidades Pendientes
1. **Metadatos nativos**: Título, artista, artwork desde MPMusicPlayerController
2. **Lock screen controls**: Integración con Control Center
3. **Notificaciones de reproducción**: Sistema nativo de iOS
4. **Cola de reproducción**: Múltiples canciones en queue
5. **Shuffle/repeat**: Modos nativos de reproducción

### Mejoras de Rendimiento
1. **Caché de verificación DRM**: Evitar verificaciones repetidas
2. **Pooling de Method Channels**: Reutilizar conexiones
3. **Lazy loading**: Inicializar MPMusicPlayerController solo cuando necesario

## 📋 Checklist de Implementación

### ✅ Completado
- [x] Method Channels bidireccionales
- [x] Reproducción básica (play/pause/stop)
- [x] Control de posición (seek)
- [x] Obtener posición actual
- [x] Obtener duración total
- [x] Verificación DRM
- [x] Estados de reproducción
- [x] Logging sistema
- [x] Manejo de errores
- [x] Compatibility Android
- [x] Documentación completa

### 🔄 En Progreso
- [ ] Tests de integración completos
- [ ] Optimización de rendimiento

### 📋 Pendiente
- [ ] Metadatos nativos (título, artista, artwork)
- [ ] Lock screen controls
- [ ] Notificaciones de reproducción
- [ ] Cola de reproducción múltiple
- [ ] Modos shuffle/repeat nativos

---

**Versión**: 3.0.0  
**Última Actualización**: Agosto 2024  
**Estado**: Implementación completa y funcional