# Player API Reference

## PlayerCubit

### Descripción
Cubit que maneja el estado del reproductor de música con funcionalidades avanzadas de shuffle, repetición y navegación.

### Constructor

```dart
PlayerCubit(PlayerRepository playerRepository, SettingsRepository settingsRepository)
```

**Parámetros:**
- `playerRepository`: Repositorio para operaciones de reproducción
- `settingsRepository`: Repositorio para configuraciones del usuario

### Métodos Públicos

#### `setPlayingSong`

```dart
Future<void> setPlayingSong(
  List<SongModel> playlist,
  SongModel song,
  List<SongModel>? shuffledPlaylist,
)
```

Establece una nueva canción y playlist para reproducir.

**Parámetros:**
- `playlist`: Lista original de canciones
- `song`: Canción a reproducir
- `shuffledPlaylist`: Lista shuffle existente (opcional, para preservar secuencia)

**Comportamiento:**
- Regenera nueva lista shuffle si no se proporciona una existente
- Coloca la canción seleccionada como primera en shuffle
- Actualiza currentIndex según el modo activo (shuffle/normal)

**Ejemplo:**
```dart
// Reproducir nueva playlist (regenera shuffle)
await playerCubit.setPlayingSong(playlist, selectedSong);

// Preservar shuffle existente
await playerCubit.setPlayingSong(playlist, selectedSong, existingShuffleList);
```

#### `nextSong`

```dart
Future<void> nextSong()
```

Avanza a la siguiente canción en la lista activa.

**Comportamiento por RepeatMode:**
- `RepeatMode.one`: Mantiene la canción actual
- `RepeatMode.all/none`: Avanza según lógica de navegación

**Ejemplo:**
```dart
await playerCubit.nextSong();
```

#### `previousSong`

```dart
Future<void> previousSong()
```

Retrocede a la canción anterior en la lista activa.

**Comportamiento por RepeatMode:**
- `RepeatMode.one`: Mantiene la canción actual
- `RepeatMode.all/none`: Retrocede según lógica de navegación

**Ejemplo:**
```dart
await playerCubit.previousSong();
```

#### `togglePlayPause`

```dart
Future<void> togglePlayPause()
```

Alterna entre reproducción y pausa.

**Ejemplo:**
```dart
await playerCubit.togglePlayPause();
```

#### `seekTo`

```dart
Future<void> seekTo(Duration position)
```

Busca una posición específica en la canción actual.

**Parámetros:**
- `position`: Posición objetivo en la canción

**Ejemplo:**
```dart
await playerCubit.seekTo(Duration(seconds: 30));
```

#### `toggleShuffle`

```dart
void toggleShuffle()
```

Alterna entre modo shuffle activado/desactivado.

**Comportamiento al activar:**
- Genera nueva lista aleatoria con canción actual como primera
- Establece currentIndex = 0

**Comportamiento al desactivar:**
- Vuelve a usar playlist original
- Recalcula currentIndex según posición en lista original

**Ejemplo:**
```dart
playerCubit.toggleShuffle();
```

#### `toggleRepeat`

```dart
void toggleRepeat()
```

Alterna entre los modos de repetición en ciclo: none → one → all → none.

**Modos de repetición:**
- `RepeatMode.none`: Reproduce secuencialmente, se detiene al final
- `RepeatMode.one`: Repite la canción actual indefinidamente
- `RepeatMode.all`: Repite toda la playlist indefinidamente

**Ejemplo:**
```dart
playerCubit.toggleRepeat();
```

#### `getCurrentSongPosition`

```dart
Stream<int> getCurrentSongPosition()
```

Retorna un stream con la posición actual de la canción en milisegundos.

**Retorna:** Stream que emite la posición cada 500ms durante reproducción

**Ejemplo:**
```dart
playerCubit.getCurrentSongPosition().listen((position) {
  print('Posición actual: ${position}ms');
});
```

#### `setPlaybackSpeed`

```dart
Future<bool> setPlaybackSpeed(double speed)
```

Establece la velocidad de reproducción.

**Parámetros:**
- `speed`: Velocidad de reproducción (1.0 = normal, 0.5 = mitad, 2.0 = doble)

**Retorna:** `true` si se aplicó correctamente, `false` si falló

**Ejemplo:**
```dart
bool success = await playerCubit.setPlaybackSpeed(1.5);
```

#### `getPlaybackSpeed`

```dart
double getPlaybackSpeed()
```

Obtiene la velocidad de reproducción actual.

**Retorna:** Velocidad actual de reproducción

**Ejemplo:**
```dart
double currentSpeed = playerCubit.getPlaybackSpeed();
```

### Sleep Timer Methods

#### `startSleepTimer`

```dart
void startSleepTimer(Duration duration, bool waitForSong)
```

Inicia el temporizador de sueño.

**Parámetros:**
- `duration`: Duración del temporizador
- `waitForSong`: Si debe esperar a que termine la canción actual

**Ejemplo:**
```dart
playerCubit.startSleepTimer(Duration(minutes: 30), true);
```

#### `stopSleepTimer`

```dart
void stopSleepTimer()
```

Detiene el temporizador de sueño.

**Ejemplo:**
```dart
playerCubit.stopSleepTimer();
```

### Queue Management Methods

#### `insertSongNext`

```dart
void insertSongNext(SongModel song)
```

Inserta una canción como la siguiente a reproducir.

**Parámetros:**
- `song`: Canción a insertar

**Ejemplo:**
```dart
playerCubit.insertSongNext(selectedSong);
```

#### `addToQueue`

```dart
void addToQueue(SongModel song)
```

Añade una canción al final de la cola.

**Parámetros:**
- `song`: Canción a añadir

**Ejemplo:**
```dart
playerCubit.addToQueue(selectedSong);
```

#### `removeFromQueue`

```dart
void removeFromQueue(SongModel song)
```

Remueve una canción de la cola.

**Parámetros:**
- `song`: Canción a remover

**Ejemplo:**
```dart
playerCubit.removeFromQueue(selectedSong);
```

## PlayerState

### Descripción
Estado inmutable que representa el estado actual del reproductor.

### Propiedades

#### Core Properties

```dart
List<SongModel> get playlist             // Lista original (solo lectura)
List<SongModel> get shufflePlaylist      // Lista shuffle (solo lectura)
List<SongModel> get activePlaylist       // Lista activa según shuffle
int currentIndex                         // Índice en lista activa
bool isPlaying                          // Estado de reproducción
bool isShuffleEnabled                   // Shuffle activado/desactivado
RepeatMode repeatMode                   // Modo de repetición actual
```

#### Computed Properties

```dart
bool get hasSelectedSong                // Si hay canción válida seleccionada
SongModel? get currentSong              // Canción actual en lista activa
```

#### Playback Properties

```dart
double playbackSpeed                    // Velocidad de reproducción (1.0 = normal)
```

#### Sleep Timer Properties

```dart
bool isSleepTimerActive                 // Si sleep timer está activo
bool waitForSongToFinish               // Si espera fin de canción
Duration? sleepTimerDuration           // Duración total del timer
Duration? sleepTimerRemaining          // Tiempo restante
```

### Constructor

```dart
PlayerState({
  required List<SongModel> playlist,
  required int currentIndex,
  required bool isPlaying,
  required bool isShuffleEnabled,
  required RepeatMode repeatMode,
  required bool isSleepTimerActive,
  required bool waitForSongToFinish,
  required double playbackSpeed,
  List<SongModel>? shufflePlaylist,
  Duration? sleepTimerDuration,
  Duration? sleepTimerRemaining,
})
```

### Factory Constructor

```dart
PlayerState.initial()
```

Crea un estado inicial con valores por defecto y preferencias guardadas.

### Métodos

#### `copyWith`

```dart
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
})
```

Crea una copia del estado con valores actualizados.

## RepeatMode Enum

```dart
enum RepeatMode {
  none,  // Reproduce secuencialmente, se detiene al final
  one,   // Repite la canción actual indefinidamente
  all,   // Repite toda la playlist indefinidamente
}
```

## Usage Examples

### Ejemplo Básico de Reproducción

```dart
class MusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(state.currentSong?.title ?? 'No song'),
            IconButton(
              onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
              icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              onPressed: () => context.read<PlayerCubit>().toggleShuffle(),
              icon: Icon(
                Icons.shuffle,
                color: state.isShuffleEnabled ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Ejemplo de Control de Velocidad

```dart
class SpeedControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return Row(
          children: [
            Text('Speed: ${state.playbackSpeed}x'),
            Slider(
              value: state.playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: (speed) {
                context.read<PlayerCubit>().setPlaybackSpeed(speed);
              },
            ),
          ],
        );
      },
    );
  }
}
```

### Ejemplo de Sleep Timer

```dart
class SleepTimerControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.isSleepTimerActive) {
          return Column(
            children: [
              Text('Sleep Timer: ${state.sleepTimerRemaining?.inMinutes ?? 0} min'),
              ElevatedButton(
                onPressed: () => context.read<PlayerCubit>().stopSleepTimer(),
                child: Text('Cancel Timer'),
              ),
            ],
          );
        }
        
        return ElevatedButton(
          onPressed: () {
            context.read<PlayerCubit>().startSleepTimer(
              Duration(minutes: 30),
              true, // Wait for song to finish
            );
          },
          child: Text('Set Sleep Timer (30 min)'),
        );
      },
    );
  }
}
```

## Error Handling

### Estados de Error Comunes

1. **Playlist vacía**: Métodos de navegación retornan sin acción
2. **Canción no encontrada**: Índices se validan antes de uso
3. **Reproducción fallida**: Estados se revierten automáticamente

### Validaciones Internas

```dart
// Ejemplo de validación interna
Future<void> nextSong() async {
  if (state.activePlaylist.isEmpty) return; // Validación temprana
  
  // Lógica de navegación...
}
```

## Performance Considerations

### Optimizaciones Implementadas

1. **Streams Eficientes**: Posición se actualiza cada 500ms solo durante reproducción
2. **Listas Lazy**: Shuffle se genera solo cuando es necesario
3. **Estado Inmutable**: Usa `copyWith` para actualizaciones eficientes
4. **Validaciones Tempranas**: Evita operaciones innecesarias

### Mejores Prácticas

1. **Use BlocBuilder**: Para rebuilds eficientes de UI
2. **Dispose Streams**: Automáticamente manejado por el Cubit
3. **Batch Updates**: Agrupe múltiples cambios en un solo `emit`