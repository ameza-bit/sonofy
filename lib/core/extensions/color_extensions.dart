import 'package:flutter/material.dart';
import 'package:sonofy/core/themes/app_colors.dart';

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
}
