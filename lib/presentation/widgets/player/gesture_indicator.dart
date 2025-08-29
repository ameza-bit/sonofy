import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';

class GestureIndicator extends StatefulWidget {
  const GestureIndicator({
    required this.label,
    required this.value,
    required this.icon,
    required this.isVisible,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isVisible;

  @override
  State<GestureIndicator> createState() => _GestureIndicatorState();
}

class _GestureIndicatorState extends State<GestureIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(GestureIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.musicDeepBlack.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.musicWhite.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: context.musicWhite,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: context.musicWhite,
                    fontSize: context.scaleText(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: TextStyle(
                    color: context.musicWhite,
                    fontSize: context.scaleText(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}