# Sistema de Reproducción - Player System

## Descripción General

El sistema de reproducción de Sonofy maneja la reproducción de música con funcionalidades avanzadas de shuffle, repetición y navegación inteligente. Está construido usando BLoC pattern para manejo de estado y Clean Architecture.

## Arquitectura del Sistema

### Componentes Principales

```
Player System
├── PlayerCubit (Estado y lógica)
├── PlayerState (Modelo de estado)
├── PlayerRepository (Interfaz de datos)
├── PlayerScreen (UI principal)
└── Widgets especializados
    ├── PlayerControl (Controles de reproducción)
    ├── PlayerSlider (Barra de progreso)
    └── PlaylistModal (Cola de reproducción)
```

## PlayerState - Manejo de Estado

### Estructura de Estado

El `PlayerState` maneja dos listas de reproducción separadas:

- **`_playlist`**: Lista original de canciones en orden normal
- **`_shufflePlaylist`**: Lista mezclada aleatoriamente
- **`activePlaylist`**: Getter que devuelve la lista apropiada según `isShuffleEnabled`

### Propiedades del Estado

```dart
class PlayerState {
  final List<SongModel> _playlist;           // Lista original
  final List<SongModel> _shufflePlaylist;    // Lista shuffle
  final int currentIndex;                    // Índice en lista activa
  final bool isPlaying;                      // Estado de reproducción
  final bool isShuffleEnabled;               // Shuffle activado/desactivado
  final RepeatMode repeatMode;               // Modo de repetición
  final double playbackSpeed;                // Velocidad de reproducción
  // ... otras propiedades para sleep timer
}
```

### Modos de Repetición

```dart
enum RepeatMode {
  none,  // Reproduce secuencialmente, se detiene al final
  one,   // Repite la canción actual indefinidamente
  all,   // Repite toda la playlist indefinidamente
}
```

## PlayerCubit - Lógica de Negocio

### Métodos Principales

#### `setPlayingSong(playlist, song, shuffledPlaylist?)`
Establece una nueva canción y playlist para reproducir.
- Regenera lista shuffle con canción seleccionada como primera
- Opcionalmente preserva lista shuffle existente

#### `toggleShuffle()`
Alterna modo shuffle con lógica inteligente:
- **Al activar**: Genera nueva lista con canción actual al inicio (índice 0)
- **Al desactivar**: Vuelve a playlist original, recalcula índice

#### `toggleRepeat()`
Cicla entre modos: `none → one → all → none`

#### `nextSong()` / `previousSong()`
Navegación con comportamiento según RepeatMode:
- **RepeatMode.one**: Mantiene canción actual
- **RepeatMode.all/none**: Avanza/retrocede según lógica de navegación

### Auto-advance Inteligente

El sistema maneja automáticamente el avance al final de cada canción:

```dart
// En _startPositionUpdates()
if (isNearEnd && state.hasSelectedSong) {
  if (state.repeatMode == RepeatMode.one) {
    await _playerRepository.seek(Duration.zero);  // Repetir canción
  } else if (state.repeatMode == RepeatMode.all) {
    await nextSong();  // Continuar con siguiente
  } else if (state.repeatMode == RepeatMode.none) {
    if (state.currentIndex < state.activePlaylist.length - 1) {
      await nextSong();  // Avanzar si no es la última
    } else {
      // Es la última canción: volver al inicio pausado
      await _playerRepository.pause();
      emit(state.copyWith(currentIndex: 0, isPlaying: false));
    }
  }
}
```

## Shuffle Inteligente

### Características

1. **Canción actual al inicio**: Al activar shuffle, la canción reproduciéndose se coloca como primera
2. **Preservación de secuencia**: PlaylistModal preserva lista shuffle existente
3. **Regeneración selectiva**: Solo regenera cuando es necesario

### Implementación

```dart
List<SongModel> _generateShufflePlaylist(List<SongModel> playlist, [SongModel? currentSong]) {
  if (playlist.isEmpty) return [];
  
  final shuffled = List.of(playlist);
  shuffled.shuffle();
  
  // Mover canción actual al inicio si se proporciona
  if (currentSong != null) {
    final currentIndex = shuffled.indexWhere((s) => s.id == currentSong.id);
    if (currentIndex != -1) {
      final current = shuffled.removeAt(currentIndex);
      shuffled.insert(0, current);
    }
  }
  
  return shuffled;
}
```

## PlaylistModal - Cola de Reproducción

### Funcionalidades

- **Vista adaptativa**: Muestra canciones según RepeatMode
- **Auto-scroll**: Se reposiciona automáticamente a canción actual
- **Preservación de shuffle**: Usa método especializado para no regenerar listas

### Lógica de Visualización

```dart
List<SongModel> _getDisplayedSongs(PlayerState state) {
  switch (state.repeatMode) {
    case RepeatMode.one:
      return [activePlaylist[state.currentIndex]];  // Solo canción actual
    
    case RepeatMode.none:
      return activePlaylist.sublist(state.currentIndex);  // Desde actual hasta final
    
    case RepeatMode.all:
      // Toda la playlist con canción actual al inicio
      final reorderedPlaylist = <SongModel>[];
      for (int i = 0; i < activePlaylist.length; i++) {
        final songIndex = (i + state.currentIndex) % activePlaylist.length;
        reorderedPlaylist.add(activePlaylist[songIndex]);
      }
      return reorderedPlaylist;
  }
}
```

## Preservación de Estado

### PlayerPreferences

Las preferencias del usuario se persisten automáticamente:

```dart
class PlayerPreferences {
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
}
```

### Restauración al Inicializar

```dart
PlayerState.initial()
  : isShuffleEnabled = Preferences.playerPreferences.isShuffleEnabled,
    repeatMode = Preferences.playerPreferences.repeatMode,
    // ... otros valores iniciales
```

## Casos de Uso Principales

### 1. Reproducir Nueva Playlist
```dart
// Desde cualquier contexto (regenera shuffle)
playerCubit.setPlayingSong(playlist, song);

// Desde PlaylistModal (preserva shuffle)
playerCubit.setPlayingSong(playlist, song, existingShufflePlaylist);
```

### 2. Activar Shuffle
```dart
// La canción actual se convierte en la primera de la nueva secuencia
playerCubit.toggleShuffle();
```

### 3. Cambiar Modo de Repetición
```dart
// Cicla entre los tres modos
playerCubit.toggleRepeat();
```

## Integración con UI

### PlayerControl
Muestra controles con estados visuales apropiados:
- Íconos de repeat según modo actual
- Ícono de shuffle con indicador de estado
- Botones de navegación (anterior/siguiente)

### PlayerScreen
Pantalla principal que integra todos los componentes:
- PlayerSlider para progreso de canción
- PlayerControl para controles
- PlayerBottomModals para modales adicionales

## Consideraciones de Rendimiento

1. **Lazy Loading**: Las listas shuffle se generan solo cuando es necesario
2. **Streaming de Posición**: Actualización eficiente de progreso cada 500ms
3. **Preservación de Estado**: Evita regeneraciones innecesarias de listas
4. **Auto-scroll Optimizado**: Animaciones suaves con callbacks apropiados

## Testing y Mantenimiento

### Puntos Críticos para Testing
- Transiciones entre modos de repetición
- Generación correcta de listas shuffle
- Preservación de estado en navegación
- Auto-advance al final de canciones
- Sincronización de índices entre listas

### Métricas de Calidad
- Tiempo de respuesta en cambios de canción
- Consistencia de estado entre sesiones
- Fluidez de animaciones en UI
- Precisión de posicionamiento en listas

## Extensibilidad Futura

El sistema está diseñado para soportar:
- Múltiples colas de reproducción
- Algoritmos de shuffle personalizados
- Modos de repetición adicionales
- Integración con servicios de streaming
- Análisis de patrones de escucha