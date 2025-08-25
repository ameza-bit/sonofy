# Widgets Especializados

## 📖 Visión General

Los widgets especializados de Sonofy son componentes específicos del dominio musical que manejan funcionalidades particulares del reproductor de audio y la gestión de la biblioteca musical. Estos widgets encapsulan lógica compleja y proporcionan interfaces especializadas para la experiencia musical.

## 🎵 Widgets del Reproductor

### PlayerControl

#### Propósito
Controles principales del reproductor de música con botones de play/pause, anterior y siguiente.

#### Ubicación
`lib/presentation/widgets/player/player_control.dart`

#### Características
- **Controles centrales**: Play/pause como acción principal
- **Navegación de playlist**: Botones anterior/siguiente
- **Estados visuales**: Iconos adaptativos según estado de reproducción
- **Integración BLoC**: Conectado directamente con PlayerCubit

#### Implementación
```dart
class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPreviousButton(context, state),
            _buildPlayPauseButton(context, state),
            _buildNextButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildPreviousButton(BuildContext context, PlayerState state) {
    return IconButton(
      onPressed: state.hasPrevious 
          ? () => context.read<PlayerCubit>().previousSong()
          : null,
      icon: Icon(
        FontAwesome.solidBackward,
        size: 32,
        color: state.hasPrevious 
            ? context.musicWhite
            : context.musicWhite.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, PlayerState state) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.musicWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: state.currentSong != null
            ? () => context.read<PlayerCubit>().togglePlayPause()
            : null,
        icon: Icon(
          state.isPlaying 
              ? FontAwesome.solidPause 
              : FontAwesome.solidPlay,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        iconSize: 56,
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, PlayerState state) {
    return IconButton(
      onPressed: state.hasNext 
          ? () => context.read<PlayerCubit>().nextSong()
          : null,
      icon: Icon(
        FontAwesome.solidForward,
        size: 32,
        color: state.hasNext 
            ? context.musicWhite
            : context.musicWhite.withValues(alpha: 0.5),
      ),
    );
  }
}
```

#### Estados Manejados
- **Sin canción**: Todos los controles deshabilitados
- **Primera canción**: Botón anterior deshabilitado
- **Última canción**: Botón siguiente deshabilitado
- **Reproduciendo**: Botón pause visible
- **Pausado**: Botón play visible

### PlayerSlider

#### Propósito
Control deslizante para mostrar y controlar el progreso de reproducción de la canción actual.

#### Ubicación
`lib/presentation/widgets/player/player_slider.dart`

#### Características
- **Progreso visual**: Muestra posición actual en la canción
- **Control interactivo**: Permite saltar a posiciones específicas
- **Información temporal**: Tiempo transcurrido y duración total
- **Actualización en tiempo real**: Se actualiza automáticamente durante reproducción

#### Implementación
```dart
class PlayerSlider extends StatefulWidget {
  const PlayerSlider({super.key});

  @override
  State<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends State<PlayerSlider> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _startPositionTimer();
  }

  void _startPositionTimer() {
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => _updatePosition(),
    );
  }

  void _updatePosition() {
    if (!_isDragging && mounted) {
      // Actualizar posición desde el repositorio
      context.read<PlayerCubit>().updatePosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong;
        if (currentSong == null) {
          return _buildEmptySlider();
        }

        return Column(
          children: [
            _buildSlider(context, state),
            const SizedBox(height: 8),
            _buildTimeLabels(context, state),
          ],
        );
      },
    );
  }

  Widget _buildSlider(BuildContext context, PlayerState state) {
    final duration = Duration(milliseconds: state.currentSong?.duration ?? 0);
    final position = state.position ?? Duration.zero;
    
    final sliderValue = _isDragging 
        ? _dragValue 
        : (duration.inMilliseconds > 0 
            ? position.inMilliseconds / duration.inMilliseconds 
            : 0.0);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        activeTrackColor: context.musicWhite,
        inactiveTrackColor: context.musicWhite.withValues(alpha: 0.3),
        thumbColor: context.musicWhite,
        overlayColor: context.musicWhite.withValues(alpha: 0.2),
      ),
      child: Slider(
        value: sliderValue.clamp(0.0, 1.0),
        onChanged: (value) {
          setState(() {
            _isDragging = true;
            _dragValue = value;
          });
        },
        onChangeEnd: (value) {
          final newPosition = Duration(
            milliseconds: (value * duration.inMilliseconds).round(),
          );
          context.read<PlayerCubit>().seekTo(newPosition);
          setState(() {
            _isDragging = false;
          });
        },
      ),
    );
  }

  Widget _buildTimeLabels(BuildContext context, PlayerState state) {
    final duration = Duration(milliseconds: state.currentSong?.duration ?? 0);
    final position = state.position ?? Duration.zero;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(position),
          style: TextStyle(
            color: context.musicWhite.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        Text(
          _formatDuration(duration),
          style: TextStyle(
            color: context.musicWhite.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: Colors.grey.shade300,
          ),
          child: const Slider(
            value: 0.0,
            onChanged: null,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0:00', style: TextStyle(color: Colors.grey.shade500)),
            Text('0:00', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }
}
```

### PlayerLyrics

#### Propósito
Modal y botón para mostrar las letras de la canción actual (funcionalidad preparada).

#### Ubicación
`lib/presentation/widgets/player/player_lyrics.dart`

#### Características
- **Modal deslizable**: Se presenta desde la parte inferior
- **Scroll automático**: Sincronización con reproducción (planificado)
- **Búsqueda de letras**: Integración con APIs de letras (planificado)
- **Diseño adaptativo**: Se ajusta al contenido disponible

#### Implementación
```dart
class PlayerLyrics extends StatelessWidget {
  const PlayerLyrics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () => _showLyricsModal(context),
            icon: Icon(
              FontAwesome.lightFileLines,
              size: 18,
              color: context.musicWhite.withValues(alpha: 0.8),
            ),
            label: Text(
              'Ver letra',
              style: TextStyle(
                color: context.musicWhite.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: context.musicWhite.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  void _showLyricsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LyricsModal(),
    );
  }
}
```

## 📚 Widgets de Biblioteca

### SongCard

#### Propósito
Componente unificado para mostrar canciones con soporte para interacciones contextuales. Rediseñado completamente para el nuevo sistema de modales contextuales.

#### Ubicación
`lib/presentation/widgets/library/song_card.dart`

#### Características Principales
- **Interacciones Contextuales**: Long press con opciones específicas según contexto
- **Callbacks Externos**: Manejo de tap y long press desde el componente padre
- **Botón de Play**: Botón circular con gradiente para reproducción directa
- **Estados Visuales**: Indicadores claros de reproducción y estado
- **Información Completa**: Título, artista, duración formateada

#### Nueva Implementación
```dart
class SongCard extends StatelessWidget {
  const SongCard({
    required this.playlist,
    required this.song,
    required this.onTap,
    required this.onLongPress,  // ✨ Nuevo: Callback contextual
    super.key,
  });

  final List<SongModel> playlist;
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onLongPress;  // ✨ Manejo externo

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return InkWell(
          onTap: () {
            context.read<PlayerCubit>().setPlayingSong(playlist, song);
            onTap(); // ✨ Callback externo
          },
          onLongPress: onLongPress, // ✨ Callback contextual
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 12,
                children: [
                  // ✨ Botón de play circular con gradiente
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, state) {
                      final isPlaying = state.isPlaying && 
                                       state.currentSong?.id == song.id;
                      return CircularGradientButton(
                        size: 48,
                        elevation: 1,
                        primaryColor: isPlaying ? primaryColor : context.musicWhite,
                        onPressed: () {
                          if (state.currentSong?.id == song.id) {
                            context.read<PlayerCubit>().togglePlayPause();
                          } else {
                            context.read<PlayerCubit>().setPlayingSong(playlist, song);
                          }
                        },
                        child: Icon(
                          isPlaying ? FontAwesomeIcons.solidPause : FontAwesomeIcons.solidPlay,
                          color: isPlaying ? context.musicWhite : primaryColor,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  
                  // Información de la canción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.scaleText(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          song.artist ?? song.composer ?? 'Desconocido',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.scaleText(12),
                            color: context.musicLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Duración
                  Text(
                    DurationMinutes.format(song.duration ?? 0),
                    style: TextStyle(
                      fontSize: context.scaleText(12),
                      color: context.musicLightGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

#### Uso Contextual de SongCard

La nueva arquitectura de `SongCard` permite diferentes comportamientos según el contexto:

```dart
// ✅ En LibraryScreen
SongCard(
  playlist: orderedSongs,
  song: song,
  onTap: () => context.pushNamed(PlayerScreen.routeName),
  onLongPress: () => OptionsModal(context).songLibraryContext(song, orderedSongs),
);

// ✅ En PlaylistScreen  
SongCard(
  playlist: playlistSongs,
  song: song,
  onTap: () => context.pushNamed(PlayerScreen.routeName),
  onLongPress: () => OptionsModal(context).songPlaylistContext(song, playlistSongs),
);

// ✅ En PlaylistModal (Cola de reproducción)
SongCard(
  playlist: state.playlist,
  song: currentSong,
  onTap: () => context.pop(),
  onLongPress: () => OptionsModal(context).songPlayerListContext(currentSong, state.playlist),
);
```

#### Interacciones Soportadas

| Acción | Comportamiento |
|--------|----------------|
| **Tap en card** | Reproduce canción + ejecuta callback `onTap` |
| **Long press** | Ejecuta callback `onLongPress` (modal contextual) |
| **Tap en play button** | Si es canción actual: toggle play/pause, sino: reproduce |

#### Migración desde Versión Anterior

**❌ Antes (acoplado)**
```dart
// SongCard manejaba internamente las opciones
SongCard(playlist: songs, song: song) // Sin callbacks
```

**✅ Después (desacoplado)**
```dart  
// SongCard recibe callbacks externos para flexibilidad
SongCard(
  playlist: songs,
  song: song,
  onTap: () => navigateToPlayer(),
  onLongPress: () => showContextualOptions(),
)
```

### BottomPlayer

#### Propósito
Reproductor mini que se mantiene visible en la parte inferior de la biblioteca.

#### Ubicación
`lib/presentation/widgets/library/bottom_player.dart`

#### Características
- **Siempre visible**: Persistente en LibraryScreen
- **Información compacta**: Canción actual y estado
- **Navegación rápida**: Tap para ir al reproductor completo
- **Hero animation**: Transición suave al PlayerScreen

#### Implementación
```dart
class BottomPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const BottomPlayer({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong;
        
        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return Hero(
          tag: 'player_container',
          child: Material(
            color: Colors.transparent,
            child: BottomClipperContainer(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    _buildArtwork(context, currentSong),
                    const SizedBox(width: 12),
                    _buildSongInfo(context, currentSong),
                    const Spacer(),
                    _buildPlayButton(context, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtwork(BuildContext context, SongModel song) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          artworkWidth: 48,
          artworkHeight: 48,
          artworkFit: BoxFit.cover,
          nullArtworkWidget: Container(
            color: Colors.grey.shade300,
            child: Icon(
              Icons.music_note,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, SongModel song) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            song.title.isNotEmpty ? song.title : 'Canción Sin Título',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            song.artist ?? song.composer ?? 'Artista Desconocido',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, PlayerState state) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => context.read<PlayerCubit>().togglePlayPause(),
        icon: Icon(
          state.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
```

### BottomClipperContainer

#### Propósito
Contenedor con diseño recortado que crea un efecto visual elevado.

#### Ubicación
`lib/presentation/widgets/library/bottom_clipper_container.dart`

#### Características
- **Clip path personalizado**: Crea forma redondeada superior
- **Efecto elevado**: Sombra y elevación visual
- **Flexible**: Acepta cualquier contenido hijo
- **Consistente**: Usado en BottomPlayer y PlayerScreen

#### Implementación
```dart
class BottomClipperContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const BottomClipperContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Crear path con bordes redondeados superiores
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
```

## 🎨 Widgets de Configuración

### LocalMusicSection

#### Propósito
Sección especializada en configuraciones para gestionar la importación de música local desde carpetas del dispositivo.

#### Ubicación
`lib/presentation/views/settings/local_music_section.dart`

#### Características
- **Selección de carpeta**: Integra selector nativo del sistema
- **Estados visuales**: Muestra información de la carpeta actual y cantidad de archivos
- **Gestión de errores**: Manejo de permisos y carpetas inaccesibles
- **Integración BLoC**: Conectado con SettingsCubit y SongsCubit para actualización automática
- **Feedback al usuario**: Indicadores de carga y notificaciones toast

#### Implementación
```dart
class LocalMusicSection extends StatelessWidget {
  const LocalMusicSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SectionCard(
          title: context.tr('settings.local_music.title'),
          icon: FontAwesome.lightFolderMusic,
          children: [
            _buildCurrentFolderInfo(context, state),
            const SizedBox(height: 12),
            _buildSelectFolderButton(context, state),
            if (state.settings.localMusicPath != null) ...[
              const SizedBox(height: 12),
              _buildMp3FilesInfo(context, state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCurrentFolderInfo(BuildContext context, SettingsState state) {
    final localPath = state.settings.localMusicPath;
    
    return SectionItem(
      title: context.tr('settings.local_music.current_folder'),
      subtitle: localPath?.isNotEmpty == true 
          ? _formatPath(localPath!)
          : context.tr('settings.local_music.no_folder_selected'),
      leadingIcon: FontAwesome.lightFolder,
    );
  }

  Widget _buildSelectFolderButton(BuildContext context, SettingsState state) {
    return PrimaryButton(
      text: state.settings.localMusicPath?.isNotEmpty == true
          ? context.tr('settings.local_music.change_folder')
          : context.tr('settings.local_music.select_folder'),
      icon: FontAwesome.lightFolderOpen,
      isLoading: state.isLoading,
      onPressed: state.isLoading ? null : () => _selectFolder(context),
    );
  }

  Widget _buildMp3FilesInfo(BuildContext context, SettingsState state) {
    return BlocBuilder<SongsCubit, SongsState>(
      buildWhen: (previous, current) => 
          previous.localSongs.length != current.localSongs.length,
      builder: (context, songsState) {
        final localSongsCount = songsState.localSongs.length;
        
        return SectionItem(
          title: context.tr('settings.local_music.mp3_files_found'),
          subtitle: context.tr('settings.local_music.files_count', 
              namedArgs: {'count': localSongsCount.toString()}),
          leadingIcon: FontAwesome.lightMusic,
          trailing: localSongsCount > 0 
              ? IconButton(
                  icon: Icon(FontAwesome.lightArrowRotateRight),
                  onPressed: () => _refreshLocalSongs(context),
                  tooltip: context.tr('settings.local_music.refresh_files'),
                )
              : null,
        );
      },
    );
  }

  Future<void> _selectFolder(BuildContext context) async {
    try {
      final settingsCubit = context.read<SettingsCubit>();
      final songsCubit = context.read<SongsCubit>();
      
      final hasFiles = await settingsCubit.selectAndSetMusicFolder();
      
      if (hasFiles) {
        // Actualizar biblioteca automáticamente
        await songsCubit.refreshLocalSongs();
        
        if (context.mounted) {
          Toast.show(
            context,
            context.tr('settings.local_music.folder_selected_success'),
            type: ToastType.success,
          );
        }
      } else {
        if (context.mounted) {
          Toast.show(
            context,
            context.tr('settings.local_music.no_mp3_files_found'),
            type: ToastType.warning,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Toast.show(
          context,
          context.tr('settings.local_music.selection_error'),
          type: ToastType.error,
        );
      }
    }
  }

  void _refreshLocalSongs(BuildContext context) {
    context.read<SongsCubit>().refreshLocalSongs();
    Toast.show(
      context,
      context.tr('settings.local_music.refreshing_files'),
      type: ToastType.info,
    );
  }

  String _formatPath(String path) {
    final parts = path.split('/');
    if (parts.length > 3) {
      return '.../${parts.sublist(parts.length - 2).join('/')}';
    }
    return path;
  }
}
```

#### Estados Manejados
- **Sin carpeta**: Muestra botón para seleccionar
- **Carpeta seleccionada**: Muestra información de la carpeta y botón para cambiar
- **Cargando**: Botón en estado de loading durante selección
- **Con archivos**: Muestra contador de MP3 encontrados y botón de refresco
- **Errores**: Manejo de excepciones con notificaciones toast

#### Integración con Use Cases
- **SelectMusicFolderUseCase**: Para selección de carpeta
- **GetSongsFromFolderUseCase**: Para escaneo de archivos MP3
- **GetLocalSongsUseCase**: Para cargar canciones en la biblioteca

### ColorPickerDialog

#### Propósito
Diálogo para seleccionar el color primario de la aplicación.

#### Ubicación
`lib/presentation/views/settings/color_picker_dialog.dart`

#### Características
- **Colores predefinidos**: Paleta curada de colores
- **Previsualización**: Vista previa del color seleccionado
- **Indicador visual**: Marca el color actualmente seleccionado
- **Aplicación inmediata**: Los cambios se ven al instante

#### Implementación
```dart
class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  static const List<Color> _predefinedColors = [
    Color(0xFF5C42FF), // Púrpura por defecto
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFFF9800), // Naranja
    Color(0xFFF44336), // Rojo
    Color(0xFF9C27B0), // Púrpura claro
    Color(0xFF00BCD4), // Cian
    Color(0xFFFFEB3B), // Amarillo
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('settings.appearance.color_picker_title')),
      content: SizedBox(
        width: 280,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _predefinedColors.length,
          itemBuilder: (context, index) {
            final color = _predefinedColors[index];
            final isSelected = color.value == currentColor.value;
            
            return _buildColorOption(context, color, isSelected);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
      ],
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        onColorSelected(color);
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected 
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}
```

## 🔮 Widgets Futuros

### Funcionalidades Planificadas

#### SearchWidget
```dart
class SearchWidget extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final List<SongModel> suggestions;

  // Widget de búsqueda con sugerencias en tiempo real
}
```

#### PlaylistCard
```dart
class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback? onTap;

  // Tarjeta para mostrar playlists personalizadas
}
```

#### EqualizerWidget
```dart
class EqualizerWidget extends StatelessWidget {
  final List<double> bandLevels;
  final ValueChanged<List<double>>? onChanged;

  // Control visual de ecualizador
}
```

#### VolumeSlider
```dart
class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double>? onChanged;

  // Control de volumen deslizable
}
```

### Mejoras de Accesibilidad
- **Soporte completo para screen readers**
- **Navegación por teclado**
- **Indicadores de estado audibles**
- **Texto alternativo descriptivo**

### Optimizaciones de Rendimiento
- **Lazy loading mejorado**
- **Cacheo inteligente de carátulas**
- **Virtualización de listas grandes**
- **Debouncing en controles interactivos**

Los widgets especializados de Sonofy proporcionan la funcionalidad específica del dominio musical, mantieniendo alta calidad de código y experiencia de usuario optimizada para la reproducción y gestión de música.