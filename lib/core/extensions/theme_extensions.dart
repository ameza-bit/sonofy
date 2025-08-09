import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samva/presentation/blocs/settings/settings_cubit.dart';

extension ThemeExtensions on ThemeData {
  // Obtener el factor de escala configurado por el usuario
  double get textScaleFactor {
    return typography.black.bodyLarge?.fontSize == null
        ? 1.0
        : typography.black.bodyLarge!.fontSize! / 16.0;
  }

  // Obtener un TextScaler
  TextScaler get textScaler {
    return TextScaler.linear(textScaleFactor);
  }

  // Escalar cualquier tamaño de texto
  double textSize(double size) {
    return size * textScaleFactor;
  }

  // Escalar tamaño de íconos
  double iconSize(double size) {
    return textSize(size);
  }
}

// Extensión para BuildContext
extension BuildContextExtensions on BuildContext {
  // Acceso rápido al factor de escala
  double get fontScale {
    // Si estamos en un context con un SettingsCubit, usar ese valor
    try {
      final settingsState = read<SettingsCubit>().state;
      return settingsState.settings.fontSize;
    } catch (_) {
      // Si no hay SettingsCubit disponible, usar el valor del tema
      return Theme.of(this).textScaleFactor;
    }
  }

  // Obtener un TextScaler basado en la configuración actual
  TextScaler get textScaler {
    return TextScaler.linear(fontScale);
  }

  // Escalar tamaño de texto
  double scaleText(double size) {
    return size * fontScale;
  }

  // Escalar tamaño de íconos
  double scaleIcon(double size) {
    return scaleText(size);
  }
}
