import 'package:flutter/material.dart';

class PlayerSlideTransition extends Page<void> {
  final Widget child;
  final Offset? beginOffset;
  final Offset? endOffset;

  const PlayerSlideTransition({
    required this.child,
    this.beginOffset,
    this.endOffset,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<void> createRoute(BuildContext context) {
    return PageRouteBuilder<void>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(
          begin: beginOffset ?? begin,
          end: endOffset ?? end,
        ).chain(CurveTween(curve: curve));

        final offsetAnimation = animation.drive(tween);

        // Crear una animación de fade que se sincroniza con el slide
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
          ),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}
