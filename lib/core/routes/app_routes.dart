import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/transitions/player_transition.dart';
import 'package:sonofy/core/utils/page_transition.dart';
import 'package:sonofy/presentation/screens/library_screen.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/screens/settings_screen.dart';
import 'package:sonofy/presentation/screens/splash_screen.dart';

class AppRoutes {
  // Variable para controlar si ya se mostró el splash
  static bool _hasShownSplash = false;

  static RouterConfig<Object>? getGoRoutes(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final List<RouteBase> routes = [
      GoRoute(
        path: '/',
        builder: (context, state) {
          _hasShownSplash = true;
          return const SplashScreen();
        },
        routes: [
          GoRoute(
            path: LibraryScreen.routeName,
            name: LibraryScreen.routeName,
            pageBuilder: (context, state) => PageTransition(
              context: context,
              state: state,
              page: const LibraryScreen(),
            ).fadeTransition(),
            routes: [
              GoRoute(
                path: PlayerScreen.routeName,
                name: PlayerScreen.routeName,
                pageBuilder: (context, state) => PlayerSlideTransition(
                  child: const PlayerScreen(),
                  key: state.pageKey,
                  name: state.name,
                  arguments: state.extra,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/${SettingsScreen.routeName}',
        name: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
    ];

    return GoRouter(
      navigatorKey: navigatorKey,
      routes: routes,
      errorBuilder: (context, state) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text(state.error.toString(), maxLines: 5)),
        ),
      ),
      redirect: (context, state) {
        final isSplashRoute = state.matchedLocation == '/';
        final isRedirectedFromSplash = state.uri.queryParameters.containsKey(
          'redirected',
        );

        // Si ya se mostró el splash y estamos en la ruta raíz sin parámetros de redirección,
        // redirigir a la biblioteca
        if (_hasShownSplash && isSplashRoute && !isRedirectedFromSplash) {
          return '/${LibraryScreen.routeName}';
        }

        return null;
      },
    );
  }
}
