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
- [Guías](./guides/)
  - [Configuración de Desarrollo](./guides/development-setup.md)
  - [Guía de Contribución](./guides/contributing.md)
  - [Resumen de Funcionalidades](./guides/features-overview.md)
  - [Funcionalidades por Plataforma](./guides/platform-specific-features.md)
  - [Integración iPod Library](./guides/ipod-library-integration.md)
- [Componentes](./components/)
  - [Widgets Comunes](./components/common-widgets.md)
  - [Pantallas](./components/screens.md)
  - [Sistema de Temas](./components/theming-system.md)

## 🚀 Características Principales

### Reproducción de Audio
- ⏯️ Control de reproducción (play/pause/stop)
- ⏭️ Navegación entre canciones (anterior/siguiente)
- 📊 Slider de progreso con control manual
- 🖼️ Visualización de carátulas de álbum
- 🔀 Modo aleatorio (shuffle) inteligente
- 🔁 Modos de repetición (uno, todos, ninguno)
- 🍎 **NUEVO**: Soporte nativo para URLs iPod Library (iOS)
- 🎵 **NUEVO**: Reproductor dual (AudioPlayers + MPMusicPlayerController)
- 🔒 **NUEVO**: Verificación automática de protección DRM

### Gestión de Biblioteca Híbrida
- 📁 **iOS**: Escaneo automático + selección manual de carpetas (FilePicker)
- 🤖 **Android**: Escaneo automático completo (on_audio_query_pluse)
- 📋 Lista organizada de canciones con fuentes combinadas
- 🔍 Búsqueda de canciones (próximamente)
- 📱 Reproductor mini en la interfaz principal
- 🎯 Experiencia optimizada por plataforma
- 🍎 **NUEVO**: Integración completa con biblioteca nativa de iOS
- 🔄 **NUEVO**: Sistema dual de reproducción inteligente

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
| Metadata Musical | on_audio_query_pluse | ^2.9.4 |
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

**Versión de Documentación**: 3.0.0  
**Última Actualización**: Agosto 2024 - Integración iPod Library Nativa  
**Mantenedor**: Equipo de Desarrollo Sonofy

## 🆕 Novedades v3.0.0 - iPod Library Integration

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