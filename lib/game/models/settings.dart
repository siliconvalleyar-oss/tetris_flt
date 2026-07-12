import 'package:flutter/material.dart';
import '../services/persistence_service.dart';
import 'theme_mode.dart';

/// Minimalist settings for the Playdate Tetris.
class GameSettings extends ChangeNotifier {
  GameThemeMode _themeMode = GameThemeMode.light;
  bool _filledBlocks = true;
  bool _soundEnabled = true;

  GameThemeMode get themeMode => _themeMode;
  bool get darkMode => _themeMode == GameThemeMode.dark || _themeMode == GameThemeMode.darkGray;
  bool get filledBlocks => _filledBlocks;
  bool get soundEnabled => _soundEnabled;

  void load() {
    final prefs = PersistenceService.instance;
    _themeMode = prefs.getThemeMode();
    _filledBlocks = prefs.isFilledBlocks();
    _soundEnabled = prefs.isSoundEnabled();
    notifyListeners();
  }

  void cycleThemeMode() {
    const modes = GameThemeMode.values;
    final idx = modes.indexOf(_themeMode);
    _themeMode = modes[(idx + 1) % modes.length];
    _save();
    notifyListeners();
  }

  void setThemeMode(GameThemeMode mode) {
    _themeMode = mode;
    _save();
    notifyListeners();
  }

  void toggleFilledBlocks() {
    _filledBlocks = !_filledBlocks;
    _save();
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _save();
    notifyListeners();
  }

  void _save() {
    final prefs = PersistenceService.instance;
    prefs.setThemeMode(_themeMode);
    prefs.setFilledBlocks(_filledBlocks);
    prefs.setSoundEnabled(_soundEnabled);
  }

  // ─── Colores por modo ─────────────────────────────────

  Color get backgroundColor {
    switch (_themeMode) {
      case GameThemeMode.light:
        return Colors.white;
      case GameThemeMode.dark:
        return Colors.black;
      case GameThemeMode.lightGray:
        return const Color(0xFFD0D0D0);
      case GameThemeMode.darkGray:
        return const Color(0xFF2A2A2A);
    }
  }

  Color get foregroundColor {
    switch (_themeMode) {
      case GameThemeMode.light:
        return Colors.black;
      case GameThemeMode.dark:
        return Colors.white;
      case GameThemeMode.lightGray:
        return const Color(0xFF1A1A1A);
      case GameThemeMode.darkGray:
        return const Color(0xFFE0E0E0);
    }
  }

  Color get borderColor {
    switch (_themeMode) {
      case GameThemeMode.light:
        return Colors.grey[300]!;
      case GameThemeMode.dark:
        return Colors.grey[800]!;
      case GameThemeMode.lightGray:
        return const Color(0xFFB0B0B0);
      case GameThemeMode.darkGray:
        return const Color(0xFF444444);
    }
  }

  Color get textColor {
    switch (_themeMode) {
      case GameThemeMode.light:
        return Colors.grey[600]!;
      case GameThemeMode.dark:
        return Colors.grey[500]!;
      case GameThemeMode.lightGray:
        return const Color(0xFF505050);
      case GameThemeMode.darkGray:
        return const Color(0xFF909090);
    }
  }

  Color get lightTextColor {
    switch (_themeMode) {
      case GameThemeMode.light:
        return Colors.grey[500]!;
      case GameThemeMode.dark:
        return Colors.grey[600]!;
      case GameThemeMode.lightGray:
        return const Color(0xFF606060);
      case GameThemeMode.darkGray:
        return const Color(0xFF808080);
    }
  }

  String get themeModeLabel {
    switch (_themeMode) {
      case GameThemeMode.light:
        return 'LIGHT';
      case GameThemeMode.dark:
        return 'DARK';
      case GameThemeMode.lightGray:
        return 'GRAY LIGHT';
      case GameThemeMode.darkGray:
        return 'GRAY DARK';
    }
  }
}
