import 'package:flutter/material.dart';
import 'package:sonofy/core/themes/music_colors.dart';

/// Helpers y componentes para crear gradientes dinámicos basados en el color
/// primario configurado por el usuario. Proporciona widgets reutilizables
/// y funciones de utilidad para mantener consistencia visual.
class GradientHelpers {
  
  /// Crea un gradiente lineal estándar de la aplicación
  static LinearGradient createLinear(Color primaryColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return MusicColors.createMusicGradient(primaryColor, begin: begin, end: end);
  }
  
  /// Crea un gradiente circular para botones y elementos redondos
  static RadialGradient createCircular(Color primaryColor) {
    return MusicColors.createCircularGradient(primaryColor);
  }
  
  /// Crea un gradiente horizontal para barras de progreso
  static LinearGradient createHorizontal(Color primaryColor) {
    return MusicColors.createMusicGradient(
      primaryColor,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
  
  /// Crea un gradiente vertical para fondos
  static LinearGradient createVertical(Color primaryColor) {
    return MusicColors.createMusicGradient(
      primaryColor,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

/// Widget contenedor que aplica gradiente dinámico basado en el color primario
class GradientContainer extends StatelessWidget {
  const GradientContainer({
    required this.child,
    required this.primaryColor,
    this.borderRadius,
    this.gradient,
    this.padding,
    super.key,
  });

  final Widget child;
  final Color primaryColor;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? GradientHelpers.createLinear(primaryColor),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

/// Botón con gradiente dinámico - ideal para botones principales
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.onPressed,
    required this.child,
    required this.primaryColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 12.0,
    this.gradient,
    this.elevation = 2.0,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color primaryColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Gradient? gradient;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient ?? GradientHelpers.createLinear(primaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: padding,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: MusicColors.textOnGradient,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón circular con gradiente - ideal para controles de reproducción
class CircularGradientButton extends StatelessWidget {
  const CircularGradientButton({
    required this.onPressed,
    required this.child,
    required this.primaryColor,
    this.size = 56.0,
    this.elevation = 4.0,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color primaryColor;
  final double size;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: GradientHelpers.createCircular(primaryColor),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: MusicColors.textOnGradient,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de progreso con gradiente dinámico
class GradientProgressIndicator extends StatelessWidget {
  const GradientProgressIndicator({
    required this.value,
    required this.primaryColor,
    this.height = 4.0,
    this.borderRadius = 2.0,
    super.key,
  });

  final double value;
  final Color primaryColor;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: MusicColors.progressInactive,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: GradientHelpers.createHorizontal(primaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Card con borde gradiente sutil
class GradientBorderCard extends StatelessWidget {
  const GradientBorderCard({
    required this.child,
    required this.primaryColor,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
    this.borderWidth = 1.5,
    super.key,
  });

  final Widget child;
  final Color primaryColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: GradientHelpers.createLinear(primaryColor),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        padding: padding,
        decoration: BoxDecoration(
          color: MusicColors.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}

/// Slider personalizado con gradiente
class GradientSlider extends StatelessWidget {
  const GradientSlider({
    required this.value,
    required this.onChanged,
    required this.primaryColor,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    super.key,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final Color primaryColor;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: primaryColor,
        inactiveTrackColor: MusicColors.progressInactive,
        thumbColor: primaryColor,
        overlayColor: MusicColors.generateLightVariant(primaryColor),
        valueIndicatorColor: primaryColor,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

/// Extensiones para aplicar gradientes fácilmente a widgets existentes
extension GradientExtensions on Widget {
  /// Envuelve el widget en un GradientContainer
  Widget withGradient(Color primaryColor, {
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return GradientContainer(
      primaryColor: primaryColor,
      borderRadius: borderRadius,
      padding: padding,
      child: this,
    );
  }
  
  /// Aplica un gradiente como fondo usando un DecoratedBox
  Widget withGradientBackground(Color primaryColor, {
    BorderRadius? borderRadius,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: GradientHelpers.createLinear(primaryColor),
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }
}