import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/app_colors.dart';

/// Botón secundario de la aplicación, utilizado para acciones secundarias.
///
/// Se estiliza automáticamente según el tema actual (claro/oscuro) y se adapta
/// al sistema de escalado de texto de la aplicación.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool outlined;

  const SecondaryButton({
    required this.text,
    this.onPressed,
    this.icon,
    this.iconColor,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 54.0,
    this.padding,
    this.borderRadius,
    this.outlined = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppColors.isDarkMode(context);
    final buttonPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: fullWidth ? 24 : 16, vertical: 16);
    final buttonRadius = borderRadius ?? BorderRadius.circular(12);

    // Usar el ButtonStyle correcto según si es outlined o no
    final ButtonStyle buttonStyle = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: theme.primaryColor,
            side: BorderSide(color: theme.primaryColor),
            backgroundColor: Colors.transparent,
            disabledForegroundColor: AppColors.textDisabled(context),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.black12 : Colors.grey.shade100,
            foregroundColor: theme.primaryColor,
            disabledBackgroundColor: isDark
                ? Colors.grey.shade900
                : Colors.grey.shade200,
            disabledForegroundColor: AppColors.textDisabled(context),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            elevation: 0,
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: _buildContent(context),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: _buildContent(context),
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.primaryColor,
        ),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: context.scaleIcon(16), color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: context.scaleText(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: context.scaleText(16),
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }
}
