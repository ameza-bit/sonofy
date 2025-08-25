# Estructura del Proyecto Sonofy

## 📁 Estructura General

```
sonofy/
├── android/                 # Configuración específica de Android
├── assets/                  # Recursos estáticos
│   ├── fonts/              # Fuentes personalizadas
│   ├── images/             # Imágenes de la aplicación
│   ├── screenshots/        # Capturas de pantalla
│   └── translations/       # Archivos de traducción
├── docs/                   # Documentación adicional
├── ios/                    # Configuración específica de iOS
├── lib/                    # Código fuente principal
├── linux/                  # Configuración para Linux
├── macos/                  # Configuración para macOS
├── web/                    # Configuración para Web
├── windows/                # Configuración para Windows
├── documentation/          # Documentación técnica del proyecto
├── pubspec.yaml           # Dependencias y configuración del proyecto
└── README.md              # Información básica del proyecto
```

## 🎯 Estructura del Código Fuente (`lib/`)

### Organización por Capas (Clean Architecture)

```
lib/
├── main.dart              # Punto de entrada de la aplicación
├── core/                  # Funcionalidades compartidas
├── data/                  # Capa de datos
├── domain/               # Capa de dominio
└── presentation/         # Capa de presentación
```

## 🏗️ Detalle de la Carpeta `core/`

```
core/
├── constants/
│   └── app_constants.dart        # Constantes globales de la aplicación
├── enums/
│   └── language.dart            # Enumeración de idiomas soportados
├── extensions/
│   ├── color_extensions.dart    # Extensiones para colores
│   ├── icon_extensions.dart     # Extensiones para iconos
│   ├── responsive_extensions.dart # Extensiones para diseño responsivo
│   └── theme_extensions.dart    # Extensiones para temas
├── routes/
│   └── app_routes.dart          # Configuración de rutas de navegación
├── services/
│   └── preferences.dart         # Servicio de preferencias locales
├── themes/
│   ├── app_colors.dart          # Definición de colores
│   ├── gradient_helpers.dart    # Utilidades para gradientes
│   ├── main_theme.dart          # Tema principal de la aplicación
│   ├── music_colors.dart        # Colores específicos del reproductor
│   ├── music_theme.dart         # Tema del reproductor
│   └── neutral_theme.dart       # Tema neutral/dark
├── transitions/
│   └── player_transition.dart   # Transiciones personalizadas
└── utils/
    ├── card_width.dart          # Utilidades para ancho de tarjetas
    ├── device_platform.dart     # Detección de plataforma
    ├── duration_minutes.dart    # Formateo de duración
    ├── mp3_file_converter.dart  # Conversor de archivos MP3 a SongModel
    ├── page_transition.dart     # Transiciones entre páginas
    ├── responsive_layout.dart   # Utilidades de diseño responsivo
    ├── toast.dart              # Utilidades para notificaciones
    └── validators.dart         # Validadores de formularios
```

## 💾 Detalle de la Carpeta `data/`

```
data/
├── models/
│   └── setting.dart             # Modelo de configuraciones
└── repositories/
    ├── player_repository_impl.dart    # Implementación del repositorio de reproductor
    ├── settings_repository_impl.dart  # Implementación del repositorio de configuraciones
    └── songs_repository_impl.dart     # Implementación del repositorio de canciones
```

## 🎯 Detalle de la Carpeta `domain/`

```
domain/
├── repositories/
│   ├── player_repository.dart      # Interfaz del repositorio de reproductor
│   ├── settings_repository.dart    # Interfaz del repositorio de configuraciones
│   └── songs_repository.dart       # Interfaz del repositorio de canciones
└── usecases/
    ├── get_local_songs_usecase.dart      # Caso de uso para obtener canciones locales
    ├── get_songs_from_folder_usecase.dart # Caso de uso para escanear carpetas MP3
    └── select_music_folder_usecase.dart   # Caso de uso para selección de carpetas
```

## 🖼️ Detalle de la Carpeta `presentation/`

```
presentation/
├── blocs/                    # Gestión de estado con BLoC
│   ├── player/
│   │   ├── player_cubit.dart     # Cubit del reproductor
│   │   └── player_state.dart     # Estados del reproductor
│   ├── settings/
│   │   ├── settings_cubit.dart   # Cubit de configuraciones
│   │   └── settings_state.dart   # Estados de configuraciones
│   └── songs/
│       ├── songs_cubit.dart      # Cubit de canciones
│       └── songs_state.dart      # Estados de canciones
├── screens/                  # Pantallas principales
│   ├── library_screen.dart      # Pantalla de biblioteca musical
│   ├── player_screen.dart       # Pantalla del reproductor
│   ├── settings_screen.dart     # Pantalla de configuraciones
│   └── splash_screen.dart       # Pantalla de splash
├── views/                    # Vistas específicas
│   └── settings/
│       ├── appearance_section.dart    # Sección de apariencia
│       ├── color_picker_dialog.dart   # Diálogo selector de color
│       ├── language_section.dart      # Sección de idiomas
│       ├── local_music_section.dart   # Sección de música local
│       └── security_section.dart      # Sección de seguridad
└── widgets/                  # Widgets reutilizables
    ├── common/              # Widgets comunes
    │   ├── custom_text_field.dart     # Campo de texto personalizado
    │   ├── font_awesome/              # Sistema de iconos Font Awesome
    │   │   ├── font_awesome_flutter.dart    # Implementación principal
    │   │   ├── name_icon_mapping.dart       # Mapeo de nombres a iconos
    │   │   └── src/                         # Fuentes del sistema
    │   │       ├── fa_icon.dart            # Widget de icono
    │   │       └── icon_data.dart          # Datos de iconos
    │   ├── primary_button.dart        # Botón primario
    │   ├── section_card.dart          # Tarjeta de sección
    │   ├── section_item.dart          # Elemento de sección
    │   └── secundary_button.dart      # Botón secundario
    ├── library/             # Widgets de biblioteca
    │   ├── bottom_clipper_container.dart  # Contenedor con recorte
    │   ├── bottom_player.dart             # Reproductor mini
    │   └── song_card.dart                 # Tarjeta de canción
    └── player/              # Widgets del reproductor
        ├── lirycs_modal.dart          # Modal de letras
        ├── player_bottom_modals.dart  # Modales inferiores (letras, playlist, sleep)
        ├── player_control.dart        # Controles del reproductor
        ├── player_slider.dart         # Slider de progreso
        ├── playlist_modal.dart        # Modal de playlist
        └── sleep_modal.dart           # Modal de temporizador de sueño
```

## 📦 Recursos (`assets/`)

```
assets/
├── fonts/
│   ├── font_awesome/        # Colección completa de Font Awesome
│   │   ├── fa-solid-900.ttf
│   │   ├── fa-regular-400.ttf
│   │   ├── fa-light-300.ttf
│   │   └── ...              # Múltiples variantes
│   └── sf-ui-display-cufonfonts/  # Fuente principal SF UI Display
│       ├── sf-ui-display-medium-*.otf
│       ├── sf-ui-display-bold-*.otf
│       └── ...
├── images/
│   ├── icon-white.png      # Icono principal de la app (blanco)
│   ├── piano.png           # Imagen de piano
│   ├── placeholder.png     # Imagen placeholder para carátulas
│   └── sonofy-icon.png    # Icono de la aplicación
├── screenshots/
│   ├── colors.png          # Captura del sistema de colores
│   ├── core.png           # Captura de funciones core
│   └── login.png          # Captura de login
└── translations/
    ├── en.json            # Traducciones en inglés
    └── es.json            # Traducciones en español
```

## 🎨 Convenciones de Nomenclatura

### Archivos y Carpetas
- **snake_case** para nombres de archivos: `player_screen.dart`
- **lowercase** para carpetas: `presentation/`, `widgets/`
- **Sufijos descriptivos**: `_screen.dart`, `_cubit.dart`, `_state.dart`

### Clases
- **PascalCase** para clases: `PlayerScreen`, `SongCard`
- **Sufijos por tipo**:
  - Screens: `*Screen` (ej: `LibraryScreen`)
  - Widgets: Descriptivo (ej: `SongCard`, `BottomPlayer`)
  - Cubits: `*Cubit` (ej: `PlayerCubit`)
  - States: `*State` (ej: `PlayerState`)
  - Repositories: `*Repository` o `*RepositoryImpl`

### Variables y Métodos
- **camelCase**: `currentSong`, `setPlayingSong()`
- **Booleanos** con prefijo `is`: `isPlaying`, `canContinue`

## 📱 Organización por Características

La estructura permite fácil identificación de componentes por funcionalidad:

### 🎵 Reproductor de Audio
- **Cubit**: `presentation/blocs/player/`
- **Pantalla**: `presentation/screens/player_screen.dart`
- **Widgets**: `presentation/widgets/player/`
- **Repositorio**: `domain/repositories/player_repository.dart`
- **Implementación**: `data/repositories/player_repository_impl.dart`

### 📚 Biblioteca Musical
- **Cubit**: `presentation/blocs/songs/`
- **Pantalla**: `presentation/screens/library_screen.dart`
- **Widgets**: `presentation/widgets/library/`
- **Repositorio**: `domain/repositories/songs_repository.dart`
- **Implementación**: `data/repositories/songs_repository_impl.dart`

### ⚙️ Configuraciones
- **Cubit**: `presentation/blocs/settings/`
- **Pantalla**: `presentation/screens/settings_screen.dart`
- **Vistas**: `presentation/views/settings/`
- **Modelo**: `data/models/setting.dart`
- **Repositorio**: `domain/repositories/settings_repository.dart`
- **Implementación**: `data/repositories/settings_repository_impl.dart`

## 🔧 Archivos de Configuración Importantes

### `pubspec.yaml`
- Dependencias del proyecto
- Configuración de assets
- Configuración de fuentes
- Metadata del proyecto

### `main.dart`
- Punto de entrada de la aplicación
- Configuración de BLoC providers
- Inicialización de servicios
- Configuración de internacionalización

Esta estructura modular facilita el mantenimiento, testing y escalabilidad del proyecto, permitiendo que múltiples desarrolladores trabajen simultáneamente sin conflictos.