import 'package:flutter/material.dart';
import 'package:sonofy/core/themes/neutral_theme.dart';
import 'package:sonofy/core/themes/music_colors.dart';

class MainTheme {
  static ThemeData get lightTheme => _createLightTheme(MusicColors.defaultPrimary);
  static ThemeData get darkTheme => _createDarkTheme(MusicColors.defaultPrimary);

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
      scaffoldBackgroundColor: MusicColors.background,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondary,
        surface: MusicColors.surface,
        onSecondary: MusicColors.textOnGradient,
        onSurface: MusicColors.darkGrey,
        outline: MusicColors.lightGrey,
        error: MusicColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: MusicColors.darkGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardColor: MusicColors.surface,
      cardTheme: CardThemeData(
        color: MusicColors.surface,
        elevation: 2,
        shadowColor: MusicColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: MusicColors.textOnGradient,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      dividerColor: MusicColors.subtleBorder,
      iconTheme: const IconThemeData(color: MusicColors.mediumGrey),
      textTheme: _createTextTheme(MusicColors.darkGrey),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: MusicColors.surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: MusicColors.iconInactive,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: MusicColors.progressInactive,
        thumbColor: primaryColor,
        overlayColor: MusicColors.generateLightVariant(primaryColor),
        valueIndicatorColor: primaryColor,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
      ),
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
        surfaceContainerLowest: NeutralTheme.blackOpacity,
        onSecondary: MusicColors.textOnGradient,
        outline: Colors.grey.shade600,
        error: MusicColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardColor: NeutralTheme.blackOpacity,
      cardTheme: CardThemeData(
        color: NeutralTheme.blackOpacity,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: MusicColors.textOnGradient,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      dividerColor: Colors.grey.shade800,
      iconTheme: IconThemeData(color: Colors.grey.shade300),
      textTheme: _createTextTheme(Colors.white),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeutralTheme.oilBlack,
        selectedItemColor: primaryLight,
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryLight,
        inactiveTrackColor: Colors.grey.shade700,
        thumbColor: primaryLight,
        overlayColor: primaryLight.withValues(alpha: 0.3),
        valueIndicatorColor: primaryLight,
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
      ),
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
