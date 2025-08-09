// lib/core/constants/app_constants.dart

/// Constantes para toda la aplicación
/// Centraliza dimensiones, breakpoints, duración de animaciones,
/// y otros valores constantes para mantener consistencia en la UI.
///
/// Breakpoints para diseño responsivo
class AppBreakpoints {
  /// Ancho máximo para dispositivos móviles
  static const double mobileMax = 600;

  /// Ancho mínimo para tabletas
  static const double tabletMin = 601;

  /// Ancho máximo para tabletas
  static const double tabletMax = 900;

  /// Ancho mínimo para vista web
  static const double webMin = 901;

  /// Ancho máximo para componentes centrados en vista web
  static const double webComponentMaxWidth = 450;

  /// Ancho máximo para formularios en vista tablet
  static const double tabletFormMaxWidth = 600;

  /// Método para verificar si el ancho corresponde a un móvil
  static bool isMobile(double width) => width <= mobileMax;

  /// Método para verificar si el ancho corresponde a una tableta
  static bool isTablet(double width) => width > mobileMax && width <= tabletMax;

  /// Método para verificar si el ancho corresponde a vista web
  static bool isWeb(double width) => width > tabletMax;
}

/// Espaciado y padding consistente para toda la app
class AppSpacing {
  /// Padding pequeño estándar (8)
  static const double xs = 8.0;

  /// Padding medio pequeño estándar (12)
  static const double sm = 12.0;

  /// Padding medio estándar (16)
  static const double md = 16.0;

  /// Padding medio grande estándar (20)
  static const double lg = 20.0;

  /// Padding grande estándar (24)
  static const double xl = 24.0;

  /// Padding extra grande estándar (32)
  static const double xxl = 32.0;

  /// Padding doble grande estándar (40)
  static const double xxxl = 40.0;

  /// Separación vertical entre secciones en móvil
  static const double sectionVerticalMobile = 32.0;

  /// Separación vertical entre secciones en tablet/web
  static const double sectionVerticalLarge = 40.0;

  /// Padding lateral para contenido en móvil
  static const double contentPaddingMobile = 20.0;

  /// Padding lateral para contenido en tablet
  static const double contentPaddingTablet = 60.0;

  /// Padding lateral para contenido en web
  static const double contentPaddingWeb = 80.0;
}

/// Dimensiones de elementos de UI
class AppSizes {
  /// Altura estándar para botones en móvil
  static const double buttonHeightMobile = 48.0;

  /// Altura estándar para botones en tablet/web
  static const double buttonHeightLarge = 56.0;

  /// Tamaño del logo en pantalla móvil
  static const double logoSizeMobile = 100.0;

  /// Tamaño del logo en pantalla tablet
  static const double logoSizeTablet = 130.0;

  /// Tamaño del logo en pantalla web
  static const double logoSizeWeb = 180.0;

  /// Altura de entrada de texto estándar
  static const double inputHeight = 56.0;

  /// Elevación para tarjetas
  static const double cardElevation = 4.0;
}

/// Tamaños de texto para diferentes pantallas
class AppTextSizes {
  /// Tamaño de texto para títulos en móvil
  static const double titleMobile = 24.0;

  /// Tamaño de texto para títulos en tablet
  static const double titleTablet = 28.0;

  /// Tamaño de texto para títulos en web
  static const double titleWeb = 32.0;

  /// Tamaño de texto para subtítulos en móvil
  static const double subtitleMobile = 16.0;

  /// Tamaño de texto para subtítulos en tablet/web
  static const double subtitleLarge = 18.0;

  /// Tamaño de texto para cuerpo en móvil
  static const double bodyMobile = 14.0;

  /// Tamaño de texto para cuerpo en tablet/web
  static const double bodyLarge = 16.0;

  /// Tamaño de texto para pequeños detalles
  static const double caption = 12.0;
}

/// Radios de borde para diferentes elementos UI
class AppBorderRadius {
  /// Radio para botones
  static const double button = 12.0;

  /// Radio para tarjetas
  static const double card = 16.0;

  /// Radio para campos de entrada
  static const double input = 10.0;

  /// Radio para diálogos
  static const double dialog = 20.0;

  /// Radio para modales
  static const double modal = 20.0;
}

/// Duración para animaciones
class AppDurations {
  /// Duración corta para animaciones simples (150ms)
  static const Duration short = Duration(milliseconds: 150);

  /// Duración media para la mayoría de animaciones (300ms)
  static const Duration medium = Duration(milliseconds: 300);

  /// Duración larga para transiciones complejas (500ms)
  static const Duration long = Duration(milliseconds: 500);

  /// Duración para mostrar/ocultar snackbars o mensajes (4s)
  static const Duration snackbar = Duration(seconds: 4);
}

/// Proporciones para diseño de layouts
class AppRatios {
  /// Proporción para el panel decorativo en web (40% del total)
  static const int webDecoRatio = 4;

  /// Proporción para el panel de formulario en web (60% del total)
  static const int webFormRatio = 6;
}

/// Layout constants
class AppLayout {
  /// Grid layout
  static const int maxGridColumns = 4;
  static const int minGridColumns = 2;
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 1.2;

  /// List layout
  static const double listItemHeight = 80.0;
  static const double listItemSpacing = 8.0;

  /// Card layout
  static const double cardMaxWidth = 300.0;
  static const double cardMinWidth = 200.0;
  static const double cardHeight = 225.0;
}
