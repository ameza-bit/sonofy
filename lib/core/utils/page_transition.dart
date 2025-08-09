import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Clase que proporciona diferentes tipos de transiciones de página personalizadas
/// para usar con GoRouter en Flutter.
///
/// Esta clase facilita la implementación de animaciones suaves entre páginas
/// y puede ser utilizada directamente en la configuración de rutas de GoRouter.
class PageTransition {
  final BuildContext context;
  final GoRouterState state;
  final Widget page;
  final Duration duration;

  /// Constructor de PageTransition
  ///
  /// Parámetros:
  /// - [context]: El BuildContext actual
  /// - [state]: El estado actual de GoRouter
  /// - [page]: El widget de la página a mostrar
  /// - [duration]: Duración de la transición (por defecto 300ms)
  PageTransition({
    required this.context,
    required this.state,
    required this.page,
    this.duration = const Duration(milliseconds: 800),
  });

  /// Crea una transición con efecto de fundido (fade)
  ///
  /// La página aparece gradualmente, aumentando su opacidad desde 0 hasta 1
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// GoRoute(
  ///   path: '/ruta',
  ///   pageBuilder: (context, state) => PageTransition(
  ///     context: context,
  ///     state: state,
  ///     page: TuPagina(),
  ///   ).fadeTransition(),
  /// ),
  /// ```
  CustomTransitionPage fadeTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      );

  /// Crea una transición deslizante desde la derecha
  ///
  /// La página se desliza desde el borde derecho de la pantalla
  ///
  /// Esta transición es ideal para navegación jerárquica hacia adelante
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// pageBuilder: (context, state) => PageTransition(
  ///   context: context,
  ///   state: state,
  ///   page: TuPagina(),
  ///   duration: Duration(milliseconds: 400), // Duración personalizada
  /// ).slideTransition(),
  /// ```
  CustomTransitionPage slideTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );

  /// Crea una transición con efecto de escala
  ///
  /// La página crece desde el centro hasta ocupar toda la pantalla
  ///
  /// Ideal para diálogos o páginas modales
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// pageBuilder: (context, state) => PageTransition(
  ///   context: context,
  ///   state: state,
  ///   page: TuPagina(),
  /// ).scaleTransition(),
  /// ```
  CustomTransitionPage scaleTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
      );

  /// Crea una transición combinando rotación y escala
  ///
  /// La página gira y crece simultáneamente
  ///
  /// Esta transición es más llamativa y puede ser útil para momentos especiales
  /// en la aplicación o para destacar ciertas páginas
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// pageBuilder: (context, state) => PageTransition(
  ///   context: context,
  ///   state: state,
  ///   page: TuPagina(),
  /// ).rotationTransition(),
  /// ```
  CustomTransitionPage rotationTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
      );

  /// Crea una transición que combina fundido y deslizamiento
  ///
  /// La página se desliza hacia arriba mientras aparece gradualmente
  ///
  /// Esta transición es suave y profesional, ideal para la mayoría
  /// de las transiciones en una aplicación seria
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// pageBuilder: (context, state) => PageTransition(
  ///   context: context,
  ///   state: state,
  ///   page: TuPagina(),
  /// ).fadeSlideTransition(),
  /// ```
  CustomTransitionPage fadeSlideTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.3);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      );

  /// Crea una transición con efecto de rebote
  ///
  /// La página aparece con un efecto de rebote elástico
  ///
  /// Esta transición añade un toque juguetón y puede ser apropiada
  /// para aplicaciones más casuales o secciones específicas
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// pageBuilder: (context, state) => PageTransition(
  ///   context: context,
  ///   state: state,
  ///   page: TuPagina(),
  /// ).bounceTransition(),
  /// ```
  CustomTransitionPage bounceTransition<T>() => CustomTransitionPage<T>(
        key: state.pageKey,
        child: page,
        transitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final bounceAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          );

          return ScaleTransition(
            scale: bounceAnimation,
            child: child,
          );
        },
      );
}
