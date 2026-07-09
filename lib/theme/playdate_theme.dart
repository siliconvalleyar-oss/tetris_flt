import 'package:flutter/material.dart';

/// Minimalist black and white theme inspired by Playdate aesthetic.
///
/// Uses only grayscale colors: pure black, pure white, and grays.
/// Clean, simple, focused on gameplay without visual distractions.
class PlaydateTheme {
  PlaydateTheme._();

  // ─── Grayscale Palette ──────────────────────────────────
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFF666666);
  static const Color lighterGray = Color(0xFF999999);
  static const Color offWhite = Color(0xFFE0E0E0);

  // ─── Piece Grayscale Values ─────────────────────────────
  // Each piece type gets a distinct gray value for visual distinction
  static const Map<String, Color> pieceGrayscale = {
    'I': pureWhite,      // Brightest - stands out
    'O': offWhite,       // Very light gray
    'T': lighterGray,    // Light gray
    'S': mediumGray,     // Medium gray
    'Z': lightGray,      // Gray
    'J': darkGray,       // Dark gray
    'L': Color(0xFF4D4D4D), // Slightly lighter than dark gray
  };

  // ─── Theme Data ─────────────────────────────────────────
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: pureBlack,
    primaryColor: pureWhite,
    colorScheme: const ColorScheme.dark(
      primary: pureWhite,
      secondary: offWhite,
      surface: darkGray,
      error: Color(0xFF999999),
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
  );

  // ─── Border Styles ──────────────────────────────────────
  static const BorderSide thinBorder = BorderSide(
    color: mediumGray,
    width: 1,
  );

  static const BorderSide thickBorder = BorderSide(
    color: pureWhite,
    width: 2,
  );

  // ─── Decorations ────────────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: darkGray,
    border: Border.all(color: mediumGray, width: 1),
  );

  static BoxDecoration get selectedCardDecoration => BoxDecoration(
    color: darkGray,
    border: Border.all(color: pureWhite, width: 2),
  );

  static BoxDecoration get buttonDecoration => BoxDecoration(
    color: pureBlack,
    border: Border.all(color: pureWhite, width: 2),
  );

  static BoxDecoration get buttonDecorationFilled => BoxDecoration(
    color: pureWhite,
    border: Border.all(color: pureWhite, width: 2),
  );
}
