# Pantallas Principales de Sonofy

## 📱 Visión General

Sonofy cuenta con **6 pantallas principales** que forman una experiencia musical completa y fluida. Cada pantalla implementa **Clean Architecture** con **BLoC pattern** y está optimizada para **múltiples plataformas** (móvil, tablet, desktop).

### 🗺️ Arquitectura de Navegación

```
/ (splash)
├── /library              # Biblioteca principal con búsqueda
│   ├── /playlist/:id      # Visualización de playlist individual  
│   │   └── /reorder       # Reordenamiento drag & drop
│   └── /player            # Reproductor inmersivo
└── /settings             # Configuraciones modulares
```

### 🎯 Patrones de Diseño Aplicados

- **Hero Animations**: Transiciones fluidas entre pantallas
- **Responsive Layout**: Adaptación automática móvil/tablet/desktop  
- **BLoC Integration**: Gestión de estado reactiva
- **Context-Aware UI**: Comportamientos adaptativos por pantalla
- **PopScope Management**: Control granular de navegación back

---

## 🚀 SplashScreen - Onboarding Inteligente

### 🎯 Propósito
Pantalla de inicialización que gestiona la carga de servicios críticos y configuraciones mientras proporciona feedback visual al usuario.

### 📍 Ubicación
`lib/presentation/screens/splash_screen.dart`

### ✨ Características Avanzadas
- **Inicialización Asíncrona**: Carga paralela de servicios (Preferences, EasyLocalization, repositorios)
- **Estado Visual**: Indicador de progreso con animaciones fluidas
- **Manejo de Errores**: Recovery graceful de fallos de inicialización
- **Redirección Inteligente**: Navegación automática basada en estado de app

### 💻 Implementación Técnica
```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Servicios críticos en paralelo
      await Future.wait([
        EasyLocalization.ensureInitialized(),
        Preferences.init(),
        _loadInitialData(),
      ]);
      
      // Navegación con delay mínimo para UX
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.go('/library');
      }
    } catch (e) {
      _handleInitializationError(e);
    }
  }
}
```

### 🔄 Flujo de Inicialización
1. **Pre-carga**: Servicios singleton (Preferences, EasyLocalization)
2. **Inyección de Dependencias**: Instanciación de repositorios y use cases
3. **Inicialización de Cubits**: 4 cubits especializados con datos iniciales
4. **Validación de Estado**: Verificación de integridad de datos persistidos
5. **Navegación Inteligente**: Redirección basada en configuración inicial

### 📦 Estados Manejados
- **✅ Success**: Inicialización exitosa → navigate to `/library`
- **⚠️ Warning**: Servicios parcialmente disponibles → navegación con limitaciones
- **❌ Error**: Fallo crítico → pantalla de error con retry
- **🔄 Recovery**: Reintento automático de servicios fallidos

---

## 📚 LibraryScreen - Biblioteca Musical Inteligente

### 🎯 Propósito
Pantalla principal que muestra la biblioteca completa de música con funcionalidades avanzadas de búsqueda, filtrado y acceso contextual.

### 📍 Ubicación
`lib/presentation/screens/library_screen.dart`

### ✨ Características Avanzadas
- **Búsqueda Interactiva**: TextField expandible con filtrado en tiempo real
- **Carga Progresiva**: Updates visuales durante escaneo de archivos (iOS)
- **Estados Diferenciados**: Carga, error, vacío, con datos
- **Navegación Protegida**: `PopScope(canPop: false)` para control de back
- **Bottom Player Persistente**: Reproductor mini siempre visible

### 🏗️ Arquitectura de Estado
```dart
class LibraryScreen extends StatefulWidget {
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Control granular de navegación
      child: Scaffold(
        appBar: _buildSearchAppBar(),
        body: _buildBody(),
        bottomNavigationBar: const BottomPlayer(),
      ),
    );
  }
  
  // AppBar dinámico con búsqueda expandible
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      title: _buildSearchField(),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }
}
```

### 🔍 Sistema de Búsqueda Avanzado
```dart
Widget _buildSearchField() {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    child: TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: context.tr('search_songs'),
        prefixIcon: Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty 
          ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      onChanged: _onSearchChanged,
    ),
  );
}

void _onSearchChanged(String query) {
  setState(() => _searchQuery = query);
  // Filtrado en tiempo real sin delay
  context.read<SongsCubit>().filterSongs(query);
}
```

### 📊 Estados de la Biblioteca
```dart
Widget _buildBody() {
  return BlocBuilder<SongsCubit, SongsState>(
    builder: (context, state) {
      if (state.isLoading && state.songs.isEmpty) {
        return _buildLoadingState();
      }
      
      if (state.isLoadingProgressive) {
        return _buildProgressiveLoadingState(state);
      }
      
      if (state.error != null) {
        return _buildErrorState(state.error!);
      }
      
      if (state.filteredSongs.isEmpty && _searchQuery.isNotEmpty) {
        return _buildNoSearchResultsState();
      }
      
      if (state.songs.isEmpty) {
        return _buildEmptyLibraryState();
      }
      
      return _buildSongsListView(state.filteredSongs);
    },
  );
}

Widget _buildProgressiveLoadingState(SongsState state) {
  return Column(
    children: [
      LinearProgressIndicator(
        value: state.totalFiles > 0 
          ? state.loadedCount / state.totalFiles 
          : null,
      ),
      Text('${context.tr('loading_songs')}: ${state.loadedCount}/${state.totalFiles}'),
      Expanded(
        child: _buildSongsListView(state.songs),
      ),
    ],
  );
}
```

---

## 🎵 PlayerScreen - Reproductor Inmersivo

### 🎯 Propósito
Experiencia de reproducción inmersiva con controles completos, información detallada y acceso a funciones avanzadas.

### 📍 Ubicación
`lib/presentation/screens/player_screen.dart`

### ✨ Características Avanzadas
- **UI Inmersiva**: AppBar transparente con artwork de fondo
- **Hero Animations**: Transición fluida desde BottomPlayer
- **Gestos Intuitivos**: Swipe down para cerrar
- **Overlay Inteligente**: Oscurecimiento automático sobre artwork
- **Modales Contextuales**: Sleep timer, playlist, letras (futuro)

### 🎨 Implementación Visual
```dart
class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong;
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildTransparentAppBar(context),
          body: _buildImmersiveBody(currentSong),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildTransparentAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showPlayerOptions(context),
        ),
      ],
    );
  }
}
```

### 🖼️ Sistema de Artwork Dinámico
```dart
Widget _buildArtworkSection(SongModel? song) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.5,
    width: double.infinity,
    child: Stack(
      children: [
        // Artwork de fondo con efecto blur
        QueryArtworkWidget(
          id: song?.id ?? 0,
          type: ArtworkType.AUDIO,
          nullArtworkWidget: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.secondary,
                ],
              ),
            ),
            child: Icon(Icons.music_note, size: 120, color: Colors.white),
          ),
        ),
        
        // Overlay oscuro para legibilidad
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        
        // Información de la canción
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: _buildSongInfo(song),
        ),
      ],
    ),
  );
}
```

---

## 📋 PlaylistScreen - Gestión de Playlists

### 🎯 Propósito
Visualización y gestión detallada de playlists individuales con funcionalidades de edición.

### 📍 Ubicación
`lib/presentation/screens/playlist_screen.dart`

### ✨ Características Avanzadas
- **Parámetros de Ruta**: Recibe `playlistId` desde GoRouter
- **Header Dinámico**: Información de playlist con cover grid
- **Lista Reordenable**: Drag & drop para reorganizar canciones
- **Acciones Contextuales**: Editar, eliminar playlist, agregar canciones
- **Estados de Carga**: Loading, error, playlist vacía

### 📊 Gestión de Estado
```dart
class PlaylistScreen extends StatelessWidget {
  final String playlistId;
  
  const PlaylistScreen({required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, state) {
        final playlist = state.playlists.firstWhere(
          (p) => p.id == playlistId,
          orElse: () => null,
        );
        
        if (playlist == null) {
          return _buildPlaylistNotFoundScreen();
        }
        
        return _buildPlaylistContent(playlist);
      },
    );
  }
  
  Widget _buildPlaylistContent(Playlist playlist) {
    return Scaffold(
      appBar: _buildPlaylistAppBar(playlist),
      body: Column(
        children: [
          _buildPlaylistHeader(playlist),
          Expanded(
            child: _buildSongsList(playlist),
          ),
        ],
      ),
      bottomNavigationBar: const BottomPlayer(),
    );
  }
}
```

---

## 🔄 ReorderPlaylistScreen - Reordenamiento Drag & Drop

### 🎯 Propósito
Interfaz especializada para reordenar canciones dentro de una playlist usando gestos drag & drop.

### 📍 Ubicación
`lib/presentation/screens/reorder_playlist_screen.dart`

### ✨ Características Avanzadas
- **ReorderableListView**: Componente nativo optimizado
- **Feedback Visual**: Indicadores de drag state
- **Persistencia Automática**: Guarda cambios inmediatamente
- **Cancelación**: Opción para descartar cambios

### 🎮 Implementación de Reordenamiento
```dart
class ReorderPlaylistScreen extends StatefulWidget {
  final String playlistId;
  
  @override
  State<ReorderPlaylistScreen> createState() => _ReorderPlaylistScreenState();
}

class _ReorderPlaylistScreenState extends State<ReorderPlaylistScreen> {
  late List<SongModel> _songs;
  bool _hasChanges = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildReorderAppBar(),
      body: ReorderableListView.builder(
        itemCount: _songs.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return _buildReorderableItem(song, index);
        },
      ),
    );
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final song = _songs.removeAt(oldIndex);
      _songs.insert(newIndex, song);
      _hasChanges = true;
    });
  }
  
  Widget _buildReorderableItem(SongModel song, int index) {
    return Card(
      key: ValueKey(song.id),
      child: ListTile(
        leading: Icon(Icons.drag_handle),
        title: Text(song.title),
        subtitle: Text(song.artist ?? 'Unknown Artist'),
        trailing: Text('${index + 1}'),
      ),
    );
  }
}
```

---

## ⚙️ SettingsScreen - Configuraciones Modulares

### 🎯 Propósito
Centro de control para todas las configuraciones de la aplicación, organizado en secciones modulares.

### 📍 Ubicación
`lib/presentation/screens/settings_screen.dart`

### ✨ Características Avanzadas
- **Secciones Modulares**: Componentes especializados por tipo de configuración
- **Temas Dinámicos**: Preview en tiempo real de cambios
- **Validación de Entrada**: Validadores en tiempo real
- **Configuración por Plataforma**: Opciones específicas iOS/Android

### 🏗️ Arquitectura Modular
```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/library'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Secciones modulares especializadas
            AppearanceSection(),
            const SizedBox(height: 16),
            
            LanguageSection(),
            const SizedBox(height: 16),
            
            // Sección específica para iOS
            if (Platform.isIOS) ...[
              LocalMusicSection(),
              const SizedBox(height: 16),
            ],
            
            SecuritySection(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomPlayer(),
    );
  }
}
```

### 📱 Secciones Especializadas

#### AppearanceSection
- **Selector de Tema**: Claro/Oscuro/Sistema
- **Color Primario**: Picker con 16 colores predefinidos  
- **Tamaño de Fuente**: Slider con preview en tiempo real

#### LanguageSection  
- **Selector de Idioma**: Español/Inglés con flags
- **Aplicación Inmediata**: Cambio sin restart

#### LocalMusicSection (Solo iOS)
- **Selector de Carpeta**: FilePicker integration
- **Estado de Importación**: Progreso y estadísticas
- **Gestión de Archivos**: Limpieza y re-escaneo

#### SecuritySection
- **Autenticación Biométrica**: Toggle con validación
- **Configuraciones de Privacidad**: Controles granulares

---

## 🎨 CARACTERÍSTICAS TRANSVERSALES

### 🎭 Hero Animations
**Transiciones fluidas entre pantallas relacionadas**:
```dart
// BottomPlayer → PlayerScreen
Hero(
  tag: 'player_container',
  child: Material(
    type: MaterialType.transparency,
    child: PlayerContainer(),
  ),
)
```

### 📱 Responsive Design
**Adaptación automática por dispositivo**:
```dart
Widget build(BuildContext context) {
  return context.isMobile 
    ? _buildMobileLayout()
    : context.isTablet
        ? _buildTabletLayout()
        : _buildDesktopLayout();
}
```

### 🔄 BLoC Integration
**Estado reactivo en todas las pantallas**:
```dart
// Patrón estándar de escucha selectiva
BlocBuilder<PlayerCubit, PlayerState>(
  buildWhen: (previous, current) => 
    previous.currentSong?.id != current.currentSong?.id,
  builder: (context, state) => SongDisplay(state.currentSong),
)
```

### 🎯 Navigation Management
**Control granular de navegación**:
```dart
PopScope(
  canPop: _canNavigateBack(),
  onPopInvoked: (didPop) => _handleBackNavigation(didPop),
  child: screen,
)
```

---

## 🚀 OPTIMIZACIONES DE RENDIMIENTO

### 🔄 Lazy Loading
- **Inicialización diferida** de widgets pesados
- **Carga progresiva** de listas largas
- **Estados de loading** específicos por sección

### 📊 State Management Optimization  
- **BuildWhen selectivo** para reconstrucciones mínimas
- **BlocSelector** para propiedades específicas
- **Debouncing** en búsquedas y filtros

### 🎨 UI Performance
- **Hero animations** optimizadas
- **Cached network images** para artwork
- **List view optimization** con itemExtent

Este sistema de pantallas demuestra una arquitectura madura y bien estructurada que proporciona una experiencia de usuario fluida y consistente a través de toda la aplicación, con optimizaciones específicas para diferentes plataformas y contextos de uso.