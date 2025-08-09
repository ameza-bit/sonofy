import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

/// Extension para hacer los iconos responsivos al tamaño de fuente
extension ResponsiveIcon on BuildContext {
  /// Tamaño de icono pequeño escalado por font size
  double get iconSizeSmall {
    final settingsState = read<SettingsCubit>().state;
    return _getScaledIconSize(16, settingsState.settings.fontSize);
  }

  /// Tamaño de icono mediano escalado por font size
  double get iconSizeMedium {
    final settingsState = read<SettingsCubit>().state;
    return _getScaledIconSize(20, settingsState.settings.fontSize);
  }

  /// Tamaño de icono grande escalado por font size
  double get iconSizeLarge {
    final settingsState = read<SettingsCubit>().state;
    return _getScaledIconSize(24, settingsState.settings.fontSize);
  }

  /// Tamaño de icono extra grande escalado por font size
  double get iconSizeXLarge {
    final settingsState = read<SettingsCubit>().state;
    return _getScaledIconSize(32, settingsState.settings.fontSize);
  }

  /// Método personalizado para escalar cualquier tamaño de icono
  double getScaledIconSize(double baseSize) {
    final settingsState = read<SettingsCubit>().state;
    return _getScaledIconSize(baseSize, settingsState.settings.fontSize);
  }

  /// Método privado que calcula el tamaño escalado
  double _getScaledIconSize(double baseSize, double fontScale) {
    // Aplicar escalado pero con límites razonables para iconos
    // Los iconos no deberían escalar tanto como el texto
    final scaleFactor =
        (fontScale - 1.0) * 0.5 + 1.0; // Reduce el factor de escala
    return (baseSize * scaleFactor).clamp(
      12.0,
      48.0,
    ); // Límites mínimo y máximo
  }
}

/// Widget helper para iconos responsivos
class AppResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double baseSize;
  final Color? color;

  const AppResponsiveIcon({
    required this.icon,
    this.baseSize = 20,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.fontSize != current.settings.fontSize,
      builder: (context, state) {
        final scaledSize = context._getScaledIconSize(
          baseSize,
          state.settings.fontSize,
        );
        return Icon(icon, size: scaledSize, color: color);
      },
    );
  }
}
