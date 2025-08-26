import 'package:flutter/material.dart';

class LayoutConstants {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 1024; // Ajustado de 1400 a 1024
  static const double desktopMinWidth = 1024; // Ajustado de 1400 a 1024

  // Web Layout Dimensions
  static const double sidebarWidth = 280;
  static const double headerHeight = 64;
  static const double contentMaxWidth = 1400;
  static const double contentPadding = 10;

  // Navigation
  static const double navBarHeight = 56;
  static const double navItemHeight = 48;

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;

  // Constantes de márgenes modificables para cada dispositivo
  static const EdgeInsets mobilePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 8);
  static const EdgeInsets tabletPadding =
      EdgeInsets.symmetric(horizontal: 70, vertical: 20);
  static const EdgeInsets desktopPadding =
      EdgeInsets.symmetric(horizontal: 100, vertical: 20);

  // Constantes de aparición del FloatingActionButton modificables para cada dispositivo
  static const EdgeInsets mobileFloatingPadding = EdgeInsets.only(bottom: 100);
  static const EdgeInsets tabletFloatingPadding =
      EdgeInsets.only(bottom: 100, right: 300);
  static const EdgeInsets desktopFloatingPadding =
      EdgeInsets.symmetric(vertical: 20, horizontal: 500);

  static bool isWebLayoutWidth(double width) {
    return width >= desktopMinWidth;
  }
}
