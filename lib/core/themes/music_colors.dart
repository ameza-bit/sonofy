import 'package:flutter/material.dart';

/// Paleta de colores específica para la aplicación de música Sonofy.
/// Incluye colores fijos de la marca y funciones para generar variantes dinámicas
/// basadas en el color primario configurado por el usuario.
class MusicColors {
  
  // ============================================================================
  // COLORES PRINCIPALES DE LA MARCA (configurables por el usuario)
  // ============================================================================
  
  /// Color púrpura principal por defecto - #5C42FF
  /// Este color puede ser modificado por el usuario desde configuración
  static const Color defaultPrimary = Color(0xFF5C42FF);
  
  /// Color púrpura más claro para gradientes - #8673FD
  /// Se usa como segunda parada del gradiente principal
  static const Color defaultPrimaryLight = Color(0xFF8673FD);
  
  // ============================================================================
  // COLORES FIJOS DE LA PALETA (no configurables)
  // ============================================================================
  
  /// Fondo principal de la aplicación - #F0F0F0
  static const Color background = Color(0xFFF0F0F0);
  
  /// Superficie de cards y elementos - #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Negro profundo para textos principales - #090909
  static const Color deepBlack = Color(0xFF090909);
  
  /// Gris oscuro para textos principales - #333333
  static const Color darkGrey = Color(0xFF333333);
  
  /// Gris medio para textos secundarios - #4F4F4F
  static const Color mediumGrey = Color(0xFF4F4F4F);
  
  /// Gris claro para textos terciarios - #828282
  static const Color lightGrey = Color(0xFF828282);
  
  /// Blanco puro - #FFFFFF
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // ============================================================================
  // COLORES DE ESTADO Y FEEDBACK
  // ============================================================================
  
  /// Color para mensajes de éxito
  static const Color success = Color(0xFF4CAF50);
  
  /// Color para advertencias
  static const Color warning = Color(0xFFFF9800);
  
  /// Color para errores
  static const Color error = Color(0xFFF44336);
  
  /// Color para información
  static const Color info = Color(0xFF2196F3);
  
  // ============================================================================
  // FUNCIONES PARA GENERAR COLORES DINÁMICOS
  // ============================================================================
  
  /// Genera un color de gradiente complementario basado en el color primario
  /// configurado por el usuario. Aumenta el brillo y saturación para crear
  /// el efecto de gradiente característico de la aplicación.
  static Color generateGradientColor(Color primaryColor) {
    final HSLColor hsl = HSLColor.fromColor(primaryColor);
    
    // Aumentar el brillo en 15% y la saturación en 10% para el gradiente
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation + 0.10).clamp(0.0, 1.0))
              .toColor();
  }
  
  /// Genera una variante más oscura del color primario para estados pressed/focused
  static Color generateDarkVariant(Color primaryColor) {
    final HSLColor hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();
  }
  
  /// Genera una variante más clara del color primario para fondos sutiles
  static Color generateLightVariant(Color primaryColor) {
    final HSLColor hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness + 0.30).clamp(0.0, 1.0))
              .withSaturation((hsl.saturation - 0.20).clamp(0.0, 1.0))
              .toColor();
  }
  
  /// Crea un gradiente lineal usando el color primario configurado
  static LinearGradient createMusicGradient(Color primaryColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    final gradientColor = generateGradientColor(primaryColor);
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [gradientColor, primaryColor],
      stops: const [0.0, 1.0],
    );
  }
  
  /// Crea un gradiente circular para botones de reproducción
  static RadialGradient createCircularGradient(Color primaryColor) {
    final gradientColor = generateGradientColor(primaryColor);
    return RadialGradient(
      colors: [gradientColor, primaryColor],
      stops: const [0.0, 1.0],
    );
  }
  
  // ============================================================================
  // PALETA DE COLORES PARA SELECTOR DE CONFIGURACIÓN
  // ============================================================================
  
  /// Lista de colores predefinidos que el usuario puede elegir
  /// El primer color es el defaultPrimary (#5C42FF)
  static const List<Color> availableColors = [
    defaultPrimary,         // #5C42FF - Púrpura original
    Color(0xFFE91E63),      // Pink
    Color(0xFF9C27B0),      // Purple
    Color(0xFF673AB7),      // Deep Purple
    Color(0xFF3F51B5),      // Indigo
    Color(0xFF2196F3),      // Blue
    Color(0xFF00BCD4),      // Cyan
    Color(0xFF009688),      // Teal
    Color(0xFF4CAF50),      // Green
    Color(0xFF8BC34A),      // Light Green
    Color(0xFFCDDC39),      // Lime
    Color(0xFFFFEB3B),      // Yellow
    Color(0xFFFFC107),      // Amber
    Color(0xFFFF9800),      // Orange
    Color(0xFFFF5722),      // Deep Orange
    Color(0xFF795548),      // Brown
  ];
  
  // ============================================================================
  // HELPERS PARA COMPONENTES DE MÚSICA
  // ============================================================================
  
  /// Color para barras de progreso inactivas
  static Color get progressInactive => lightGrey.withValues(alpha: 0.3);
  
  /// Color para texto sobre fondos con gradiente
  static const Color textOnGradient = pureWhite;
  
  /// Color para iconos en estado inactivo
  static Color get iconInactive => mediumGrey.withValues(alpha: 0.6);
  
  /// Color para divisores y bordes sutiles
  static Color get subtleBorder => lightGrey.withValues(alpha: 0.2);
  
  /// Color para sombras suaves en cards
  static Color get cardShadow => deepBlack.withValues(alpha: 0.1);
}