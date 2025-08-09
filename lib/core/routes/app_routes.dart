import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/presentation/screens/login_screen.dart';
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
            path: LoginScreen.routeName,
            name: LoginScreen.routeName,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: SettingsScreen.routeName,
            name: SettingsScreen.routeName,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
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
        // final FirebaseAuth auth = FirebaseAuth.instance;
        final isSplashRoute = state.matchedLocation == '/';
        // final isAuthenticated = auth.currentUser != null;

        if (_hasShownSplash) {
          if (isSplashRoute) {
            return '/${LoginScreen.routeName}';
            // return isAuthenticated ? "/${HomeScreen.routeName}" : "/${LoginScreen.routeName}";
          }
        } else if (!isSplashRoute) {
          return '/?redirected=${state.uri.path}';
        }

        return null;
      },
    );
  }
}
