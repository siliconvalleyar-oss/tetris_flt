import 'package:flutter/material.dart';

/// Minimalist black and white theme for Playdate-inspired Tetris.
class AppTheme {
  AppTheme._();

  // ─── Grayscale Colors ───────────────────────────────────
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFF666666);
  static const Color lighterGray = Color(0xFF999999);
  static const Color offWhite = Color(0xFFE0E0E0);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: pureBlack,
    primaryColor: pureWhite,
    colorScheme: const ColorScheme.dark(
      primary: pureWhite,
      secondary: offWhite,
      surface: darkGray,
      error: lighterGray,
    ),
    fontFamily: 'monospace',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: pureWhite,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 8,
      ),
      headlineMedium: TextStyle(
        color: pureWhite,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
      bodyLarge: TextStyle(
        color: offWhite,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: lighterGray,
        fontSize: 12,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: pureBlack,
      elevation: 0,
      iconTheme: IconThemeData(color: pureWhite),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: pureWhite,
    primaryColor: pureBlack,
    colorScheme: const ColorScheme.light(
      primary: pureBlack,
      secondary: darkGray,
      surface: offWhite,
      error: mediumGray,
    ),
    fontFamily: 'monospace',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: pureBlack,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 8,
      ),
      headlineMedium: TextStyle(
        color: pureBlack,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
      bodyLarge: TextStyle(
        color: darkGray,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: mediumGray,
        fontSize: 12,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: pureWhite,
      elevation: 0,
      iconTheme: IconThemeData(color: pureBlack),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );
}
