# Sistema de Modales Contextual - OptionsModal

## 📋 Visión General

El sistema `OptionsModal` es una clase unificada que gestiona todos los modales contextuales en Sonofy. Proporciona opciones dinámicas según el contexto, mejorando la experiencia de usuario al mostrar solo las acciones relevantes para cada situación.

## 🎯 Características Principales

### ✅ Funcionalidades Core
- **Opciones Contextuales**: Solo muestra acciones relevantes según el contexto
- **Detección Inteligente**: Identifica automáticamente el estado de reproducción
- **Gestión de Cola**: Opciones específicas para gestión de lista de reproducción
- **Playlist Management**: Acciones contextuales para playlists específicas
- **Player Integration**: Integración inteligente con el estado del reproductor

### ✅ Beneficios Técnicos
- **UX Mejorada**: Usuario solo ve opciones aplicables
- **Código Limpio**: Lógica condicional centralizada
- **Mantenibilidad**: Fácil agregar nuevas opciones y contextos
- **Performance**: Menos widgets renderizados innecesariamente

## 📖 API de la Clase

```dart
class OptionsModal {
  BuildContext context;
  
  OptionsModal(this.context);
  
  // Métodos principales
  void library();                                    // Opciones de biblioteca
  void player();                                     // Opciones del reproductor
  void playlist();                                   // Opciones de playlist
  void songLibraryContext(song, playlist);          // Canción desde biblioteca
  void songPlaylistContext(song, playlist);         // Canción desde playlist
  void songPlayerListContext(song, playlist);       // Canción desde cola de reproducción
}
```

### Métodos Contextuales

| Método | Contexto | Opciones Incluidas |
|--------|----------|---------------------|
| `library()` | Pantalla principal | Sleep, Order, Create Playlist, Equalizer, Settings |
| `player()` | Reproductor activo | Sleep, Add/Remove Playlist*, Speed, Equalizer, Settings |
| `playlist()` | Vista de playlist | Sleep, Reorder, Rename, Delete, Equalizer, Settings |
| `songLibraryContext()` | Long press en biblioteca | Play, Play Next**, Add to Queue**, Add to Playlist, Song Info |
| `songPlaylistContext()` | Long press en playlist | Play, Play Next**, Add to Queue**, Add/Remove Playlist, Song Info |
| `songPlayerListContext()` | Long press en cola | Play, Play Next**, Add to Queue**, Remove from Queue, Add to Playlist, Song Info |

*Solo si reproduce desde playlist  
**Solo si hay reproducción activa

## 🎨 Estructura del Modal

```dart
class OptionsModal {
  void _show(List<Widget> options) => modalView(
    context,
    isScrollable: true,
    title: context.tr('options.title'),
    children: [SectionCard(title: '', children: options)],
  );
  
  // Lógica condicional
  void player() {
    final playerState = context.read<PlayerCubit>().state;
    final songsState = context.read<SongsCubit>().state;
    
    final options = <Widget>[
      const SleepOption(),
      const AddPlaylistOption(),
      // Solo mostrar si reproduce desde playlist
      if (_isPlayingFromPlaylist(playerState, songsState))
        const RemovePlaylistOption(),
      const SpeedOption(),
      const EqualizerOption(),
      const SettingsOption(),
    ];
    _show(options);
  }
}
```

## 🔄 Lógica Condicional

### Detección de Context Reproductor

```dart
static bool _isPlayingFromPlaylist(PlayerState playerState, SongsState songsState) {
  // Si no hay canción seleccionada, no estamos reproduciendo desde playlist
  if (!playerState.hasSelectedSong) return false;
  
  // Si la cantidad de canciones en la playlist actual es menor que
  // el total de canciones en la biblioteca, estamos en una playlist específica
  final playlistLength = playerState.playlist.length;
  final totalSongsLength = songsState.songs.length;
  
  return playlistLength < totalSongsLength;
}
```

### Opciones de Canción Contextual

```dart
void songLibraryContext(SongModel song, List<SongModel> playlist) {
  final playerState = context.read<PlayerCubit>().state;
  final options = <Widget>[
    PlaySongOption(song: song, playlist: playlist),
    
    // Solo si hay reproducción activa
    if (playerState.hasSelectedSong) ...[
      PlayNextOption(song: song),
      AddToQueueOption(song: song),
    ],
    
    AddToPlaylistOption(song: song),
    SongInfoOption(song: song),
  ];
  _show(options);
}
```

## 📱 Casos de Uso Específicos

### 1. Opciones de Biblioteca
**Contexto**: `library_screen.dart`
**Trigger**: Botón de opciones en AppBar

```dart
// Uso
OptionsModal(context).library();

// Opciones mostradas
├── Sleep Timer
├── Order Songs 
├── Create Playlist
├── Equalizer
└── Settings
```

### 2. Opciones de Reproductor
**Contexto**: `player_screen.dart`
**Trigger**: Botón de opciones en AppBar

```dart
// Uso
OptionsModal(context).player();

// Opciones mostradas (condicionales)
├── Sleep Timer
├── Add to Playlist
├── Remove from Playlist  [solo si reproduce desde playlist]
├── Playback Speed
├── Equalizer
└── Settings
```

### 3. Opciones de Playlist
**Contexto**: `playlist_screen.dart`
**Trigger**: Botón de opciones en AppBar

```dart
// Uso
OptionsModal(context).playlist();

// Opciones mostradas
├── Sleep Timer
├── Reorder Songs
├── Rename Playlist
├── Delete Playlist
├── Equalizer
└── Settings
```

### 4. Contexto de Canción - Biblioteca
**Contexto**: Long press en `SongCard` desde biblioteca
**Trigger**: `onLongPress` en biblioteca

```dart
// Uso
OptionsModal(context).songLibraryContext(song, playlist);

// Opciones mostradas
├── Play
├── Play Next          [solo si hay reproducción]
├── Add to Queue       [solo si hay reproducción]
├── Add to Playlist
└── Song Information
```

### 5. Contexto de Canción - Playlist
**Contexto**: Long press en `SongCard` desde vista de playlist
**Trigger**: `onLongPress` en playlist

```dart
// Uso
OptionsModal(context).songPlaylistContext(song, playlist);

// Opciones mostradas
├── Play
├── Play Next          [solo si hay reproducción]
├── Add to Queue       [solo si hay reproducción]
├── Add to Playlist
├── Remove from Playlist
└── Song Information
```

### 6. Contexto de Canción - Cola de Reproducción
**Contexto**: Long press en `SongCard` desde modal de playlist del reproductor
**Trigger**: `onLongPress` en `PlaylistModal`

```dart
// Uso
OptionsModal(context).songPlayerListContext(song, playlist);

// Opciones mostradas
├── Play
├── Play Next          [solo si hay reproducción]
├── Add to Queue       [solo si hay reproducción]
├── Remove from Queue
├── Add to Playlist
└── Song Information
```

## 🔧 Integración con SongCard

### Estructura Actualizada de SongCard

```dart
class SongCard extends StatelessWidget {
  const SongCard({
    required this.playlist,
    required this.song,
    required this.onTap,
    required this.onLongPress,  // Callback directo
    super.key,
  });

  final List<SongModel> playlist;
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onLongPress;  // Manejo externo del contexto
}
```

### Uso en Diferentes Pantallas

```dart
// En LibraryScreen
SongCard(
  playlist: orderedSongs,
  song: song,
  onTap: () => context.pushNamed(PlayerScreen.routeName),
  onLongPress: () => OptionsModal(context).songLibraryContext(song, orderedSongs),
);

// En PlaylistScreen
SongCard(
  playlist: playlistSongs,
  song: song,
  onTap: () => context.pushNamed(PlayerScreen.routeName),
  onLongPress: () => OptionsModal(context).songPlaylistContext(song, playlistSongs),
);

// En PlaylistModal
SongCard(
  playlist: state.playlist,
  song: currentSong,
  onTap: () => context.pop(),
  onLongPress: () => OptionsModal(context).songPlayerListContext(currentSong, state.playlist),
);
```

## 🎛️ Opciones Disponibles

### Opciones de Reproductor
- **PlaySongOption**: Reproduce la canción inmediatamente
- **PlayNextOption**: Inserta canción después de la actual
- **AddToQueueOption**: Agrega canción al final de la cola
- **RemoveFromQueueOption**: Elimina canción de la cola actual

### Opciones de Playlist
- **AddToPlaylistOption**: Agrega canción a playlists existentes
- **RemoveFromPlaylistOption**: Elimina canción de playlists

### Opciones de Información
- **SongInfoOption**: Muestra metadata completa de la canción
- **ShareOption**: Comparte información de la canción

### Opciones de Sistema
- **SleepOption**: Configuración de sleep timer
- **SpeedOption**: Velocidad de reproducción
- **EqualizerOption**: Configuración de ecualizador
- **SettingsOption**: Configuraciones generales

## 🔍 Flujo de Decisión Condicional

### Player Modal
```
¿Hay canción reproduciéndose?
├── No → Solo opciones básicas
└── Yes → ¿Reproduce desde playlist?
    ├── No → Sin "Remove from Playlist"
    └── Yes → Con "Remove from Playlist"
```

### Song Context Modal
```
¿Hay reproducción activa?
├── No → Solo Play, Add to Playlist, Song Info
└── Yes → Incluir Play Next, Add to Queue

¿Desde qué contexto?
├── Library → Sin Remove options
├── Playlist → Con Remove from Playlist
└── Player Queue → Con Remove from Queue
```

## 📊 Beneficios de UX

### Antes vs Después

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Opciones mostradas** | Todas siempre | Solo relevantes |
| **Confusión del usuario** | Alta | Mínima |
| **Clicks innecesarios** | Frecuentes | Eliminados |
| **Contexto perdido** | Común | Never |
| **Experiencia** | Inconsistente | Fluida |

### Ejemplos de Mejora

#### Escenario 1: Usuario no está reproduciendo música
- **Antes**: Veía "Play Next", "Add to Queue" (no funcionales)
- **Después**: Solo ve "Play", "Add to Playlist", "Song Info"

#### Escenario 2: Usuario reproduce desde biblioteca general
- **Antes**: Veía "Remove from Playlist" (sin sentido)
- **Después**: No ve esa opción

#### Escenario 3: Long press desde lista de reproducción
- **Antes**: No tenía forma de quitar canción de la cola
- **Después**: Ve "Remove from Queue" específicamente

## 🚀 Extensibilidad

### Agregar Nueva Opción

```dart
// 1. Crear el widget de opción
class MyNewOption extends StatelessWidget {
  const MyNewOption({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightStar,
      title: context.tr('options.my_new_option'),
      onTap: () {
        context.pop();
        // Lógica de la opción
      },
    );
  }
}

// 2. Agregar a OptionsModal
void myContext(SongModel song) {
  final options = <Widget>[
    // ... otras opciones
    const MyNewOption(),
  ];
  _show(options);
}
```

### Agregar Nuevo Contexto

```dart
void songSpecialContext(SongModel song, List<SongModel> playlist) {
  final playerState = context.read<PlayerCubit>().state;
  final options = <Widget>[
    PlaySongOption(song: song, playlist: playlist),
    
    // Lógica condicional específica
    if (someCondition) SpecialOption(song: song),
    
    SongInfoOption(song: song),
  ];
  _show(options);
}
```

## 🎯 Mejores Prácticas

### ✅ Do's
- Usar OptionsModal(context).method() para todos los modales
- Mantener lógica condicional simple y clara  
- Agrupar opciones relacionadas
- Proporcionar feedback visual claro
- Testear todos los contextos posibles

### ❌ Don'ts
- No mostrar opciones no funcionales
- No duplicar lógica entre contextos
- No ignorar el estado de reproducción
- No mezclar contextos sin lógica clara
- No hardcodear listas de opciones

---

El sistema OptionsModal contextual mejora significativamente la experiencia de usuario al proporcionar solo las opciones relevantes para cada situación, eliminando confusión y haciendo la app más intuitiva y eficiente.