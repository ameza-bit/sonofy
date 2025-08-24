# Sistema Completo de Widgets de Sonofy

## 📖 Visión General

Sonofy cuenta con un sistema integral de widgets especializados organizados en cuatro categorías principales, cada una diseñada para casos de uso específicos dentro de la aplicación musical. El sistema está construido siguiendo principios de **Component-Driven Development** y **Design System** consistente.

## 🏗️ Arquitectura del Sistema de Widgets

### Organización Jerárquica

```
presentation/widgets/
├── common/          # Componentes base reutilizables
├── library/         # Widgets específicos de biblioteca musical
├── options/         # Sistema contextual de opciones/menús
└── player/          # Controles avanzados de reproducción
```

### Patrones de Diseño Aplicados

- **Composition over Inheritance**: Widgets composables y modulares
- **Single Responsibility**: Cada widget tiene un propósito específico
- **Context-Aware**: Comportamientos adaptativos según contexto de uso
- **BLoC Integration**: Integración profunda con gestión de estado reactivo

---

## 1. 🔧 WIDGETS COMUNES (/common/)

### CustomTextField
**Propósito**: Campo de texto avanzado con soporte completo para validación y temas

**Características Técnicas**:
- **Validación Integrada**: Soporte para múltiples validadores
- **Estados Visuales**: Normal, focus, error, disabled
- **Tipos Especializados**: Password con toggle de visibilidad
- **Responsive Design**: Escalado automático con `context.scaleText`
- **Accesibilidad**: AutofillHints y TextInputAction para UX optimizada

```dart
CustomTextField(
  labelText: 'Nombre de la playlist',
  validator: Validators.required,
  onChanged: (value) => _validateInput(value),
  textInputAction: TextInputAction.done,
  autofillHints: [AutofillHints.name],
)
```

### PrimaryButton y SecondaryButton
**Propósito**: Sistema de botones con jerarquía visual clara

**Patrones Implementados**:
- **Factory Pattern**: Múltiples configuraciones (outlined, filled, icon, loading)
- **Responsive Scaling**: Adaptación automática a diferentes pantallas
- **Dynamic Theming**: Colores primarios configurables por usuario

```dart
// Botón primario con estado de carga
PrimaryButton(
  text: context.tr('create'),
  icon: Icons.add,
  isLoading: state.isCreating,
  onPressed: state.isCreating ? null : _createPlaylist,
)

// Botón secundario con estilo outline
SecondaryButton.outlined(
  text: context.tr('cancel'),
  onPressed: () => Navigator.pop(context),
)
```

### SectionCard y SectionItem
**Propósito**: Organización consistente de contenido en secciones

**Características**:
- **Adaptive Elevation**: Sombras que respetan el tema claro/oscuro
- **Flexible Content**: Soporte para dividers, trailing widgets, iconografía
- **Gesture Recognition**: InkWell response con feedback táctil

### Sistema FontAwesome Personalizado
**Propósito**: Iconografía rica sin limitaciones de tamaño cuadrado

**Innovaciones Técnicas**:
```dart
// Implementación que evita restricciones de AspectRatio
class FaIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  // Renderizado directo sin Container cuadrado forzado
  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}
```

**Soporte Multi-Familia**:
- FontAwesome Solid, Regular, Light, Brands
- Clases especializadas por tipo: `IconDataSolid`, `IconDataLight`
- Manejo direccional para iconos RTL/LTR

---

## 2. 🎵 WIDGETS DE BIBLIOTECA MUSICAL (/library/)

### BottomPlayer
**Propósito**: Reproductor persistente minimalista con información de canción actual

**Arquitectura Avanzada**:
- **Multiple BlocBuilder**: Escucha simultánea `PlayerCubit` + `SettingsCubit`
- **Hero Animations**: Transiciones fluidas hacia PlayerScreen completo
- **Real-time Progress**: StreamBuilder para progreso circular en tiempo real

**Características UX**:
```dart
// Progreso circular que rodea la portada
Stack(
  alignment: Alignment.center,
  children: [
    // Progreso circular dinámico
    StreamBuilder<Duration>(
      stream: playerCubit.positionStream,
      builder: (context, snapshot) => CircularProgressIndicator(
        value: _calculateProgress(snapshot.data, duration),
        strokeWidth: 2,
        backgroundColor: Colors.grey[300],
      ),
    ),
    // Portada de álbum con QueryArtworkWidget
    QueryArtworkWidget(
      id: song.id,
      type: ArtworkType.AUDIO,
      nullArtworkWidget: Icon(Icons.music_note),
    ),
  ],
)
```

### PlaylistCard con PlaylistCoverGrid
**Propósito**: Visualización inteligente de playlists con sistema de grid dinámico

**Algoritmo de Portadas**:
```dart
class PlaylistCoverGrid extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      child: _buildGridLayout(),
    );
  }

  Widget _buildGridLayout() {
    final songCount = playlist.songIds.length;
    
    if (songCount == 0) return _buildPlaceholder();
    if (songCount == 1) return _buildSingleCover();
    if (songCount <= 4) return _buildMultipleCovers();
    
    // Lógica recursiva para más de 4 canciones
    return _buildGridWithFallback();
  }
}
```

**Integración Avanzada**:
- **Navigation**: GoRouter con parámetros tipados para rutas anidadas
- **Context Menus**: Long press para `OptionsModal` contextual
- **Dynamic Sizing**: Cálculo responsivo con `cardWidth()` utility

### SongCard
**Propósito**: Componente principal para representar canciones individuales

**Estado Visual Inteligente**:
```dart
// Diferenciación visual para canción activa
Container(
  decoration: BoxDecoration(
    color: isCurrentSong 
      ? context.colorScheme.primary.withOpacity(0.1)
      : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
  ),
  child: ListTile(
    leading: _buildPlayButton(),
    title: _buildSongInfo(),
    trailing: _buildDuration(),
  ),
)
```

**Integración con Estado**:
- **Playlist Context**: Manejo inteligente de playlist original vs shuffled
- **Real-time Updates**: Respuesta instantánea a cambios de estado
- **Gesture Handling**: Tap para reproducir, long press para opciones

---

## 3. 🎛️ SISTEMA DE OPCIONES (/options/)

### OptionsModal - Sistema Contextual Avanzado
**Propósito**: Modal inteligente con opciones diferenciadas por contexto

**Patrón Strategy Implementado**:
```dart
class OptionsModal extends StatelessWidget {
  // Factory constructors para diferentes contextos
  factory OptionsModal.library(BuildContext context, {
    required List<SongModel> songs,
    required VoidCallback onRefresh,
  }) => OptionsModal._(context, LibraryOptionsStrategy(songs, onRefresh));

  factory OptionsModal.playlist(BuildContext context, {
    required Playlist playlist,
    required VoidCallback onRefresh,
  }) => OptionsModal._(context, PlaylistOptionsStrategy(playlist, onRefresh));

  factory OptionsModal.player(BuildContext context) =>
    OptionsModal._(context, PlayerOptionsStrategy());
}
```

**Contextos Especializados**:
1. **Library Context**: Crear playlist, configuraciones, ordenar
2. **Playlist Context**: Editar, eliminar, reordenar, información
3. **Player Context**: Ecualizador, sleep timer, velocidad, compartir
4. **Song Contexts**: Opciones específicas por contexto de canción

### AddToPlaylistOption - Lógica de Negocio Compleja
**Propósito**: Funcionalidad avanzada para gestión de playlists

**Algoritmo Inteligente**:
```dart
Future<void> _showPlaylistSelection() async {
  // Filtrar playlists que NO contienen la canción
  final availablePlaylists = allPlaylists.where((playlist) {
    return !playlist.songIds.contains(song.id);
  }).toList();

  if (availablePlaylists.isEmpty) {
    // Estado especial: todas las playlists ya contienen la canción
    _showAllPlaylistsContainSong();
    return;
  }

  // Mostrar selector de playlists disponibles
  _showPlaylistPicker(availablePlaylists);
}
```

**Estados UX Manejados**:
- ✅ Playlists disponibles para agregar
- ⚠️ Todas las playlists ya contienen la canción
- 🆕 No existen playlists (prompt para crear)
- 📊 Feedback visual con Toast notifications

### Sistema de Opciones por Canción
**Arquitectura modular con componentes específicos**:

- **`PlaySongOption`**: Reproducir inmediatamente
- **`PlayNextOption`**: Insertar después de canción actual
- **`AddToQueueOption`**: Agregar al final de la cola
- **`RemoveFromQueueOption`**: Quitar de cola con ajuste de índices
- **`SongInfoOption`**: Metadatos detallados con duración formateada
- **`ShareOption`**: Compartir información de canción

---

## 4. 🎧 WIDGETS DEL REPRODUCTOR (/player/)

### PlayerControl - Sistema de Controles Inteligente
**Propósito**: Controles principales con estados visuales complejos

**Estados de Iconografía Dinámica**:
```dart
Widget _buildRepeatButton() {
  IconData iconData;
  Color? iconColor;
  
  switch (state.repeatMode) {
    case RepeatMode.none:
      iconData = Icons.repeat;
      iconColor = context.colorScheme.onSurface.withOpacity(0.6);
      break;
    case RepeatMode.one:
      iconData = Icons.repeat_one;
      iconColor = context.colorScheme.primary;
      break;
    case RepeatMode.all:
      iconData = Icons.repeat;
      iconColor = context.colorScheme.primary;
      break;
  }
  
  return IconButton(
    icon: Icon(iconData, color: iconColor),
    onPressed: () => context.read<PlayerCubit>().toggleRepeat(),
  );
}
```

**Botón Principal con Gradiente**:
- **CircularGradientButton**: Diseño especializado para reproducción
- **Estado Loading**: Indicador durante cambios de canción
- **Responsive Sizing**: Escalado según configuración de usuario

### PlayerSlider - Control de Progreso Avanzado
**Propósito**: Interactividad fluida para navegación temporal

**Características Técnicas**:
```dart
class PlayerSlider extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: context.read<PlayerCubit>().positionStream,
      builder: (context, snapshot) {
        final position = _isDragging ? _dragPosition : snapshot.data;
        return Column(
          children: [
            Slider(
              value: _calculateProgress(position, duration),
              onChanged: _onSliderChanged,
              onChangeStart: _onSliderStart,
              onChangeEnd: _onSliderEnd,
              activeColor: context.colorScheme.primary,
            ),
            _buildTimeLabels(position, duration),
          ],
        );
      },
    );
  }
}
```

**Estados de Interacción**:
- **Dragging State**: Preview visual de nueva posición
- **Real-time Updates**: Sincronización con stream de posición
- **Gesture Handling**: Smooth dragging con feedback inmediato

### PlaylistModal - Visualización Inteligente de Cola
**Propósito**: Modal de cola con lógica de visualización condicional

**Algoritmo Condicional por RepeatMode**:
```dart
List<SongModel> _getDisplayPlaylist() {
  final currentSong = state.currentSong;
  if (currentSong == null) return state.activePlaylist;

  switch (state.repeatMode) {
    case RepeatMode.one:
      // Solo mostrar canción actual (se repite infinitamente)
      return [currentSong];
      
    case RepeatMode.none:
      // Mostrar desde canción actual hasta el final
      final currentIndex = state.activePlaylist.indexOf(currentSong);
      return state.activePlaylist.sublist(currentIndex);
      
    case RepeatMode.all:
      // Mostrar lista completa reordenada con actual al inicio
      final reordered = List<SongModel>.from(state.activePlaylist);
      final currentIndex = reordered.indexOf(currentSong);
      if (currentIndex > 0) {
        final current = reordered.removeAt(currentIndex);
        reordered.insert(0, current);
      }
      return reordered;
  }
}
```

### SleepModal - Temporizador Avanzado
**Propósito**: Sleep timer con modos condicionales

**Estados de Funcionamiento**:
1. **Configuración**: Slider para seleccionar duración + botones rápidos
2. **Timer Activo**: Countdown en tiempo real con opción de cancelar
3. **Modo Espera**: "Esperar final de canción" con lógica condicional

**Implementación de Estados Visuales**:
```dart
Widget _buildTimerDisplay() {
  if (!state.isSleepTimerActive) return _buildConfigurationView();
  
  if (state.waitForSongToFinish && state.sleepTimerRemaining!.inSeconds <= 0) {
    return _buildWaitingForSongEndView();
  }
  
  return _buildActiveTimerView();
}
```

---

## 🎨 PATRONES DE DISEÑO APLICADOS

### 1. BLoC Pattern Consistency
**Integración uniforme en todos los widgets**:
```dart
// Patrón estándar de escucha de estado
BlocBuilder<PlayerCubit, PlayerState>(
  buildWhen: (previous, current) => 
    previous.isPlaying != current.isPlaying,
  builder: (context, state) => PlayPauseIcon(isPlaying: state.isPlaying),
)

// Patrón de acciones
onPressed: () => context.read<PlayerCubit>().togglePlayPause()
```

### 2. Responsive Design Pattern
**Extensiones contextuales para adaptabilidad**:
```dart
// Escalado automático de texto
Text(
  title, 
  style: TextStyle(fontSize: context.scaleText(16)),
)

// Padding responsivo
Padding(
  padding: EdgeInsets.all(context.isMobile ? 16 : 24),
  child: content,
)
```

### 3. Component Composition Pattern
**Widgets altamente composables**:
```dart
// Ejemplo de composición en SongCard
SongCard(
  song: song,
  showArtwork: true,
  showDuration: true,
  onTap: () => _playSong(song),
  onLongPress: () => _showSongOptions(song),
  trailing: _buildPlayingIndicator(song),
)
```

### 4. Context-Aware Pattern
**Comportamientos adaptativos según contexto**:
```dart
// OptionsModal adapta opciones según origen
factory OptionsModal.songInLibrary(SongModel song) => OptionsModal._(
  [PlaySongOption(song), AddToPlaylistOption(song), SongInfoOption(song)]
);

factory OptionsModal.songInPlaylist(SongModel song, Playlist playlist) => OptionsModal._(
  [PlaySongOption(song), RemoveFromPlaylistOption(song, playlist)]
);
```

---

## 🎯 CARACTERÍSTICAS DESTACADAS

### 1. **Theming System Integration**
- Colores primarios dinámicos desde configuración de usuario
- Soporte completo para modo claro/oscuro
- Escalado de fuentes configurable

### 2. **Performance Optimizations**
- **StreamBuilders** específicos para datos en tiempo real
- **BuildWhen** selectivo para reconstrucciones optimizadas
- **Widget rebuilding** mínimo con BlocSelector

### 3. **Accessibility Features**
- Semantic labels apropiados
- Keyboard navigation support
- Screen reader compatibility
- Contrast ratios respetando WCAG

### 4. **Micro-interactions**
- Feedback táctil con InkWell responses
- Loading states con indicadores contextuales
- Toast notifications para feedback de acciones
- Hero animations para transiciones fluidas

### 5. **Error Handling**
- Estados de error visuales apropiados
- Fallbacks graceful para widgets que fallan
- Validación de entrada en tiempo real

---

## 🔮 EXTENSIBILIDAD

### Nuevos Widgets
El sistema está diseñado para fácil extensión:

```dart
// Template para nuevo widget común
class NewCommonWidget extends StatelessWidget {
  // Seguir patrones establecidos:
  // 1. BlocBuilder/BlocListener para estado
  // 2. context.scaleText para responsive
  // 3. Theming consistente
  // 4. Accessibility labels
}
```

### Nuevos Contextos de Opciones
```dart
// Agregar nuevo contexto al OptionsModal
factory OptionsModal.newContext(ContextData data) => 
  OptionsModal._(context, NewContextStrategy(data));
```

Este sistema de widgets demuestra una arquitectura sólida, enfocada en la experiencia del usuario, con patrones de diseño consistentes y una integración profunda con el ecosistema de gestión de estado de la aplicación.