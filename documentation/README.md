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
  - [Estados y Cubits](./api/state-management.md)
  - [Modelos de Datos](./api/data-models.md)
- [Guías](./guides/)
  - [Configuración de Desarrollo](./guides/development-setup.md)
  - [Guía de Contribución](./guides/contributing.md)
  - [Deployment](./guides/deployment.md)
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

### Gestión de Biblioteca
- 📁 Escaneo automático de música del dispositivo
- 📋 Lista organizada de canciones
- 🔍 Búsqueda de canciones (próximamente)
- 📱 Reproductor mini en la interfaz principal

### Personalización
- 🌙 Temas claro/oscuro/automático
- 🎨 Selector de color primario personalizable
- 📏 Escalado de fuente ajustable
- 🔐 Configuración de seguridad biométrica

### Internacionalización
- 🌍 Soporte multiidioma (actualmente español)
- 📝 Sistema de traducciones extensible

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Versión |
|-----------|------------|---------|
| Framework | Flutter | SDK ^3.8.1 |
| Gestión de Estado | flutter_bloc | ^9.1.1 |
| Navegación | go_router | ^16.1.0 |
| Audio | audioplayers | ^6.5.0 |
| Metadata Musical | on_audio_query_pluse | ^2.9.4 |
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

**Versión de Documentación**: 1.0.0  
**Última Actualización**: Agosto 2024  
**Mantenedor**: Equipo de Desarrollo Sonofy