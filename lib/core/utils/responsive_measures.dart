import 'dart:ui';

import 'package:sonofy/core/constants/layout_constants.dart';

/// Clase que provee medidas de ancho y alto de la pantalla,
/// ademas de booleanos para determinar el tipo de dispositivo.
class ResponsiveMeasures {
  /// Lado más corto de la pantalla.
  static double get shortestSide {
    final window = PlatformDispatcher.instance.views.first;
    final physicalSize = window.physicalSize;
    final devicePixelRatio = window.devicePixelRatio;
    final shortestSide = physicalSize.shortestSide / devicePixelRatio;
    return shortestSide;
  }

  /// Determina si la pantalla es de un dispositivo móvil.
  ///
  /// Es verdadero si el lado más corto de la pantalla es menor a mobileMaxWidth.
  static bool get isMobile => shortestSide < LayoutConstants.mobileMaxWidth;

  /// Determina si la pantalla es de un dispositivo tablet.
  ///
  /// Es verdadero si el lado más corto de la pantalla es
  /// mayor o igual a tabletMinWidth y menor a desktopMinWidth.
  static bool get isTablet => shortestSide >= LayoutConstants.tabletMinWidth && 
                            shortestSide < LayoutConstants.desktopMinWidth;

  /// Determina si la pantalla es de un dispositivo de escritorio.
  ///
  /// Es verdadero si el lado más corto de la pantalla es mayor o igual a desktopMinWidth.
  static bool get isDesktop => shortestSide >= LayoutConstants.desktopMinWidth;

  /// Ancho máximo de una pantalla de dispositivo móvil.
  static double get mobileMaxWidth => LayoutConstants.mobileMaxWidth;

  /// Ancho máximo de una pantalla de dispositivo tablet.
  static double get tabletMaxWidth => LayoutConstants.tabletMaxWidth;

  ///Funcion que calcula el reescalado de un widget
  static double widthWidgetMeasure({
    required double screenSize,
    required double widgetMinSize,
    required double screenMargin,
  }) =>
      widgetMinSize +
      ((screenSize % widgetMinSize) / (screenSize ~/ widgetMinSize)) -
      screenMargin;
}
