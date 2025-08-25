# Sistema de Control de Velocidad de Reproducción

## 🎯 Descripción General

El sistema de control de velocidad de reproducción de Sonofy permite a los usuarios ajustar la velocidad de reproducción de audio entre 0.5x y 2.0x, con soporte nativo para iOS (MPMusicPlayerController) y multiplataforma para AudioPlayers.

## 🏗️ Arquitectura

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTACIÓN                           │
├─────────────────────────────────────────────────────────────┤
│ SpeedOption Widget → PlayerCubit → SettingsCubit          │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       DOMINIO                              │
├─────────────────────────────────────────────────────────────┤
│ PlayerRepository → SettingsRepository                     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                        DATOS                               │
├─────────────────────────────────────────────────────────────┤
│ PlayerRepositoryImpl → IpodLibraryConverter               │
│ SettingsRepositoryImpl → SharedPreferences                │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     PLATAFORMA                             │
├─────────────────────────────────────────────────────────────┤
│ iOS: MPMusicPlayerController.currentPlaybackRate          │
│ AudioPlayers: AudioPlayer.setPlaybackRate()               │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Funcionalidades

### Velocidades Disponibles
- **0.5x** - Reproducción lenta para contenido educativo
- **0.75x** - Velocidad reducida para mejor comprensión
- **1.0x** - Velocidad normal (predeterminada)
- **1.25x** - Aceleración ligera
- **1.5x** - Velocidad rápida
- **1.75x** - Aceleración alta
- **2.0x** - Velocidad máxima

### Soporte por Plataforma

| Característica | iOS (Nativo) | iOS/Android (AudioPlayers) |
|---|---|---|
| Control de Velocidad | ✅ | ✅ |
| Persistencia | ✅ | ✅ |
| Rango Completo | ✅ | ✅ |
| Switching Automático | ✅ | ✅ |

## 🔧 Implementación Técnica

### 1. Modelo de Datos

```dart
// lib/data/models/setting.dart
class Settings {
  final double playbackSpeed;
  
  Settings({
    this.playbackSpeed = 1.0,
    // otros campos...
  });
}
```

### 2. Repository Pattern

```dart
// lib/domain/repositories/player_repository.dart
abstract class PlayerRepository {
  Future<bool> setPlaybackSpeed(double speed);
  double getPlaybackSpeed();
}

// lib/data/repositories/player_repository_impl.dart
class PlayerRepositoryImpl implements PlayerRepository {
  @override
  Future<bool> setPlaybackSpeed(double speed) async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.setPlaybackSpeed(speed);
    } else {
      await player.setPlaybackRate(speed);
      return true;
    }
  }
}
```

### 3. Method Channel iOS

```swift
// ios/Runner/AppDelegate.swift
private func setPlaybackSpeed(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let player = musicPlayer,
          let args = call.arguments as? [String: Any],
          let speed = args["speed"] as? Double else {
        result(false)
        return
    }
    
    player.currentPlaybackRate = Float(speed)
    result(true)
}
```

### 4. State Management

```dart
// lib/presentation/blocs/player/player_cubit.dart
class PlayerCubit extends Cubit<PlayerState> {
  Future<bool> setPlaybackSpeed(double speed) async {
    final success = await _playerRepository.setPlaybackSpeed(speed);
    if (success) {
      emit(state.copyWith(playbackSpeed: speed));
    }
    return success;
  }
}
```

### 5. UI Components

```dart
// lib/presentation/widgets/options/speed_option.dart
class SpeedSelectorForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, playerState) {
        final currentSpeed = playerState.playbackSpeed;
        
        return ListView.builder(
          itemBuilder: (context, index) {
            final speed = speedOptions[index];
            final isCurrentSpeed = speed == currentSpeed;
            
            return ListTile(
              title: Text('${speed}x'),
              trailing: isCurrentSpeed ? Icon(Icons.check) : null,
              onTap: () async {
                await playerCubit.setPlaybackSpeed(speed);
                settingsCubit.updatePlaybackSpeed(speed);
              },
            );
          },
        );
      },
    );
  }
}
```

## 📱 Flujo de Usuario

### Cambiar Velocidad de Reproducción

1. **Acceso**: Usuario abre modal de opciones desde cualquier pantalla
2. **Selección**: Toca "Velocidad de reproducción" 
3. **Modal**: Se abre selector con 7 opciones de velocidad
4. **Selección**: Usuario selecciona nueva velocidad (ej: 1.5x)
5. **Aplicación**: Sistema aplica cambio inmediatamente
6. **Persistencia**: Configuración se guarda automáticamente
7. **Feedback**: Toast confirma el cambio

### Detección Automática de Reproductor

```dart
// El sistema detecta automáticamente qué reproductor usar:
if (_usingNativePlayer && Platform.isIOS) {
  // Usa MPMusicPlayerController para URLs iPod Library
  return IpodLibraryConverter.setPlaybackSpeed(speed);
} else {
  // Usa AudioPlayers para archivos locales
  await player.setPlaybackRate(speed);
}
```

## 🔍 Debugging y Logging

### iOS Swift Logging
```swift
logToFlutter("🚀 Setting speed to: \(speed)x")
player.currentPlaybackRate = Float(speed)
logToFlutter("✅ Playback speed set to \(speed)x")
```

### Flutter Dart Logging
```dart
try {
  final result = await _channel.invokeMethod('setPlaybackSpeed', {
    'speed': speed,
  });
  return result as bool? ?? false;
} catch (e) {
  // Log error
  return false;
}
```

## ⚠️ Limitaciones y Consideraciones

### Limitaciones Actuales
- **Reproductor Nativo iOS**: Funciona solo con canciones no protegidas por DRM
- **Rango de Velocidad**: Limitado a 0.5x - 2.0x por restricciones del reproductor
- **Android Native**: No tiene reproductor nativo, usa solo AudioPlayers

### Consideraciones de Performance
- **Memory**: Cambios de velocidad no afectan el uso de memoria
- **Battery**: Velocidades altas pueden consumir más batería
- **Quality**: Algoritmos internos mantienen calidad de audio

## 🧪 Testing

### Unit Tests
```dart
group('PlaybackSpeed', () {
  test('should set playback speed correctly', () async {
    final result = await playerRepository.setPlaybackSpeed(1.5);
    expect(result, true);
    expect(playerRepository.getPlaybackSpeed(), 1.5);
  });
});
```

### Integration Tests
```dart
group('SpeedOption Widget', () {
  testWidgets('should update speed when tapped', (tester) async {
    await tester.tap(find.text('1.5x'));
    await tester.pumpAndSettle();
    
    verify(mockPlayerCubit.setPlaybackSpeed(1.5)).called(1);
  });
});
```

## 🔮 Futuras Mejoras

### Características Planeadas
- **Velocidades Personalizadas**: Slider para velocidades exactas
- **Presets por Género**: Velocidades automáticas según tipo de música
- **Ajuste Dinámico**: Cambio de velocidad basado en contexto
- **Equalizer Integration**: Ajustes automáticos de ecualización por velocidad

### Mejoras Técnicas
- **Caching Inteligente**: Pre-carga para cambios de velocidad frecuentes
- **Background Processing**: Cambios de velocidad sin interrupciones
- **Analytics**: Tracking de preferencias de velocidad por usuario

---

## 📚 Referencias Técnicas

- [MPMusicPlayerController Documentation](https://developer.apple.com/documentation/mediaplayer/mpmusicplayercontroller)
- [AudioPlayers Plugin](https://pub.dev/packages/audioplayers)
- [Flutter Method Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

**Versión**: 3.3.0  
**Última Actualización**: Agosto 2024  
**Autor**: Equipo de Desarrollo Sonofy