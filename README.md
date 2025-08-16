# 🎵 Sonofy

**Sonofy** es un moderno e intuitivo reproductor de audio desarrollado en Flutter que permite a los usuarios disfrutar de su biblioteca musical local con una experiencia de usuario elegante y funcional.

## 📱 Características Principales

- 🎮 **Reproducción Completa**: Controles avanzados de play/pause, anterior/siguiente, repetir y aleatorio
- 📊 **Control de Progreso**: Slider interactivo con información temporal en tiempo real
- 🎨 **Personalización Avanzada**: Temas claro/oscuro/automático con colores primarios personalizables
- 📏 **Escalado de Fuente**: Múltiples niveles de tamaño de texto
- 🌍 **Multiidioma**: Soporte para español e inglés con sistema extensible
- 📚 **Biblioteca Musical**: Escaneo automático y gestión inteligente de canciones
- 🔒 **Seguridad**: Preparado para autenticación biométrica
- ⏰ **Temporizador de Sueño**: Control automático de apagado con opciones avanzadas
- 🍎 **🆕 iPod Library Nativa**: Soporte completo para URLs iPod library en iOS
- 🔄 **🆕 Reproductor Dual**: Sistema inteligente AudioPlayers + MPMusicPlayerController
- 🔒 **🆕 Protección DRM**: Verificación automática de archivos protegidos

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| **Flutter** | SDK ^3.8.1 | Framework de desarrollo |
| **flutter_bloc** | ^9.1.1 | Gestión de estado |
| **go_router** | ^16.1.0 | Navegación declarativa |
| **audioplayers** | ^6.5.0 | Reproducción de audio |
| **on_audio_query_pluse** | ^2.9.4 | Metadata musical |
| **easy_localization** | ^3.0.8 | Internacionalización |
| **shared_preferences** | ^2.5.3 | Persistencia local |

## 🏗️ Arquitectura

Sonofy implementa **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── core/          # Utilidades, temas, rutas y servicios compartidos
├── data/          # Implementaciones de repositorios y modelos
├── domain/        # Interfaces de repositorios y lógica de negocio
└── presentation/  # UI, widgets, BLoCs y pantallas
```

### Capas Principales

- **Presentation**: Manejo de UI y gestión de estado con BLoC
- **Domain**: Contratos e interfaces de repositorios
- **Data**: Implementaciones concretas y persistencia
- **Core**: Servicios compartidos y configuraciones

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK ^3.8.1
- Dart SDK incluido en Flutter
- Android Studio / VS Code
- Dispositivo/emulador Android o iOS

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd sonofy
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar iconos de aplicación**
```bash
flutter pub run flutter_launcher_icons:main
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 📱 Pantallas Principales

### 🎬 Splash Screen
Pantalla de carga inicial con branding de la aplicación.

### 📚 Library Screen (`/library`)
- Lista completa de canciones del dispositivo
- Reproductor mini siempre visible
- Navegación intuitiva y rápida

### 🎵 Player Screen (`/library/player`)
- Reproductor de pantalla completa
- Visualización de carátulas y metadata
- Controles completos de reproducción
- Acceso a modales de letras, playlist y temporizador

### ⚙️ Settings Screen (`/settings`)
- Configuración de apariencia y temas
- Personalización de colores y fuentes
- Configuración de idioma y seguridad

## 🎨 Sistema de Temas

Sonofy incluye un sistema de temas dinámico y personalizable:

- **Temas Base**: Claro, oscuro y automático
- **Colores Personalizables**: Color primario configurable con generación automática de paleta
- **Tipografía**: Fuente SF UI Display con escalado ajustable
- **Iconografía**: Font Awesome completo con múltiples pesos

## 🌍 Internacionalización

### Idiomas Soportados
- 🇪🇸 **Español** (por defecto)
- 🇺🇸 **Inglés**

### Archivos de Traducciones
- `assets/translations/es.json` - Traducciones en español
- `assets/translations/en.json` - Traducciones en inglés

## 🔧 Funcionalidades Destacadas

### Reproductor de Audio
- Control completo de reproducción (play/pause/stop)
- Navegación por playlist (anterior/siguiente)
- Modos de repetición (uno, todos, ninguno)
- Modo aleatorio inteligente
- Visualización de progreso con control manual
- **🆕 Soporte iPod Library**: Reproducción nativa de biblioteca iOS
- **🆕 Verificación DRM**: Protección automática contra archivos protegidos
- **🆕 Method Channels**: 9 métodos nativos iOS implementados

### Temporizador de Sueño
- Configuración de duración (1-180 minutos)
- Opción de esperar el final de la canción
- Estados visuales claros del temporizador
- Pausado automático inteligente

### Gestión Musical
- Escaneo automático de biblioteca
- Manejo inteligente de permisos
- Visualización de carátulas y metadata
- Soporte para múltiples formatos de audio

## 📚 Documentación Completa

Para documentación técnica detallada, consulta la carpeta `documentation/`:

- [**Arquitectura**](documentation/architecture/) - Patrones de diseño y estructura
- [**API y Código**](documentation/api/) - Documentación de repositorios y estados
- [**Componentes**](documentation/components/) - Widgets y sistema de temas
- [**Guías**](documentation/guides/) - Setup, contribución y deployment

## 🤝 Contribución

Este proyecto sigue estándares de código limpio y arquitectura escalable. Para contribuir:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

### Convenciones de Código
- **Nomenclatura**: camelCase para variables, PascalCase para clases
- **Documentación**: Comentarios en español para funciones importantes
- **Linting**: Usar `flutter analyze` antes de commit
- **Testing**: Tests unitarios para lógica de negocio

## 📄 Licencia

Este proyecto es privado y está destinado únicamente para fines educativos y demostrativos.

---

**Versión**: 3.0.0  
**Plataforma**: Flutter (multiplataforma) con integración nativa iOS  
**Estado**: En desarrollo activo  
**Última actualización**: Agosto 2024 - iPod Library Integration

### 🆕 Novedades v3.0.0
- ✅ Integración completa iPod Library (iOS)
- ✅ Sistema dual de reproducción
- ✅ 9 Method Channels implementados
- ✅ Verificación DRM automática
- ✅ Compatibilidad total Android/iOS
