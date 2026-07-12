import 'package:flutter/material.dart';

/// Minimalist grayscale themes for Playdate-inspired Tetris.
class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Color(0xFFE0E0E0),
      surface: Color(0xFF1A1A1A),
      error: Color(0xFF999999),
    ),
    fontFamily: 'monospace',
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Color(0xFF1A1A1A),
      surface: Color(0xFFE0E0E0),
      error: Color(0xFF333333),
    ),
    fontFamily: 'monospace',
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );

  static final ThemeData lightGrayTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFD0D0D0),
    primaryColor: const Color(0xFF1A1A1A),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A1A1A),
      secondary: Color(0xFF404040),
      surface: Color(0xFFB0B0B0),
      error: Color(0xFF505050),
    ),
    fontFamily: 'monospace',
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFFD0D0D0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );

  static final ThemeData darkGrayTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2A2A2A),
    primaryColor: const Color(0xFFE0E0E0),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE0E0E0),
      secondary: Color(0xFFB0B0B0),
      surface: Color(0xFF3A3A3A),
      error: Color(0xFF808080),
    ),
    fontFamily: 'monospace',
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );

  static ThemeData forMode(int modeIndex) {
    switch (modeIndex) {
      case 0: return lightTheme;
      case 1: return darkTheme;
      case 2: return lightGrayTheme;
      case 3: return darkGrayTheme;
      default: return lightTheme;
    }
  }
}
