# Guía Completa de Theming - Sonofy Music App

## Introducción

Esta guía documenta el sistema completo de theming implementado para Sonofy, una aplicación de reproductor de música moderna con diseño inspirado en Spotify y Apple Music. El sistema combina colores fijos de la marca con colores personalizables por el usuario, creando una experiencia visual consistente y flexible.

## Estructura del Sistema

### 📁 Ubicación de Archivos

```
lib/core/themes/
├── music_colors.dart          # Paleta principal y colores dinámicos
├── gradient_helpers.dart      # Componentes con gradientes
├── music_theme.dart          # Temas especializados para música
├── main_theme.dart          # Configuración principal de ThemeData
└── neutral_theme.dart       # Colores neutrales (existente)

lib/core/extensions/
└── color_extensions.dart    # Extensiones actualizadas con nuevas funciones

lib/data/models/
└── setting.dart            # Color por defecto actualizado a #5C42FF
```

## 🎨 Paleta de Colores

### Colores Configurables
- **Primary por defecto**: `#5C42FF` (púrpura principal)
- **Gradiente generado**: Se calcula automáticamente basado en el primary
- **16 colores disponibles** en el selector de configuración

### Colores Fijos de la Marca
```dart
// Fondos
background: #F0F0F0     // Fondo principal
surface: #FFFFFF        // Cards y superficies

// Escala de grises
deepBlack: #090909      // Texto principal
darkGrey: #333333       // Texto primario
mediumGrey: #4F4F4F     // Texto secundario
lightGrey: #828282      // Texto terciario
pureWhite: #FFFFFF      // Blanco puro

// Estados
success: #4CAF50
warning: #FF9800
error: #F44336
info: #2196F3
```

## 🔧 Uso del Sistema

### 1. Colores Básicos con Extensiones

```dart
// Colores fijos
Container(
  color: context.musicBackground,     // #F0F0F0
  child: Text(
    'Título',
    style: TextStyle(color: context.musicDarkGrey), // #333333
  ),
)

// Colores dinámicos (se adaptan al color configurado)
Container(
  color: context.primaryColor,        // Color configurado por usuario
  child: Text(
    'Botón',
    style: TextStyle(color: context.musicTextOnGradient),
  ),
)
```

### 2. Gradientes Dinámicos

```dart
// Gradiente que se adapta al color primario
Container(
  decoration: BoxDecoration(
    gradient: context.musicGradient,
  ),
  child: child,
)

// Gradiente horizontal para barras de progreso
Container(
  decoration: BoxDecoration(
    gradient: context.horizontalMusicGradient,
  ),
  child: progressBar,
)

// Gradiente circular para botones
Container(
  decoration: BoxDecoration(
    gradient: context.circularMusicGradient,
    shape: BoxShape.circle,
  ),
  child: playButton,
)
```

### 3. Componentes Especializados

#### GradientButton
```dart
GradientButton(
  primaryColor: Theme.of(context).primaryColor,
  onPressed: () => _signIn(),
  child: Text('Sign In'),
)
```

#### CircularGradientButton (Para controles de música)
```dart
CircularGradientButton(
  primaryColor: Theme.of(context).primaryColor,
  size: 56.0,
  onPressed: () => _playPause(),
  child: Icon(FontAwesomeIcons.solidPlay),
)
```

#### GradientProgressIndicator
```dart
GradientProgressIndicator(
  value: 0.6, // 0.0 - 1.0
  primaryColor: Theme.of(context).primaryColor,
  height: 4.0,
)
```

#### GradientSlider
```dart
GradientSlider(
  value: currentValue,
  primaryColor: Theme.of(context).primaryColor,
  onChanged: (value) => _updateProgress(value),
  min: 0.0,
  max: 100.0,
)
```

### 4. Widgets de Alto Nivel

#### MusicControls (Controles de reproductor completos)
```dart
MusicControls(
  theme: MusicTheme.musicPlayerTheme(primaryColor),
  isPlaying: isPlaying,
  onPlayPause: () => _togglePlayback(),
  onNext: () => _nextSong(),
  onPrevious: () => _previousSong(),
  isShuffling: shuffleEnabled,
  isRepeating: repeatEnabled,
)
```

#### PlaylistItem (Elementos de lista de canciones)
```dart
PlaylistItem(
  theme: MusicTheme.playlistTheme(primaryColor),
  title: song.title,
  artist: song.artist,
  duration: song.duration,
  isPlaying: currentSong == song,
  isFavorite: song.isFavorite,
  onTap: () => _playSong(song),
)
```

## 📱 Ejemplos de Implementación

### Pantalla de Login Moderna
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: context.musicBackground,
      body: Column(
        children: [
          // Header con gradiente
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: context.musicGradient,
            ),
            child: Center(
              child: Text(
                'Welcome to Sonofy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.musicTextOnGradient,
                ),
              ),
            ),
          ),
          
          // Formulario
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Campo de email
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MusicThemeData.authIcons['email'],
                      color: context.musicMediumGrey,
                    ),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.musicSubtleBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón con gradiente
                GradientButton(
                  primaryColor: primaryColor,
                  onPressed: () => _signIn(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MusicThemeData.authIcons['success']),
                      const SizedBox(width: 8),
                      Text('Sign In'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Reproductor de Música
```dart
class MusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerTheme = MusicTheme.musicPlayerTheme(
      Theme.of(context).primaryColor
    );
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.musicSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.musicCardShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Carátula del álbum
          Container(
            width: playerTheme.albumArtSize,
            height: playerTheme.albumArtSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                playerTheme.albumArtBorderRadius
              ),
              image: DecorationImage(
                image: albumArtImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información de la canción
          Text(
            songTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.musicDarkGrey,
            ),
          ),
          Text(
            artistName,
            style: TextStyle(
              fontSize: 16,
              color: context.musicMediumGrey,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Barra de progreso con gradiente
          GradientProgressIndicator(
            value: progress,
            primaryColor: Theme.of(context).primaryColor,
          ),
          
          const SizedBox(height: 32),
          
          // Controles de reproducción
          MusicControls(
            theme: playerTheme,
            isPlaying: isPlaying,
            onPlayPause: _togglePlayback,
            onNext: _nextSong,
            onPrevious: _previousSong,
          ),
        ],
      ),
    );
  }
}
```

## 🎯 Mejores Prácticas

### 1. Uso Consistente de Colores
```dart
// ✅ Correcto - Usar extensiones para colores fijos
Text('Título', style: TextStyle(color: context.musicDarkGrey))

// ❌ Incorrecto - Hardcodear colores
Text('Título', style: TextStyle(color: Color(0xFF333333)))
```

### 2. Gradientes Dinámicos
```dart
// ✅ Correcto - Gradiente que se adapta
Container(
  decoration: BoxDecoration(gradient: context.musicGradient),
)

// ❌ Incorrecto - Gradiente fijo
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF8673FD), Color(0xFF5C42FF)])
  ),
)
```

### 3. Componentes Reutilizables
```dart
// ✅ Correcto - Usar componentes del sistema
GradientButton(
  primaryColor: Theme.of(context).primaryColor,
  child: Text('Acción'),
)

// ❌ Incorrecto - Recrear gradientes manualmente
Container(
  decoration: BoxDecoration(/* gradiente manual */),
  child: Material(/* botón manual */),
)
```

### 4. Iconos con FontAwesome
```dart
// ✅ Correcto - Usar iconos predefinidos
Icon(MusicPlayerThemeData.controlIcons['play'])

// ✅ También correcto - Acceso directo
Icon(FontAwesomeIcons.solidPlay)
```

## 🔄 Configuración Dinámica

El sistema permite que los usuarios cambien el color primario desde la pantalla de configuración. Todos los gradientes y variantes se recalculan automáticamente:

### Proceso de Cambio de Color
1. Usuario selecciona color en `ColorPickerDialog`
2. Se actualiza `Settings.primaryColor`
3. `MainApp` se reconstruye automáticamente con nuevo tema
4. Todos los gradientes y variantes se recalculan dinámicamente

### Colores Disponibles para el Usuario
El array `MusicColors.availableColors` contiene 16 colores cuidadosamente seleccionados, empezando por el color por defecto `#5C42FF`.

## 📐 Especificaciones de Diseño

### Radios de Borde
- Botones: 12px
- Cards: 16px
- Inputs: 12px
- Reproductor: 20px

### Elevaciones
- Cards normales: 2
- Cards de reproductor: 4
- Botones: 2-3
- Diálogos: 8

### Espaciado
- Padding interno: 16-24px
- Separación entre elementos: 8-16px
- Márgenes de sección: 24-32px

## 🚀 Conclusión

Este sistema de theming proporciona:
- **Consistencia visual** en toda la aplicación
- **Flexibilidad** para personalización del usuario
- **Componentes reutilizables** para desarrollo eficiente
- **Mantenibilidad** a largo plazo
- **Diseño moderno** alineado con estándares actuales

El sistema está completamente integrado y listo para usar. Simplemente importa los archivos necesarios y utiliza las extensiones y componentes documentados para crear interfaces consistentes y atractivas.