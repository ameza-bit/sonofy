# Sistema de Temas y Estilos

## 🎨 Visión General

Sonofy implementa un sistema de temas dinámico y flexible que permite personalización completa de la apariencia, incluyendo colores primarios customizables, modos claro/oscuro y escalado de fuentes. El sistema está diseñado para ser consistente, accesible y fácil de mantener.

## 🏗️ Arquitectura del Sistema de Temas

### Estructura de Archivos
```
core/themes/
├── main_theme.dart          # Tema principal y factory methods
├── music_colors.dart        # Paleta de colores del reproductor
├── music_theme.dart         # Tema específico del reproductor
├── neutral_theme.dart       # Colores neutros y dark theme
├── app_colors.dart          # Colores generales de la app
└── gradient_helpers.dart    # Utilidades para gradientes
```

### Extensiones de Tema
```
core/extensions/
├── theme_extensions.dart    # Extensiones de BuildContext
├── color_extensions.dart    # Extensiones de Color
└── responsive_extensions.dart # Responsive design
```

## 🎭 MainTheme - Tema Principal

### Factory Methods (`core/themes/main_theme.dart`)

```dart
class MainTheme {
  /// Tema claro por defecto
  static ThemeData get lightTheme => 
      _createLightTheme(MusicColors.defaultPrimary);
      
  /// Tema oscuro por defecto
  static ThemeData get darkTheme => 
      _createDarkTheme(MusicColors.defaultPrimary);

  /// Crear tema claro con color primario personalizado
  static ThemeData createLightTheme(Color primaryColor) =>
      _createLightTheme(primaryColor);

  /// Crear tema oscuro con color primario personalizado
  static ThemeData createDarkTheme(Color primaryColor) =>
      _createDarkTheme(primaryColor);
}
```

### Implementación del Tema Claro
```dart
static ThemeData _createLightTheme(Color primaryColor) {
  // Generar color secundario automáticamente
  final secondary = Color.fromARGB(
    255,
    ((primaryColor.r * 255.0).round() * 0.7).round() & 0xff,
    ((primaryColor.g * 255.0).round() * 0.7).round() & 0xff,
    ((primaryColor.b * 255.0).round() * 0.7).round() & 0xff,
  );

  return ThemeData(
    fontFamily: 'SF_UI_Display',
    brightness: Brightness.light,
    scaffoldBackgroundColor: MusicColors.background,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondary,
      surface: MusicColors.surface,
      onSecondary: MusicColors.textOnGradient,
      onSurface: MusicColors.darkGrey,
      outline: MusicColors.lightGrey,
      error: MusicColors.error,
    ),
    // ... configuración detallada
  );
}
```

### Configuración de Componentes
```dart
// AppBar Theme
appBarTheme: const AppBarTheme(
  backgroundColor: Colors.transparent,
  foregroundColor: MusicColors.darkGrey,
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: false,
),

// Card Theme
cardTheme: CardThemeData(
  color: MusicColors.surface,
  elevation: 2,
  shadowColor: MusicColors.cardShadow,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),

// Button Theme
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: MusicColors.textOnGradient,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  ),
),

// Slider Theme
sliderTheme: SliderThemeData(
  activeTrackColor: primaryColor,
  inactiveTrackColor: MusicColors.progressInactive,
  thumbColor: primaryColor,
  overlayColor: MusicColors.generateLightVariant(primaryColor),
  valueIndicatorColor: primaryColor,
  trackHeight: 4.0,
  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
),
```

## 🎵 MusicColors - Paleta del Reproductor

### Definición (`core/themes/music_colors.dart`)

```dart
class MusicColors {
  // Colores principales
  static const Color defaultPrimary = Color(0xFF5C42FF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Colores de texto
  static const Color darkGrey = Color(0xFF2D3748);
  static const Color mediumGrey = Color(0xFF4A5568);
  static const Color lightGrey = Color(0xFF718096);
  static const Color textOnGradient = Color(0xFFFFFFFF);
  
  // Colores del reproductor
  static const Color musicWhite = Color(0xFFF8F9FA);
  static const Color musicDeepBlack = Color(0xFF0A0A0A);
  static const Color musicLightGrey = Color(0xFFE2E8F0);
  
  // Estados y feedback
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);
  
  // Elementos de UI
  static const Color cardShadow = Color(0x1A000000);
  static const Color subtleBorder = Color(0xFFE2E8F0);
  static const Color progressInactive = Color(0xFFE2E8F0);
  static const Color iconInactive = Color(0xFF9CA3AF);

  /// Genera variante clara de un color
  static Color generateLightVariant(Color color) {
    return Color.fromARGB(
      51, // 20% de opacidad
      (color.r * 255.0).round(),
      (color.g * 255.0).round(),
      (color.b * 255.0).round(),
    );
  }

  /// Genera variante oscura de un color
  static Color generateDarkVariant(Color color) {
    return Color.fromARGB(
      255,
      ((color.r * 255.0).round() * 0.7).round() & 0xff,
      ((color.g * 255.0).round() * 0.7).round() & 0xff,
      ((color.b * 255.0).round() * 0.7).round() & 0xff,
    );
  }

  /// Verifica si un color es claro u oscuro
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Obtiene color de texto apropiado para el fondo
  static Color getTextColorForBackground(Color backgroundColor) {
    return isLightColor(backgroundColor) ? darkGrey : musicWhite;
  }
}
```

## 🌑 NeutralTheme - Colores para Tema Oscuro

### Definición (`core/themes/neutral_theme.dart`)

```dart
class NeutralTheme {
  // Colores base para tema oscuro
  static const Color richBlack = Color(0xFF0F172A);
  static const Color oilBlack = Color(0xFF1E293B);
  static const Color blackOpacity = Color(0xFF334155);
  
  // Grises neutros
  static const Color darkGrey = Color(0xFF475569);
  static const Color mediumGrey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFF94A3B8);
  
  // Colores de superficie
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  
  // Estados en tema oscuro
  static const Color errorDark = Color(0xFFEF4444);
  static const Color successDark = Color(0xFF10B981);
  static const Color warningDark = Color(0xFFF59E0B);
  static const Color infoDark = Color(0xFF3B82F6);
}
```

## 🎨 Extensiones de Tema

### ThemeExtensions (`core/extensions/theme_extensions.dart`)

```dart
extension ThemeExtensions on BuildContext {
  // Acceso rápido a colores del tema
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  
  // Colores específicos del reproductor
  Color get musicWhite => const Color(0xFFF8F9FA);
  Color get musicDeepBlack => const Color(0xFF0A0A0A);
  Color get musicLightGrey => const Color(0xFFE2E8F0);
  
  // Placeholder de imágenes
  String get imagePlaceholder => 'assets/images/placeholder.png';
  
  // Escalado de texto basado en configuraciones
  double scaleText(double size) {
    final settings = read<SettingsCubit>().state.settings;
    return size * settings.fontSize;
  }
  
  // Verificar si está en modo oscuro
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  // Color primario actual
  Color get primaryColor => colorScheme.primary;
  
  // Color de superficie actual
  Color get surfaceColor => colorScheme.surface;
}
```

### ColorExtensions (`core/extensions/color_extensions.dart`)

```dart
extension ColorExtensions on Color {
  /// Convierte Color a entero ARGB
  int toARGB32() {
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
  
  /// Crea variante más clara del color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Crea variante más oscura del color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Obtiene color con opacidad específica
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity);
  }
  
  /// Verifica si el color es claro
  bool get isLight => computeLuminance() > 0.5;
  
  /// Verifica si el color es oscuro
  bool get isDark => computeLuminance() <= 0.5;
  
  /// Obtiene color de texto contrastante
  Color get contrastingTextColor => isLight ? Colors.black : Colors.white;
}
```

## 🎭 Aplicación Dinámica de Temas

### En MainApp (`main.dart`)

```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) {
        // Solo reconstruir cuando cambian propiedades que afectan al tema
        return previous.settings.themeMode != current.settings.themeMode ||
               previous.settings.primaryColor != current.settings.primaryColor ||
               previous.settings.fontSize != current.settings.fontSize;
      },
      builder: (context, state) {
        return MaterialApp.router(
          theme: MainTheme.createLightTheme(state.settings.primaryColor)
              .copyWith(
                textTheme: MainTheme.createLightTheme(
                  state.settings.primaryColor,
                ).textTheme.apply(fontSizeFactor: state.settings.fontSize),
              ),
          darkTheme: MainTheme.createDarkTheme(state.settings.primaryColor)
              .copyWith(
                textTheme: MainTheme.createDarkTheme(
                  state.settings.primaryColor,
                ).textTheme.apply(fontSizeFactor: state.settings.fontSize),
              ),
          themeMode: state.settings.themeMode,
          // ...
        );
      },
    );
  }
}
```

### Selector de Color Primario

```dart
class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final predefinedColors = [
      const Color(0xFF5C42FF), // Púrpura por defecto
      const Color(0xFF2196F3), // Azul
      const Color(0xFF4CAF50), // Verde
      const Color(0xFFFF9800), // Naranja
      const Color(0xFFF44336), // Rojo
      const Color(0xFF9C27B0), // Púrpura claro
      const Color(0xFF00BCD4), // Cian
      const Color(0xFFFFEB3B), // Amarillo
    ];

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
          itemCount: predefinedColors.length,
          itemBuilder: (context, index) {
            final color = predefinedColors[index];
            final isSelected = color.value == currentColor.value;
            
            return GestureDetector(
              onTap: () => onColorSelected(color),
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
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## 📏 Sistema de Tipografía

### TextTheme Personalizado

```dart
static TextTheme _createTextTheme(Color textColor) {
  return TextTheme(
    // Display styles - Títulos grandes
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.normal,
      height: 64 / 57,
      color: textColor,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.normal,
      height: 52 / 45,
      color: textColor,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
      height: 44 / 36,
      color: textColor,
    ),

    // Headline styles - Encabezados
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.normal,
      height: 40 / 32,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 36 / 28,
      color: textColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
      height: 32 / 24,
      color: textColor,
    ),

    // Title styles - Títulos de sección
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 28 / 22,
      color: textColor,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      letterSpacing: 0.15,
      color: textColor,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0.1,
      color: textColor,
    ),

    // Body styles - Texto principal
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 24 / 16,
      letterSpacing: 0.15,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 20 / 14,
      letterSpacing: 0.25,
      color: textColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 16 / 12,
      letterSpacing: 0.4,
      color: textColor,
    ),

    // Label styles - Etiquetas y botones
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0.1,
      color: textColor,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      letterSpacing: 0.5,
      color: textColor,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 16 / 11,
      letterSpacing: 0.5,
      color: textColor,
    ),
  );
}
```

### Escalado de Fuente

```dart
// Aplicación del factor de escalado
.copyWith(
  textTheme: theme.textTheme.apply(
    fontSizeFactor: settings.fontSize,
  ),
)

// Uso en widgets
Text(
  'Título',
  style: TextStyle(
    fontSize: context.scaleText(20), // 20px escalado según configuración
    fontWeight: FontWeight.bold,
  ),
)
```

## 🌈 Gradientes y Efectos Visuales

### GradientHelpers (`core/themes/gradient_helpers.dart`)

```dart
class GradientHelpers {
  /// Gradiente para el reproductor
  static LinearGradient playerGradient(Color primaryColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.darken(0.2),
      ],
    );
  }
  
  /// Gradiente sutil para cards
  static LinearGradient subtleGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor.withValues(alpha: 0.1),
        baseColor.withValues(alpha: 0.05),
      ],
    );
  }
  
  /// Gradiente para overlay de imágenes
  static LinearGradient imageOverlay() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.7),
      ],
    );
  }
}
```

## 🎯 Mejores Prácticas

### Uso de Colores
```dart
// ✅ Correcto - Usar colores del tema
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Contenido',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)

// ✅ Correcto - Usar extensiones
Container(
  color: context.surfaceColor,
  child: Text(
    'Contenido',
    style: TextStyle(
      fontSize: context.scaleText(16),
    ),
  ),
)

// ❌ Incorrecto - Colores hardcodeados
Container(
  color: Colors.white,
  child: Text(
    'Contenido',
    style: TextStyle(color: Colors.black),
  ),
)
```

### Responsive Design
```dart
// Usar escalado responsivo
double fontSize = context.scaleText(16);
double padding = MediaQuery.of(context).size.width * 0.05;

// Considerar diferentes tamaños de pantalla
Widget buildContent() {
  if (context.isMobile) {
    return MobileLayout();
  } else if (context.isTablet) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

### Consistency
```dart
// Usar valores consistentes del tema
BorderRadius.circular(12), // De los botones
BorderRadius.circular(16), // De las cards

// Usar spacing consistente
const EdgeInsets.all(24.0),     // Padding principal
const EdgeInsets.all(16.0),     // Padding secundario
const EdgeInsets.all(8.0),      // Padding mínimo
```

## 🔮 Extensiones Futuras

### Temas Personalizados
```dart
class CustomTheme {
  final String name;
  final Color primaryColor;
  final Color backgroundColor;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
}

class ThemeManager {
  static List<CustomTheme> availableThemes = [
    CustomTheme(name: 'Ocean', primaryColor: Colors.blue, ...),
    CustomTheme(name: 'Forest', primaryColor: Colors.green, ...),
    CustomTheme(name: 'Sunset', primaryColor: Colors.orange, ...),
  ];
}
```

### Modo Alto Contraste
```dart
static ThemeData createHighContrastTheme() {
  return ThemeData(
    // Colores de alto contraste para accesibilidad
    colorScheme: const ColorScheme.highContrastLight(),
    // ...
  );
}
```

### Temas Basados en Carátula
```dart
Future<ThemeData> createThemeFromArtwork(ImageProvider image) async {
  final palette = await PaletteGenerator.fromImageProvider(image);
  final dominantColor = palette.dominantColor?.color ?? MusicColors.defaultPrimary;
  
  return MainTheme.createLightTheme(dominantColor);
}
```

El sistema de temas de Sonofy proporciona una base sólida y flexible para la personalización visual, manteniendo consistencia y accesibilidad en toda la aplicación.