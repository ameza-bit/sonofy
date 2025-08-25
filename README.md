# 🎵 Sonofy - Reproductor Musical Avanzado

**Sonofy** es un sofisticado reproductor de audio desarrollado en Flutter que combina **Clean Architecture**, **reproducción híbrida cross-platform**, y **funcionalidades avanzadas** para crear una experiencia musical de clase mundial.

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%7C%20BLoC-green.svg)
![License](https://img.shields.io/badge/License-Educational-orange.svg)

---

## 🌟 Características Destacadas

### 🎧 **Reproductor Híbrido Avanzado**
- **Dual Playlist Management**: Sistema inteligente con playlist original + shuffle separadas
- **Reproducción Nativa iOS**: Integración con iPod Library usando MPMusicPlayerController  
- **Fallback Cross-Platform**: AudioPlayer como respaldo universal
- **Sleep Timer Condicional**: Modo fijo vs "esperar al final de canción"
- **Control de Velocidad**: Ajuste preciso 0.5x - 2.0x sincronizado cross-platform

### 📚 **Biblioteca Musical Inteligente**
- **Carga Progresiva con Streams**: Feedback visual en tiempo real durante importación
- **Soporte Multi-Formato**: MP3, FLAC, WAV, AAC, OGG, M4A con metadatos reales
- **Sistema de Caché Avanzado**: Persistencia inteligente de duraciones extraídas
- **Diferenciación por Plataforma**: iOS (carpetas + dispositivo) vs Android (automático)
- **Búsqueda Interactiva**: Filtrado en tiempo real sin delay

### 🎨 **Sistema de Temas Dinámico**
- **16 Colores Primarios**: Paleta musical especializada con generación automática de variantes
- **Responsive Design**: Adaptación móvil/tablet/desktop con breakpoints inteligentes
- **SF UI Display Typography**: Sistema tipográfico profesional con escalado configurable
- **FontAwesome Completo**: 7 familias de iconos sin restricciones de aspecto

### 📋 **Gestión Avanzada de Playlists**
- **CRUD Completo**: Crear, editar, eliminar con validación y recovery
- **Persistencia Robusta**: JSON + SharedPreferences con sistema de backup
- **Reordenamiento Drag & Drop**: Interfaz especializada para reorganización
- **Sistema Contextual**: Opciones diferenciadas según contexto de uso

---

## 🏗️ Arquitectura de Clase Mundial

Sonofy implementa una **Clean Architecture** avanzada optimizada para aplicaciones musicales:

```mermaid
graph TD
    A[Presentation Layer] -->|BLoC Pattern| B[Domain Layer]  
    C[Data Layer] -->|Repositories| B
    D[Core Layer] -->|Extensions & Utils| A
    D -->|Services & Themes| C
    
    A -->|4 Specialized Cubits| E[Player, Songs, Playlists, Settings]
    B -->|10 Use Cases| F[Pure Business Logic]
    C -->|Platform Specific| G[iOS: iPod + Local | Android: Query Only]
```

### 📁 Estructura Modular

```
lib/
├── core/           # 🔧 Infraestructura especializada (35 archivos)
│   ├── constants/  # Breakpoints responsive y espaciado escalonado
│   ├── enums/      # Enums con lógica de negocio (Language, OrderBy)
│   ├── extensions/ # 4 extensiones contextuales reactivas
│   ├── routes/     # GoRouter con transiciones especializadas
│   ├── services/   # Servicios singleton con limpieza inteligente  
│   ├── themes/     # 6 temas especializados + gradientes dinámicos
│   ├── transitions/# Transiciones cinematográficas personalizadas
│   └── utils/      # 12 utilidades avanzadas cross-platform
├── data/           # 💾 Implementaciones con integraciones nativas
│   ├── models/     # Modelos ricos con lógica de negocio integrada
│   └── repositories/ # 4 repos con comportamiento diferenciado por plataforma
├── domain/         # 🎯 Lógica de negocio pura (contratos estables)
│   ├── repositories/ # Interfaces abstractas sin dependencias
│   └── usecases/   # 10 casos de uso especializados
└── presentation/   # 🎨 UI reactiva con componentes especializados
    ├── blocs/      # 4 Cubits con estados inmutables complejos
    ├── screens/    # 6 pantallas con navegación avanzada
    ├── views/      # Vistas modulares para configuraciones
    └── widgets/    # 4 categorías de widgets especializados
        ├── common/     # 7 componentes base reutilizables
        ├── library/    # 8 widgets específicos biblioteca musical
        ├── options/    # 21 opciones contextuales inteligentes
        └── player/     # 6 controles avanzados reproducción
```

---

## 🚀 Tecnologías y Dependencias

| Categoría | Tecnología | Versión | Propósito Especializado |
|-----------|------------|---------|------------------------|
| **Framework** | Flutter SDK | ^3.8.1 | Desarrollo multiplataforma |
| **State Management** | flutter_bloc | ^9.1.1 | Gestión reactiva con Cubit pattern |
| **Navigation** | go_router | ^16.1.0 | Navegación declarativa con rutas tipadas |
| **Audio Core** | audioplayers | ^6.5.0 | Reproductor universal cross-platform |
| **Music Library** | on_audio_query_pluse | ^2.9.4 | Metadata y consultas musicales |
| **Internationalization** | easy_localization | ^3.0.8 | Sistema de traducciones dinámico |  
| **Persistence** | shared_preferences | ^2.5.3 | Almacenamiento local con migraciones |
| **File Management** | file_picker | ^10.3.1 | Selección de archivos/carpetas (iOS) |

### 🔧 Integraciones Nativas

- **iOS Method Channels**: 9 métodos nativos para iPod Library integration
- **Platform Detection**: 6 plataformas soportadas con fallbacks
- **Permission Management**: Automático con retry logic
- **DRM Protection**: Detección y validación de contenido protegido

---

## 📱 Sistema de Pantallas Avanzado

### 🚀 **SplashScreen** - Onboarding Inteligente
- **Inicialización Paralela**: Servicios críticos cargados simultáneamente
- **Recovery Automático**: Manejo graceful de fallos de inicialización  
- **Estados Visuales**: Progress indicators con animaciones fluidas

### 📚 **LibraryScreen** - Biblioteca Inteligente
- **Búsqueda Interactiva**: TextField expandible con filtrado en tiempo real
- **Carga Progresiva Visual**: Indicadores de progreso durante importación
- **Estados Diferenciados**: Loading, empty, error, progressive loading
- **Bottom Player Persistente**: Control musical siempre accesible

### 🎵 **PlayerScreen** - Experiencia Inmersiva  
- **UI Inmersiva**: AppBar transparente con artwork de fondo
- **Hero Animations**: Transiciones fluidas desde mini player
- **Controles Avanzados**: Sleep timer, velocidad, queue management
- **Modales Contextuales**: Sistema unificado para opciones especializadas

### 📋 **PlaylistScreen** - Gestión Completa
- **Header Dinámico**: Cover grid adaptativo según número de canciones
- **Gestión Contextual**: Opciones específicas por contexto de playlist
- **Estados de Error**: Manejo graceful de playlists inexistentes

### 🔄 **ReorderPlaylistScreen** - Drag & Drop Optimizado
- **ReorderableListView**: Interfaz nativa optimizada para reorganización  
- **Feedback Visual**: Indicadores de estado durante arrastre
- **Persistencia Automática**: Guardado inmediato de cambios

### ⚙️ **SettingsScreen** - Configuraciones Modulares
- **Secciones Especializadas**: Componentes modulares por tipo de configuración
- **Preview en Tiempo Real**: Cambios visuales instantáneos
- **Configuración por Plataforma**: Opciones específicas iOS/Android

---

## 🎨 Sistema de Widgets Especializado

### 🔧 **Common Widgets** - Componentes Base
- **CustomTextField**: Validación integrada con estados visuales avanzados
- **PrimaryButton/SecondaryButton**: Jerarquía visual con factory patterns
- **FontAwesome System**: Iconografía rica sin limitaciones de aspect ratio
- **SectionCard/SectionItem**: Organización consistente de contenido

### 🎵 **Library Widgets** - Componentes Musicales  
- **BottomPlayer**: Multi-BlocBuilder con progress streams en tiempo real
- **PlaylistCoverGrid**: Algoritmo recursivo para mostrar hasta 4 portadas
- **SongCard**: Estado visual inteligente para canción actualmente reproduciéndose

### 🎛️ **Options System** - Menús Contextuales Inteligentes
- **OptionsModal**: Strategy pattern con 4 contextos diferenciados
- **AddToPlaylistOption**: Lógica compleja con filtrado y estados UX
- **21 Opciones Especializadas**: Cada una con comportamiento específico

### 🎧 **Player Widgets** - Controles Avanzados
- **PlayerControl**: Iconografía dinámica según modos de repetición
- **PlayerSlider**: Interactividad fluida con drag state
- **PlaylistModal**: Visualización condicional según RepeatMode
- **SleepModal**: Estados múltiples con countdown en tiempo real

---

## 🎯 Funcionalidades Innovadoras

### 🧠 **Sistema de Shuffle Inteligente**
```dart
List<SongModel> _generateShufflePlaylist(List<SongModel> playlist, [SongModel? currentSong]) {
  final shuffled = List.of(playlist);
  shuffled.shuffle();
  
  // Canción actual siempre primera para continuidad
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

### ⏰ **Sleep Timer Condicional**  
- **Timer Fijo**: Countdown estándar con pausa inmediata
- **Modo Espera**: Espera al final de canción actual antes de pausar
- **Estados Visuales**: Diferenciación clara entre modos activo/esperando

### 📱 **Reproducción Híbrida iOS**
```dart
@override
Future<bool> play(String url) async {
  if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
    final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
    if (isDrmProtected) return false;

    final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
    if (success) _usingNativePlayer = true;
    return success;
  } else {
    // Fallback to AudioPlayer
    await player.play(DeviceFileSource(url));
    return isPlaying();
  }
}
```

### 🔄 **Carga Progresiva con Streams**
```dart  
await for (final song in _getLocalSongsUseCase.callStream()) {
  localSongs.add(song);
  loadedCount++;
  
  emit(state.copyWith(
    songs: _applySorting(allSongs),  
    localSongs: localSongs,
    loadedCount: loadedCount,
    isLoadingProgressive: loadedCount < totalFiles,
  ));
}
```

---

## 🚀 Instalación y Configuración

### 📋 Prerrequisitos
- **Flutter SDK**: ^3.8.1
- **Dart SDK**: Incluido en Flutter  
- **Android Studio / VS Code**: IDE con plugins Flutter
- **Dispositivo/Emulador**: iOS 12+ / Android API 21+

### ⚡ Instalación Rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/your-repo/sonofy.git
cd sonofy

# 2. Instalar dependencias  
flutter pub get

# 3. Generar iconos de lanzamiento
flutter pub run flutter_launcher_icons:main

# 4. Ejecutar aplicación
flutter run

# 5. [Opcional] Análisis de código
flutter analyze

# 6. [Opcional] Tests unitarios  
flutter test
```

### 🔧 Configuración por Plataforma

#### iOS Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>NSMediaLibraryUsageDescription</key>
<string>Sonofy necesita acceso a tu biblioteca musical para reproducir canciones</string>
```

#### Android Setup
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## 🧪 Testing y Calidad

### 🔍 Análisis Estático
```bash
# Linting con reglas estrictas
flutter analyze

# Formateo de código  
dart format .

# Verificar dependencias
flutter pub deps
```

### 🧪 Testing Strategy
- **Unit Tests**: Lógica de negocio en Domain layer
- **Widget Tests**: Componentes UI aislados  
- **Integration Tests**: Flujos completos end-to-end
- **BLoC Tests**: Estados y transiciones de Cubits

```dart
// Ejemplo de test para PlayerCubit
blocTest<PlayerCubit, PlayerState>(
  'emits [playing] when setPlayingSong is called',
  build: () => PlayerCubit(mockPlayerRepository),
  act: (cubit) => cubit.setPlayingSong([mockSong], mockSong),
  expect: () => [
    PlayerState(playlist: [mockSong], currentIndex: 0, isPlaying: true),
  ],
);
```

---

## 🌍 Internacionalización

### 🗣️ Idiomas Soportados
- 🇪🇸 **Español**: Idioma por defecto con terminología musical especializada  
- 🇺🇸 **Inglés**: Traducciones completas con contexto musical

### 📝 Sistema de Traducciones
```json
// assets/translations/es.json
{
  "player": {
    "play": "Reproducir",
    "pause": "Pausar", 
    "next_song": "Siguiente canción",
    "sleep_timer": "Temporizador de sueño"
  },
  "playlists": {
    "create": "Crear playlist",
    "add_song": "Agregar canción",
    "remove_song": "Quitar canción"
  }
}
```

### 🔧 Uso en Código
```dart
// Traducciones contextuales
Text(context.tr('player.shuffle_enabled'))

// Traducciones con parámetros  
Text(context.tr('playlist.song_count', args: [playlist.songCount.toString()]))
```

---

## 📚 Documentación Técnica Completa

La documentación está organizada en módulos especializados:

### 🏗️ [**Arquitectura**](documentation/architecture/)
- [Clean Architecture Implementada](documentation/architecture/clean-architecture.md)
- [Patrones de Diseño Aplicados](documentation/architecture/design-patterns.md)  
- [Estructura del Proyecto](documentation/architecture/project-structure.md)

### 🔧 [**APIs y Servicios**](documentation/api/)
- [Repositorios y Contratos](documentation/api/repositories.md)
- [Casos de Uso Especializados](documentation/api/usecases.md)
- [Gestión de Estado BLoC](documentation/api/state-management.md)
- [Modelos de Datos](documentation/api/data-models.md)

### 🎨 [**Componentes UI**](documentation/components/)
- [Sistema Completo de Widgets](documentation/components/comprehensive-widgets-system.md)
- [Pantallas Principales](documentation/components/screens-complete.md)  
- [Sistema de Temas](documentation/components/theming-system.md)
- [Modales y Opciones](documentation/components/modal-system.md)

### 📖 [**Guías de Desarrollo**](documentation/guides/)
- [Setup y Configuración](documentation/guides/development-setup.md)
- [Contribución al Proyecto](documentation/guides/contributing.md)
- [Guía de Características](documentation/guides/features-overview.md)
- [Internacionalización](documentation/guides/internationalization-guide.md)

---

## 🤝 Contribución

### 🎯 Convenciones de Desarrollo

#### Estructura de Commits
```
feat: agregar sistema de ecualizador avanzado
fix: corregir crash en reproducción shuffle  
docs: actualizar documentación de arquitectura
refactor: optimizar carga de biblioteca musical
test: añadir tests unitarios para PlayerCubit
```

#### Código Style Guide
```dart
// ✅ Nomenclatura correcta
class PlaylistRepository {
  Future<List<Playlist>> getAllPlaylists() async { ... }
}

// ✅ Documentación en español para funciones complejas
/// Genera una playlist shuffle manteniendo la canción actual como primera
/// para preservar la continuidad de reproducción
List<SongModel> _generateShufflePlaylist(List<SongModel> playlist) { ... }

// ✅ Estados inmutables con copyWith
PlayerState copyWith({
  List<SongModel>? playlist,
  bool? isPlaying,
}) => PlayerState(
  playlist: playlist ?? this.playlist,
  isPlaying: isPlaying ?? this.isPlaying,
);
```

### 🔄 Flujo de Contribución
1. **Fork** del repositorio principal
2. **Branch** para feature (`git checkout -b feature/ecualizador-avanzado`)
3. **Desarrollo** siguiendo Clean Architecture
4. **Tests** unitarios y de integración  
5. **Documentación** actualizada
6. **Pull Request** con descripción detallada

---

## 🎖️ Versioning y Releases

### 🚀 **Versión Actual: 4.0.0** *(Agosto 2024)*

#### 🆕 **Novedades v4.0.0 - "Advanced Architecture"**
- ✅ **Clean Architecture Completa**: 4 capas especializadas con 82 archivos organizados
- ✅ **Sistema de Widgets Avanzado**: 42 widgets especializados en 4 categorías  
- ✅ **BLoC Architecture**: 4 Cubits con estados inmutables complejos
- ✅ **Reproducción Híbrida**: AudioPlayer + MPMusicPlayerController nativo iOS
- ✅ **Sistema de Temas Dinámico**: 16 colores + generación automática de paletas
- ✅ **Navegación Declarativa**: GoRouter con 6 pantallas + transiciones especializadas

#### 📈 **Historial de Versiones**

**v3.2.0** - Multi-Format Audio Support
- Soporte para MP3, FLAC, WAV, AAC, OGG, M4A
- Carga progresiva con streams y feedback visual
- Sistema de caché inteligente para metadatos

**v3.1.0** - Playlist Management System  
- CRUD completo de playlists con persistencia
- Modales unificados con responsive design
- Navegación contextual avanzada

**v3.0.0** - iPod Library Integration
- Integración completa con biblioteca iPod nativa
- 9 Method Channels para comunicación iOS
- Verificación DRM y fallback automático

---

## 📄 Licencia y Contacto

### 📜 **Licencia**
Este proyecto es **privado y educacional**, desarrollado para demostrar implementación avanzada de Clean Architecture en Flutter con funcionalidades musicales especializadas.

### 📞 **Soporte y Contacto**
- **Documentación**: Consulta la carpeta `/documentation` para información técnica detallada
- **Issues**: Reporta bugs o solicita características usando el sistema de issues
- **Contribuciones**: Sigue las guías de contribución para pull requests

---

### 🔧 **Información Técnica**

| Atributo | Valor |
|----------|-------|
| **Arquitectura** | Clean Architecture + BLoC Pattern |
| **Plataformas** | iOS 12+ / Android API 21+ |
| **Lenguaje** | Dart 3.0+ |
| **Framework** | Flutter 3.8.1+ |
| **Estado** | ✅ Producción Ready |
| **Cobertura Tests** | En desarrollo |
| **Documentación** | ✅ Completa |

---

**Sonofy** - *"La arquitectura musical del futuro"* 🎵