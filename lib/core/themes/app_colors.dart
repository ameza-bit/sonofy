import 'package:flutter/material.dart';

/// Clase utilitaria que proporciona acceso a colores comunes de la aplicación,
/// teniendo en cuenta el tema actual (oscuro o claro).
class AppColors {
  /// Determina si el tema actual es oscuro basado en el brightness.
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Color de texto primario que se adapta al tema actual.
  static Color textPrimary(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black87;
  }

  /// Color de texto secundario que se adapta al tema actual.
  static Color textSecondary(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Color de texto terciario (más sutil) que se adapta al tema actual.
  static Color textTertiary(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade500;
  }

  /// Color para texto deshabilitado que se adapta al tema actual.
  static Color textDisabled(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade400;
  }

  /// Color para bordes que se adapta al tema actual.
  static Color border(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade300;
  }

  /// Color para bordes sutiles o divisores que se adapta al tema actual.
  static Color divider(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  /// Color de fondo para tarjetas que se adapta al tema actual.
  static Color cardBackground(BuildContext context) {
    return isDarkMode(context) ? Theme.of(context).cardColor : Colors.white;
  }

  /// Color de fondo para inputs y campos que se adapta al tema actual.
  static Color inputBackground(BuildContext context) {
    return isDarkMode(context) ? Colors.black12 : Colors.grey.shade50;
  }

  /// Color de fondo para la pantalla que se adapta al tema actual.
  static Color scaffoldBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Color para elementos seleccionados basado en el color primario del tema.
  static Color selectedColor(BuildContext context, {int alpha = 255}) {
    return Theme.of(context).primaryColor.withAlpha(alpha);
  }

  /// Crea una versión con transparencia de un color para fondos de iconos, chips, etc.
  static Color withEmphasis(
    Color color,
    BuildContext context, {
    double emphasis = 0.1,
  }) {
    // Convertimos el porcentaje de énfasis a un valor de alpha (0-255)
    final alpha = (emphasis * 255).round();
    return color.withAlpha(alpha);
  }

  /// Color de fondo para componentes destacados basado en el color primario.
  static Color primaryBackground(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final alpha = isDarkMode(context) ? 40 : 30;
    return primaryColor.withAlpha(alpha);
  }

  /// Color para sombras adaptado al tema actual.
  static Color shadow(BuildContext context, {int alpha = 20}) {
    return isDarkMode(context)
        ? Colors.black.withAlpha(alpha)
        : Colors.black.withAlpha(alpha);
  }

  /// Colores para códigos de estado HTTP
  static Color statusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green.shade700;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.blue.shade700;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.amber.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  /// Color de éxito para mensajes y estados positivos.
  static Color success = Colors.green.shade700;

  /// Color de advertencia para mensajes y estados de precaución.
  static Color warning = Colors.amber.shade700;

  /// Color de error para mensajes y estados negativos.
  static Color error = Colors.red.shade700;

  /// Color de información para mensajes y estados neutrales.
  static Color info = Colors.blue.shade700;
}
