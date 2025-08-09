import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/app_colors.dart';

/// Botón primario de la aplicación, utilizado para acciones principales.
///
/// Se estiliza automáticamente según el tema actual (claro/oscuro) y se adapta
/// al sistema de escalado de texto de la aplicación.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 54.0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: fullWidth ? 24 : 16, vertical: 16);
    final buttonRadius = borderRadius ?? BorderRadius.circular(12);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.isDarkMode(context)
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          disabledForegroundColor: AppColors.textDisabled(context),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          elevation: 0,
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: context.scaleIcon(16)),
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
