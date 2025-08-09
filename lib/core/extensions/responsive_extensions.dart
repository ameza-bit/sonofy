import 'package:flutter/material.dart';
import 'package:sonofy/core/constants/app_constants.dart';

/// Extensión para BuildContext que proporciona métodos para detectar
/// el tipo de dispositivo y otras características responsivas
extension ResponsiveContext on BuildContext {
  /// Verifica si el dispositivo actual es un móvil (ancho < 600px)
  bool get isMobile =>
      MediaQuery.of(this).size.width <= AppBreakpoints.mobileMax;

  /// Verifica si el dispositivo actual es una tablet (600px < ancho < 900px)
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width > AppBreakpoints.mobileMax &&
        width <= AppBreakpoints.tabletMax;
  }

  /// Verifica si el dispositivo actual tiene vista web (ancho > 900px)
  bool get isWeb => MediaQuery.of(this).size.width > AppBreakpoints.tabletMax;

  /// Verifica si el dispositivo actual tiene una pantalla grande (tablet o web)
  bool get isLargeScreen =>
      MediaQuery.of(this).size.width > AppBreakpoints.mobileMax;

  /// Verifica si el dispositivo está en orientación de paisaje
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Obtiene el ancho de la pantalla
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Obtiene el alto de la pantalla
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Obtiene el valor de padding adecuado para el contenido según el tipo de dispositivo
  double get contentPadding {
    if (isWeb) return AppSpacing.contentPaddingWeb;
    if (isTablet) return AppSpacing.contentPaddingTablet;
    return AppSpacing.contentPaddingMobile;
  }

  /// Obtiene el tamaño de fuente para títulos según el dispositivo
  double get titleTextSize {
    if (isWeb) return AppTextSizes.titleWeb;
    if (isTablet) return AppTextSizes.titleTablet;
    return AppTextSizes.titleMobile;
  }

  /// Obtiene el tamaño de fuente para subtítulos según el dispositivo
  double get subtitleTextSize {
    if (isLargeScreen) return AppTextSizes.subtitleLarge;
    return AppTextSizes.subtitleMobile;
  }

  /// Obtiene el tamaño de fuente para texto normal según el dispositivo
  double get bodyTextSize {
    if (isLargeScreen) return AppTextSizes.bodyLarge;
    return AppTextSizes.bodyMobile;
  }

  /// Obtiene el tamaño adecuado para botones según el dispositivo
  double get buttonHeight {
    if (isLargeScreen) return AppSizes.buttonHeightLarge;
    return AppSizes.buttonHeightMobile;
  }

  /// Obtiene el espaciado vertical entre secciones según el dispositivo
  double get sectionSpacing {
    if (isLargeScreen) return AppSpacing.sectionVerticalLarge;
    return AppSpacing.sectionVerticalMobile;
  }
}
