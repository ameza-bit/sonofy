import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/screens/home_screen.dart';
import 'package:sonofy/screens/music_player_screen.dart';

class Routes {
  static RouterConfig<Object>? getGoRoutes(GlobalKey<NavigatorState> navigatorKey) {
    List<RouteBase> routes = [
      GoRoute(
        path: "/",
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            name: MusicPlayerScreen.routeName,
            path: MusicPlayerScreen.routeName,
            builder: (context, state) => const MusicPlayerScreen(),
          ),
        ],
      ),
    ];

    return GoRouter(
      navigatorKey: navigatorKey,
      routes: routes,
      errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString(), maxLines: 5))),
    );
  }
}
