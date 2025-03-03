import 'package:flutter/material.dart';

class MainThene {
  static Color get backgroundColor => const Color.fromRGBO(240, 240, 240, 1);

  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: backgroundColor,
        ),
      );
}
