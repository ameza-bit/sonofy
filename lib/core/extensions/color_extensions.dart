import 'package:flutter/material.dart';
import 'package:sonofy/core/themes/app_colors.dart';
import 'package:sonofy/core/themes/music_colors.dart';

/// Extensión para BuildContext que proporciona acceso simplificado
/// a los colores de la aplicación
extension ColorExtensions on BuildContext {
  /// Determina si el tema actual es oscuro
  bool get isDarkMode => AppColors.isDarkMode(this);

  /// Color de fondo del scaffold
  Color get scaffoldBackground => AppColors.scaffoldBackground(this);

  /// Color primario para textos
  Color get textPrimary => AppColors.textPrimary(this);

  /// Color secundario para textos
  Color get textSecondary => AppColors.textSecondary(this);

  /// Color terciario para textos (más sutil)
  Color get textTertiary => AppColors.textTertiary(this);

  /// Color para texto deshabilitado
  Color get textDisabled => AppColors.textDisabled(this);

  /// Color seleccionado/de acento
  Color get selectedColor => AppColors.selectedColor(this);

  /// Color para bordes
  Color get border => AppColors.border(this);

  /// Color para divisores
  Color get divider => AppColors.divider(this);

  /// Color para tarjetas
  Color get cardBackground => AppColors.cardBackground(this);

  /// Color de fondo para inputs
  Color get inputBackground => AppColors.inputBackground(this);

  /// Color de fondo basado en el color primario
  Color get primaryBackground => AppColors.primaryBackground(this);

  /// Color para sombras
  Color get shadow => AppColors.shadow(this);

  /// Obtiene el color de éxito (estático)
  Color get success => AppColors.success;

  /// Obtiene el color de advertencia (estático)
  Color get warning => AppColors.warning;

  /// Obtiene el color de error (estático)
  Color get error => AppColors.error;

  /// Obtiene el color de información (estático)
  Color get info => AppColors.info;

  /// Obtiene el color según el código de estado HTTP
  Color statusColor(int statusCode) => AppColors.statusColor(statusCode);

  /// Crea una versión con transparencia de un color
  Color withEmphasis(Color color, {double emphasis = 0.1}) =>
      AppColors.withEmphasis(color, this, emphasis: emphasis);

  // ============================================================================
  // EXTENSIONES PARA COLORES DE MÚSICA
  // ============================================================================

  /// Obtiene el color de gradiente complementario basado en el color primario actual
  Color get primaryGradientColor {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.generateGradientColor(primaryColor);
  }

  /// Obtiene una variante oscura del color primario para estados pressed/focused
  Color get primaryDarkVariant {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.generateDarkVariant(primaryColor);
  }

  /// Obtiene una variante clara del color primario para fondos sutiles
  Color get primaryLightVariant {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.generateLightVariant(primaryColor);
  }

  /// Crea el gradiente principal de música usando el color primario configurado
  LinearGradient get musicGradient {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.createMusicGradient(primaryColor);
  }

  /// Crea un gradiente horizontal para barras de progreso
  LinearGradient get horizontalMusicGradient {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.createMusicGradient(
      primaryColor,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Crea un gradiente circular para botones de reproducción
  RadialGradient get circularMusicGradient {
    final primaryColor = Theme.of(this).primaryColor;
    return MusicColors.createCircularGradient(primaryColor);
  }

  // ============================================================================
  // COLORES FIJOS DE LA PALETA MUSICAL
  // ============================================================================

  /// Color de fondo principal de la aplicación - #F0F0F0
  Color get musicBackground => MusicColors.background;

  /// Color de superficie para cards y elementos - #FFFFFF
  Color get musicSurface => MusicColors.surface;

  /// Negro profundo para textos principales - #090909
  Color get musicDeepBlack => MusicColors.deepBlack;

  /// Gris oscuro para textos principales - #333333
  Color get musicDarkGrey => MusicColors.darkGrey;

  /// Gris medio para textos secundarios - #4F4F4F
  Color get musicMediumGrey => MusicColors.mediumGrey;

  /// Gris claro para textos terciarios - #828282
  Color get musicLightGrey => MusicColors.lightGrey;

  /// Blanco puro - #FFFFFF
  Color get musicWhite => MusicColors.pureWhite;

  /// Color para texto sobre fondos con gradiente
  Color get musicTextOnGradient => MusicColors.textOnGradient;

  /// Color para barras de progreso inactivas
  Color get musicProgressInactive => MusicColors.progressInactive;

  /// Color para iconos en estado inactivo
  Color get musicIconInactive => MusicColors.iconInactive;

  /// Color para divisores y bordes sutiles
  Color get musicSubtleBorder => MusicColors.subtleBorder;

  /// Color para sombras suaves en cards
  Color get musicCardShadow => MusicColors.cardShadow;
}
