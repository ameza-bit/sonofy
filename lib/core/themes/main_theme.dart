import 'package:flutter/material.dart';
import 'package:samva/core/themes/neutral_theme.dart';

class MainTheme {
  static ThemeData get lightTheme => _createLightTheme(Colors.indigo.shade700);
  static ThemeData get darkTheme => _createDarkTheme(Colors.indigo.shade700);

  // Create light theme with custom primary color
  static ThemeData createLightTheme(Color primaryColor) =>
      _createLightTheme(primaryColor);

  // Create dark theme with custom primary color
  static ThemeData createDarkTheme(Color primaryColor) =>
      _createDarkTheme(primaryColor);

  static ThemeData _createLightTheme(Color primaryColor) {
    // Generate secondary color from primary (darker)
    final secondary = Color.fromARGB(
      255,
      ((primaryColor.r * 255.0).round() * 0.7).round() & 0xff,
      ((primaryColor.g * 255.0).round() * 0.7).round() & 0xff,
      ((primaryColor.b * 255.0).round() * 0.7).round() & 0xff,
    );

    return ThemeData(
      fontFamily: 'SF_UI_Display',
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeutralTheme.offWhite,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondary,
        surface: NeutralTheme.offWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: NeutralTheme.oilBlack,
        elevation: 0,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade200,
      iconTheme: IconThemeData(color: Colors.grey.shade700),
      textTheme: _createTextTheme(Colors.black87),
    );
  }

  static ThemeData _createDarkTheme(Color primaryColor) {
    // Generate lighter variant for dark theme
    final primaryLight = Color.fromARGB(
      255,
      ((primaryColor.r * 255.0).round() +
                  (255 - (primaryColor.r * 255.0).round()) * 0.3)
              .round() &
          0xff,
      ((primaryColor.g * 255.0).round() +
                  (255 - (primaryColor.g * 255.0).round()) * 0.3)
              .round() &
          0xff,
      ((primaryColor.b * 255.0).round() +
                  (255 - (primaryColor.b * 255.0).round()) * 0.3)
              .round() &
          0xff,
    );

    // Generate secondary color
    final secondary = Color.fromARGB(
      255,
      ((primaryLight.r * 255.0).round() * 0.8).round() & 0xff,
      ((primaryLight.g * 255.0).round() * 0.8).round() & 0xff,
      ((primaryLight.b * 255.0).round() * 0.8).round() & 0xff,
    );

    return ThemeData(
      fontFamily: 'SF_UI_Display',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeutralTheme.richBlack,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: secondary,
        surface: NeutralTheme.oilBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NeutralTheme.oilBlack,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: NeutralTheme.blackOpacity,
      dividerColor: Colors.grey.shade800,
      iconTheme: IconThemeData(color: Colors.grey.shade300),
      textTheme: _createTextTheme(Colors.white),
    );
  }

  // Método para crear un TextTheme completo con todos los valores explícitos
  static TextTheme _createTextTheme(Color textColor) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.normal,
        height: 64 / 57,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.normal,
        height: 52 / 45,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        height: 44 / 36,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        height: 40 / 32,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.normal,
        height: 36 / 28,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        height: 32 / 24,
        color: textColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500, // Medium
        height: 28 / 22,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        height: 24 / 16,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        height: 20 / 14,
        letterSpacing: 0.1,
        color: textColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 24 / 16,
        letterSpacing: 0.15,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 20 / 14,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 16 / 12,
        letterSpacing: 0.4,
        color: textColor,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        height: 20 / 14,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        height: 16 / 12,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500, // Medium
        height: 16 / 11,
        letterSpacing: 0.5,
        color: textColor,
      ),
    );
  }
}
