import 'package:flutter/material.dart';
import 'package:sonofy/screens/home_screen.dart';
import 'package:sonofy/themes/main_thene.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonofy',
      theme: MainThene.lightTheme,
      home: const HomeScreen(),
    );
  }
}
