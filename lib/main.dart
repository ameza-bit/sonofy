import 'package:flutter/material.dart';
import 'package:sonofy/routes/routes.dart';
import 'package:sonofy/themes/main_thene.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sonofy',
      routerConfig: Routes.getGoRoutes(navigatorKey),
      theme: MainThene.lightTheme,
    );
  }
}
