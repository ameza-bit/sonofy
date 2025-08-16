# Funcionalidades de Sonofy

## 🎵 Visión General

Sonofy ofrece una experiencia completa de reproducción de audio con funcionalidades modernas y una interfaz intuitiva. Esta documentación detalla todas las características implementadas y planificadas.

## 🎮 Funcionalidades del Reproductor

### Reproducción Básica
**Estado**: ✅ Implementado

#### Controles de Reproducción
- **Play/Pause**: Control principal de reproducción
- **Stop**: Detener completamente la reproducción
- **Siguiente/Anterior**: Navegación por la playlist
- **Repetir**: Modo de repetición de canciones
- **Aleatorio**: Reproducción aleatoria

#### Implementación Técnica
```dart
// PlayerCubit - Controles principales
Future<void> togglePlayPause() async {
  final bool isPlaying = await _playerRepository.togglePlayPause();
  emit(state.copyWith(isPlaying: isPlaying));
}

Future<void> nextSong() async {
  var currentIndex = state.currentIndex;
  if (currentIndex < state.playlist.length - 1) {
    currentIndex = currentIndex + 1;
  } else {
    currentIndex = 0; // Volver al principio
  }
  final bool isPlaying = await _playerRepository.play(
    state.playlist[currentIndex].data,
  );
  emit(state.copyWith(currentIndex: currentIndex, isPlaying: isPlaying));
}
```

### Control de Progreso
**Estado**: ✅ Implementado

#### Características
- **Slider interactivo**: Control manual de posición
- **Indicador visual**: Progreso en tiempo real
- **Información temporal**: Tiempo actual y duración total

#### Ubicación en el Código
- **Widget**: `lib/presentation/widgets/player/player_slider.dart`
- **Lógica**: `lib/data/repositories/player_repository_impl.dart:33-45`

### Visualización de Metadata
**Estado**: ✅ Implementado

#### Información Mostrada
- **Título de la canción**
- **Artista/Compositor**
- **Carátula del álbum**
- **Duración**

#### Implementación
```dart
// PlayerScreen - Visualización de metadata
final songName = currentSong?.title ?? '';
final artistName = currentSong?.artist ?? currentSong?.composer ?? '';

QueryArtworkWidget(
  id: currentSong?.id ?? -1,
  type: ArtworkType.AUDIO,
  errorBuilder: (_, _, _) => Image.asset(context.imagePlaceholder),
)
```

## 📚 Gestión de Biblioteca Musical

### Escaneo Automático
**Estado**: ✅ Implementado

#### Características
- **Detección automática**: Escanea música del dispositivo al iniciar
- **Permisos inteligentes**: Solicita permisos solo cuando es necesario
- **Filtrado**: Solo archivos de audio válidos

#### Implementación Técnica
```dart
// SongsRepositoryImpl - Escaneo de canciones
Future<List<SongModel>> getSongsFromDevice() async {
  final bool canContinue = await _configureAudioQuery();
  
  if (!canContinue) {
    return []; // Sin permisos, retorna lista vacía
  }
  
  return _audioQuery.querySongs(); // Obtiene todas las canciones
}
```

### Funcionalidad Híbrida por Plataforma
**Estado**: ✅ Implementado

#### Estrategia Diferenciada
Sonofy implementa un enfoque híbrido que optimiza la experiencia para cada plataforma:

- **🍎 iOS**: FilePicker + on_audio_query_pluse (selección manual + automática)
- **🤖 Android**: Solo on_audio_query_pluse (acceso automático completo)

#### Características iOS
- **Selección manual de carpetas**: FilePicker nativo del sistema
- **Biblioteca del dispositivo**: on_audio_query_pluse para música nativa
- **Fuentes combinadas**: Integración de múltiples orígenes
- **Control granular**: Usuario decide qué carpetas incluir
- **Metadatos estimados**: Mp3FileConverter para archivos locales

#### Características Android
- **Acceso automático completo**: Solo on_audio_query_pluse
- **Sin configuración manual**: Experiencia simplificada
- **Biblioteca unificada**: Toda la música del dispositivo automáticamente
- **Menor complejidad**: Sin gestión manual de archivos

#### Implementación Técnica

```dart
// Lógica condicional en SongsRepository
Future<String?> selectMusicFolder() async {
  if (Platform.isIOS) {
    return await FilePicker.platform.getDirectoryPath();
  }
  return null; // Android no soporta selección manual
}

// Use Cases con comportamiento específico
Future<List<SongModel>> call() async {
  if (Platform.isAndroid) {
    return []; // Android no tiene canciones "locales" separadas
  }
  // Lógica específica de iOS...
}
```

#### Ubicación en el Código
- **Repository híbrido**: `lib/data/repositories/songs_repository_impl.dart`
- **Use Cases condicionales**: `lib/domain/usecases/get_local_songs_usecase.dart`
- **BLoC con null safety**: `lib/presentation/blocs/songs/songs_cubit.dart`
- **UI solo iOS**: `lib/presentation/views/settings/local_music_section.dart`
- **Dependency Injection**: `lib/main.dart` (condicional por plataforma)

#### Experiencia de Usuario

| Aspecto | iOS | Android |
|---------|-----|---------|
| **Configuraciones** | Sección "Música Local" visible | Sin configuraciones adicionales |
| **Fuentes de música** | Dispositivo + carpetas seleccionadas | Solo dispositivo (completo) |
| **Interacción** | Selección manual opcional | Completamente automático |
| **Complejidad** | Media (más control) | Baja (simplicidad) |

### Lista de Canciones
**Estado**: ✅ Implementado

#### Características
- **Vista de lista**: Diseño optimizado para navegación
- **Información completa**: Título, artista, duración
- **Carátulas**: Miniaturas de álbum
- **Interacción táctil**: Tap para reproducir

#### Ubicación
- **Pantalla**: `lib/presentation/screens/library_screen.dart`
- **Widget**: `lib/presentation/widgets/library/song_card.dart`

### Reproductor Mini
**Estado**: ✅ Implementado

#### Características
- **Siempre visible**: En la parte inferior de la biblioteca
- **Controles básicos**: Play/pause, información de canción
- **Transición suave**: Al reproductor completo

#### Ubicación
- **Widget**: `lib/presentation/widgets/library/bottom_player.dart`

## ⚙️ Sistema de Configuraciones

### Personalización de Apariencia
**Estado**: ✅ Implementado

#### Temas
- **Modo claro**: Diseño luminoso y elegante
- **Modo oscuro**: Interfaz oscura para uso nocturno
- **Modo automático**: Sigue configuración del sistema

#### Colores Personalizables
- **Color primario**: Selector de color personalizable
- **Aplicación dinámica**: Se aplica a toda la interfaz
- **Previsualización**: Vista previa en tiempo real

#### Implementación
```dart
// SettingsScreen - Selector de color
ColorPickerDialog(
  currentColor: state.settings.primaryColor,
  onColorSelected: (color) {
    context.read<SettingsCubit>().updatePrimaryColor(color);
  },
)
```

### Escalado de Fuente
**Estado**: ✅ Implementado

#### Características
- **Múltiples niveles**: Pequeño, normal, grande, extra grande
- **Aplicación global**: Afecta toda la tipografía
- **Persistencia**: Se mantiene entre sesiones

### Configuración de Seguridad
**Estado**: ✅ Implementado (Preparado)

#### Características Preparadas
- **Autenticación biométrica**: Huella dactilar/Face ID
- **Configuración persistente**: Guardado en preferencias
- **Interface lista**: UI implementada, lógica pendiente

## 🌍 Sistema de Internacionalización

### Idiomas Soportados
**Estado**: ✅ Implementado

#### Idiomas Actuales
- **Español**: Idioma principal y por defecto
- **Inglés**: Archivos preparados

#### Implementación
```dart
// Configuración en main.dart
EasyLocalization(
  supportedLocales: const [Locale('es')],
  path: 'assets/translations',
  fallbackLocale: const Locale('es'),
)
```

#### Archivos de Traducción
- **Español**: `assets/translations/es.json`
- **Inglés**: `assets/translations/en.json`

### Sistema Extensible
**Estado**: ✅ Implementado

#### Características
- **Fácil adición**: Nuevos idiomas con archivos JSON
- **Detección automática**: Puede seguir idioma del sistema
- **Fallback inteligente**: Español como respaldo

## 🎨 Sistema de Diseño

### Temas Dinámicos
**Estado**: ✅ Implementado

#### Características
- **Generación automática**: Colores secundarios desde primario
- **Consistencia**: Aplicación coherente en toda la app
- **Adaptabilidad**: Funciona con cualquier color primario

### Diseño Responsivo
**Estado**: ✅ Implementado

#### Características
- **Escalado inteligente**: Adaptación a diferentes tamaños
- **Extensiones útiles**: Helpers para responsive design
- **Optimización**: Diferentes layouts según dispositivo

### Transiciones Personalizadas
**Estado**: ✅ Implementado

#### Tipos Implementados
- **Fade**: Transición suave entre pantallas
- **Slide**: Deslizamiento del reproductor
- **Hero**: Animaciones compartidas entre pantallas

## 📱 Navegación y UX

### Sistema de Rutas
**Estado**: ✅ Implementado

#### Características
- **GoRouter**: Navegación declarativa moderna
- **Rutas anidadas**: Organización jerárquica
- **Parámetros**: Paso de datos entre pantallas
- **Redirecciones**: Lógica de navegación automática

#### Estructura de Rutas
```dart
// AppRoutes - Configuración de navegación
/                           # Splash Screen
├── /library               # Biblioteca Musical
│   └── /player           # Reproductor Completo
└── /settings             # Configuraciones
```

### Experiencia de Usuario
**Estado**: ✅ Implementado

#### Características UX
- **Splash Screen**: Carga inicial elegante
- **Estados de carga**: Indicadores visuales
- **Transiciones fluidas**: Navegación sin cortes
- **Retroalimentación**: Respuesta visual a acciones

## 🔮 Funcionalidades Futuras

### Búsqueda Avanzada
**Estado**: 📝 Planificado

#### Características Planificadas
- **Búsqueda por texto**: Título, artista, álbum
- **Filtros**: Por género, año, duración
- **Búsqueda rápida**: Sugerencias en tiempo real

### Playlists Personalizadas
**Estado**: 📝 Planificado

#### Características Planificadas
- **Creación de playlists**: Listas personalizadas
- **Gestión**: Añadir/eliminar canciones
- **Persistencia**: Guardado local

### Ecualizador
**Estado**: 📝 Planificado

#### Características Planificadas
- **Presets**: Configuraciones predefinidas
- **Manual**: Ajuste personalizado de frecuencias
- **Persistencia**: Configuración por canción/global

### Temporizador de Sueño
**Estado**: ✅ Implementado

#### Características Implementadas
- **Duración configurable**: 1-180 minutos con opciones predeterminadas (15min, 30min, 45min, 1h)
- **Duración personalizada**: Slider interactivo con botones rápidos
- **Esperar final de canción**: Opción para pausar al terminar la canción actual
- **Estados visuales**: Countdown activo y estado de espera
- **Cancelación**: Posibilidad de cancelar el timer en cualquier momento

#### Ubicación en el Código
- **Modal**: `lib/presentation/widgets/player/sleep_modal.dart`
- **Lógica**: `lib/presentation/blocs/player/player_cubit.dart:184-248`
- **Estados**: Incluidos en `PlayerState`

#### Casos de Uso
1. **Timer estándar**: Pausar después de X minutos exactos
2. **Esperar canción**: Pausar cuando termine la canción actual después del tiempo
3. **Timer personalizado**: Configurar duración específica entre 1-180 minutos

### Letras de Canciones
**Estado**: 🚧 En Desarrollo

#### Estado Actual
- **Modal preparado**: `lib/presentation/widgets/player/lirycs_modal.dart`
- **Integración pendiente**: Fuente de letras por definir
- **UI implementada**: Interface lista para usar

### Repetir y Aleatorio
**Estado**: ✅ Implementado

#### Características Implementadas
- **Modos de repetición**:
  - `RepeatMode.none`: Sin repetición
  - `RepeatMode.one`: Repetir canción actual
  - `RepeatMode.all`: Repetir toda la playlist
- **Modo aleatorio**: Reproducción shuffle con selección inteligente
- **Navegación inteligente**: Respeta los modos al cambiar de canción

#### Ubicación en el Código
- **Estados**: `lib/presentation/blocs/player/player_state.dart:3-4`
- **Lógica shuffle**: `lib/presentation/blocs/player/player_cubit.dart:148-182`
- **Controles UI**: `lib/presentation/widgets/player/player_control.dart`

### Compartir y Social
**Estado**: 📝 Planificado

#### Características Planificadas
- **Compartir canciones**: Enlaces y metadata
- **Estado del reproductor**: Compartir "ahora escuchando"
- **Integración social**: Conexión con redes sociales

## 📊 Analíticas y Métricas

### Estadísticas de Uso
**Estado**: 📝 Planificado

#### Métricas Planificadas
- **Canciones más reproducidas**
- **Tiempo de escucha**
- **Géneros favoritos**
- **Historial de reproducción**

## 🔧 Configuraciones Avanzadas

### Calidad de Audio
**Estado**: 📝 Planificado

#### Características Planificadas
- **Configuración de bitrate**
- **Formatos soportados**
- **Optimización por dispositivo**

### Gestión de Almacenamiento
**Estado**: 📝 Planificado

#### Características Planificadas
- **Cache inteligente**
- **Limpieza automática**
- **Configuración de límites**

---

Esta documentación se actualiza continuamente conforme se implementan nuevas funcionalidades. Cada característica incluye referencias al código para facilitar el desarrollo y mantenimiento.