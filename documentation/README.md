# Sonofy - Documentación Técnica

## 🎵 Descripción General

**Sonofy** es un moderno e intuitivo reproductor de audio desarrollado en Flutter que permite a los usuarios disfrutar de su biblioteca musical local con una experiencia de usuario elegante y funcional.

## 📋 Tabla de Contenidos

- [Arquitectura](./architecture/)
  - [Patrones de Diseño](./architecture/design-patterns.md)
  - [Estructura del Proyecto](./architecture/project-structure.md)
  - [Clean Architecture](./architecture/clean-architecture.md)
- [API y Código](./api/)
  - [Repositorios](./api/repositories.md)
  - [Use Cases](./api/usecases.md)
  - [Estados y Cubits](./api/state-management.md)
  - [Modelos de Datos](./api/data-models.md)
  - [**🔀 API del Sistema de Reproducción**](./api/player-api.md)
- [Guías](./guides/)
  - [Configuración de Desarrollo](./guides/development-setup.md)
  - [Guía de Contribución](./guides/contributing.md)
  - [Resumen de Funcionalidades](./guides/features-overview.md)
  - [Funcionalidades por Plataforma](./guides/platform-specific-features.md)
  - [Integración iPod Library](./guides/ipod-library-integration.md)
  - [**🆕 Sistema de Playlists**](./guides/playlist-system-guide.md)
  - [**🆕 Control de Velocidad de Reproducción**](./guides/playback-speed-system.md)
  - [**🔀 Sistema de Shuffle Inteligente**](./guides/shuffle-system-guide.md)
  - [**✨ Internacionalización y Traducciones**](./guides/internationalization-guide.md)
- [Componentes](./components/)
  - [Widgets Comunes](./components/common-widgets.md)
  - [Pantallas](./components/screens.md)
  - [Sistema de Temas](./components/theming-system.md)
  - [**✨ Sistema de Modales Contextuales**](./components/modal-system.md)
  - [**🔀 Sistema de Reproducción Completo**](./components/player-system.md)

## ✨ Actualizaciones Recientes

### Sistema de Modales Contextuales (2024)
- **Opciones inteligentes**: Solo muestra acciones relevantes según el contexto
- **Nuevas opciones de cola**: "Reproducir a continuación", "Agregar a la cola", "Quitar de la cola"  
- **Gestión avanzada de playlist**: Opciones contextuales específicas para cada situación
- **UX mejorada**: Elimina confusión mostrando solo opciones aplicables

### Componentes Rediseñados
- **SongCard renovado**: Callbacks externos para flexibilidad contextual
- **PlayerCubit extendido**: Nuevos métodos para gestión de cola
- **19 nuevas traducciones**: Soporte completo en español e inglés

## 🚀 Características Principales

### Reproducción de Audio
- ⏯️ Control de reproducción (play/pause/stop)
- ⏭️ Navegación entre canciones (anterior/siguiente)
- 📊 Slider de progreso con control manual
- 🖼️ Visualización de carátulas de álbum
- 🔀 **NUEVO**: Modo aleatorio (shuffle) inteligente con canción actual al inicio
- 🔁 **MEJORADO**: Modos de repetición con auto-advance inteligente (uno, todos, ninguno)
- 🍎 **NUEVO**: Soporte nativo para URLs iPod Library (iOS)
- 🎵 **MEJORADO**: Reproductor dual multiplataforma (iOS: MPMusicPlayerController + AudioPlayers, Android: NativeMediaService + AudioPlayers)
- 🤖 **NUEVO**: MediaSession nativo Android con controles automáticos del sistema
- 🔒 **NUEVO**: Verificación automática de protección DRM (iOS)
- 📋 **NUEVO**: Sistema completo de gestión de playlists
- 🔄 **NUEVO**: Sistema de ordenamiento personalizable (10 opciones)
- 🚀 **NUEVO**: Control de velocidad de reproducción nativo (0.5x-2.0x)

### Gestión de Biblioteca Híbrida
- 📁 **iOS**: Escaneo automático + selección manual de carpetas (FilePicker)
- 🤖 **Android**: Escaneo automático completo (on_audio_query_pluse) + reproductor nativo
- 📋 Lista organizada de canciones con fuentes combinadas
- 🔍 Búsqueda de canciones (próximamente)
- 📱 Reproductor mini en la interfaz principal
- 🎯 Experiencia optimizada por plataforma
- 🍎 **NUEVO**: Integración completa con biblioteca nativa de iOS
- 🤖 **NUEVO**: MediaSession nativo Android para archivos locales
- 🔄 **MEJORADO**: Sistema dual de reproducción inteligente multiplataforma
- 📊 **NUEVO**: Ordenamiento avanzado con persistencia automática
- 🚀 **NUEVO**: Control de velocidad multiplataforma con persistencia

### Temporizador de Sueño
- ⏰ Configuración de duración (1-180 minutos)
- ⏱️ Opciones predeterminadas (15min, 30min, 45min, 1h)
- 🎵 Opción de esperar al final de la canción
- 📊 Slider personalizado con vista previa
- ❌ Cancelación en cualquier momento

### Personalización
- 🌙 Temas claro/oscuro/automático
- 🎨 Selector de color primario personalizable
- 📏 Escalado de fuente ajustable (8 niveles)
- 🔐 Configuración de seguridad biométrica

### Internacionalización
- 🇪🇸 Español (por defecto)
- 🇺🇸 Inglés
- 📝 Sistema de traducciones extensible

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Versión |
|-----------|------------|---------|
| Framework | Flutter | SDK ^3.8.1 |
| Gestión de Estado | flutter_bloc | ^9.1.1 |
| Navegación | go_router | ^16.1.0 |
| Audio | audioplayers | ^6.5.0 |
| Audio Nativo Android | NativeMediaService + MediaPlayer | - |
| Audio Nativo iOS | MPMusicPlayerController | - |
| Metadata Musical | on_audio_query_pluse | ^2.9.4 |
| MediaSession Android | androidx.media:media | 1.4.3 |
| Selección de Archivos | file_picker | ^10.3.1 (Solo iOS) |
| Internacionalización | easy_localization | ^3.0.8 |
| Persistencia | shared_preferences | ^2.5.3 |

## 📱 Pantallas Principales

1. **Splash Screen** - Pantalla de carga inicial
2. **Library Screen** - Biblioteca principal de música
3. **Player Screen** - Reproductor de pantalla completa
4. **Settings Screen** - Configuraciones de la aplicación

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── core/          # Configuraciones, utilidades y servicios compartidos
├── data/          # Implementaciones de repositorios y modelos
├── domain/        # Interfaces de repositorios y lógica de negocio
└── presentation/  # UI, widgets, BLoCs y pantallas
```

## 📖 Convenciones de Código

- **Nomenclatura**: camelCase para variables y métodos, PascalCase para clases
- **Documentación**: Comentarios en español para documentación interna
- **Estructura**: Organización modular por características
- **Testing**: Tests unitarios para lógica de negocio
- **Lint**: Uso de flutter_lints para mantener calidad del código

## 🤝 Contribución

Para contribuir al proyecto, consulta la [Guía de Contribución](./guides/contributing.md).

## 📄 Licencia

Este proyecto es privado y está destinado únicamente para fines educativos y demostrativos.

## 📞 Contacto

Para consultas técnicas o reportar problemas, por favor revisa la documentación correspondiente en las carpetas específicas.

---

**Versión de Documentación**: 4.0.0  
**Última Actualización**: Septiembre 2024 - MediaSession Nativo Android  
**Mantenedor**: Equipo de Desarrollo Sonofy

## 🆕 Novedades v4.0.0 - MediaSession Nativo Android

### Sistema MediaSession Completo
- **🤖 NativeMediaService**: Servicio nativo MediaPlayer con integración MediaSession
- **📱 Controles automáticos**: Panel de notificaciones igual que Spotify/YouTube Music
- **🎛️ Service Binding**: Comunicación bidireccional MainActivity ↔ MediaService
- **🔔 Foreground Service**: Reproducción sin interrupciones en background
- **🎧 Controles físicos**: Auriculares Bluetooth y botones físicos del dispositivo
- **🚗 Android Auto**: Compatibilidad automática para controles de vehículo

### Eliminación de audio_service
- **❌ Retirada audio_service**: Eliminación completa de la dependencia externa
- **✅ MediaSession nativo**: Implementación directa con AndroidX MediaCompat
- **⚡ Performance mejorada**: Menos overhead, comunicación más eficiente
- **🛡️ Mayor estabilidad**: Control total sobre el comportamiento del reproductor

### Arquitectura Dual Mejorada
- **🍎 iOS**: MPMusicPlayerController + AudioPlayers (sin cambios)
- **🤖 Android**: NativeMediaService + AudioPlayers para máxima compatibilidad
- **🔄 Switching inteligente**: Detección automática de tipo de archivo
- **📊 Estado sincronizado**: Comunicación perfecta entre reproductores nativos y Flutter

## 🔄 Historial v3.4.0 - Sistema de Shuffle Inteligente

### Shuffle Revolucionario
- **🎯 Canción Actual al Inicio**: Al activar shuffle, la canción reproduciéndose se coloca como primera
- **🔄 Doble Lista Inteligente**: Sistema de playlist original + shuffle separadas
- **💾 Preservación de Secuencia**: PlaylistModal preserva orden shuffle existente
- **🎮 Navegación Consistente**: Auto-advance vs navegación manual diferenciados
- **⚡ RepeatMode Mejorado**: Lógica corregida para cada modo de repetición

### Auto-advance Inteligente por Modo
- **🚫 RepeatMode.none**: Se detiene al final, vuelve al inicio pausado
- **🔂 RepeatMode.one**: Repite canción actual indefinidamente
- **🔁 RepeatMode.all**: Continúa infinitamente en loop

### PlaylistModal Adaptativo
- **📋 Vista por Modo**: Muestra canciones según RepeatMode activo
- **🎯 Auto-scroll**: Reposicionamiento automático a canción actual
- **🔀 Orden Inteligente**: Respeta shuffle y muestra secuencia real de reproducción

### Arquitectura Robusta
- **🏗️ PlayerState Dual**: Maneja playlist original y shuffle separadamente
- **🔄 PlayerCubit Avanzado**: Métodos especializados para cada contexto
- **📱 UI Synchronizada**: Todos los componentes reflejan estado real
- **🧪 Documentación Completa**: Guías técnicas y API reference

## 🔄 Historial v3.3.0 - Control de Velocidad de Reproducción Nativo

### Sistema de Velocidad Multiplataforma
- **🚀 7 Velocidades Disponibles**: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 1.75x, 2.0x
- **🍎 Soporte Nativo iOS**: Integración con MPMusicPlayerController.currentPlaybackRate
- **🤖 Soporte AudioPlayers**: Control via AudioPlayer.setPlaybackRate() para archivos locales
- **🔄 Switching Inteligente**: Detección automática del reproductor activo
- **💾 Persistencia Automática**: Configuración guardada con SharedPreferences
- **🎨 UI Elegante**: Selector con indicador visual de velocidad actual

### Method Channels iOS Ampliados
- **📱 setPlaybackSpeed**: Control nativo de velocidad via Swift
- **📊 getPlaybackSpeed**: Obtener velocidad actual del reproductor nativo
- **🔧 Logging Completo**: Debug detallado para troubleshooting
- **⚡ Performance Optimizada**: Comunicación eficiente Flutter ↔ Swift

### Integración Completa con Estado
- **⚙️ Settings Model**: Campo playbackSpeed con persistencia
- **🎵 PlayerCubit**: Métodos setPlaybackSpeed() y getPlaybackSpeed()
- **📱 SpeedOption Widget**: Modal completamente funcional con BLoC
- **🏗️ Clean Architecture**: Implementación siguiendo patrones establecidos

## 🔄 Historial v3.2.0 - Sistema de Ordenamiento Avanzado

### Ordenamiento Inteligente de Biblioteca
- **📊 10 Opciones de Ordenamiento**: Título, Artista, Álbum, Fecha Agregado, Duración (A-Z/Z-A)
- **💾 Persistencia Automática**: Configuración guardada con SharedPreferences
- **🎨 UI Dropdown Integrada**: Selector elegante en el modal de opciones
- **🔄 Aplicación Inmediata**: Cambios reflejados instantáneamente
- **🌍 Totalmente Traducido**: Soporte completo en español e inglés
- **🏗️ Arquitectura Robusta**: Enum OrderBy con lógica de ordenamiento integrada

### Integración Completa con Estado
- **⚙️ SettingsCubit**: Persistencia automática de preferencias
- **🎵 SongsCubit**: Aplicación de ordenamiento en todos los métodos
- **📱 OrderOption Widget**: Dropdown completamente funcional
- **🔧 Clean Architecture**: Separación clara de responsabilidades

## 🔄 Historial v3.1.0 - Playlist Management System

### Sistema Completo de Playlists
- **📋 Gestión CRUD**: Crear, editar, eliminar y gestionar playlists
- **🎶 Integración Total**: Agregar/quitar canciones desde cualquier pantalla
- **💾 Persistencia Local**: Almacenamiento con SharedPreferences
- **🎨 UI Unificada**: Modales consistentes y responsive al teclado
- **🏗️ Clean Architecture**: Implementación siguiendo patrones establecidos

### Sistema de Modales Mejorado
- **🔧 modalView() Unificado**: Una función para todos los modales
- **⌨️ Responsive al Teclado**: Elevación automática al aparecer teclado
- **🎭 Animaciones Suaves**: Transiciones optimizadas (100ms)
- **📱 Adaptativo**: Soporte para BottomPlayer cuando sea necesario
- **🧹 Código Limpio**: -87% menos líneas de código por modal

## 🔄 Historial v3.0.0 - iPod Library Integration

### Reproductor Dual Nativo iOS
- **🎵 MPMusicPlayerController**: Reproductor nativo para URLs `ipod-library://`
- **📱 AudioPlayers**: Reproductor Flutter para archivos regulares (.mp3, etc.)
- **🔄 Switching Inteligente**: Detección automática del tipo de fuente
- **🔒 Verificación DRM**: Protección automática contra archivos protegidos

### Method Channels Completos
- **✅ 9 métodos nativos** implementados en Swift
- **⏯️ Control total**: play, pause, resume, stop, seek
- **📊 Monitoreo**: posición actual, duración, estado
- **🔍 Verificación**: DRM protection check

### Compatibilidad Multiplataforma
- **🍎 iOS**: Soporte completo para iPod Library + archivos locales
- **🤖 Android**: Fallback graceful, toda funcionalidad mantenida
- **🛡️ Robustez**: Sin errores en ninguna plataforma

## 🔄 Novedades v2.0.0

### Arquitectura Híbrida por Plataforma
- **🍎 iOS**: FilePicker + on_audio_query_pluse para máxima flexibilidad
- **🤖 Android**: Solo on_audio_query_pluse para simplicidad óptima
- **🔧 Dependency Injection Condicional**: Use Cases opcionales según plataforma
- **🎯 UX Optimizada**: Experiencia nativa para cada sistema operativo

Consulta la [documentación completa de funcionalidades por plataforma](./guides/platform-specific-features.md) para más detalles.