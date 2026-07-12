import 'package:flutter/material.dart';
import '../services/persistence_service.dart';

/// Minimalist settings for the Playdate Tetris.
class GameSettings extends ChangeNotifier {
  bool _darkMode = false;
  bool _filledBlocks = true;
  bool _soundEnabled = true;

  bool get darkMode => _darkMode;
  bool get filledBlocks => _filledBlocks;
  bool get soundEnabled => _soundEnabled;

  /// Carga las preferencias guardadas al iniciar la app.
  void load() {
    final prefs = PersistenceService.instance;
    _darkMode = prefs.isDarkMode();
    _filledBlocks = prefs.isFilledBlocks();
    _soundEnabled = prefs.isSoundEnabled();
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
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
    prefs.setDarkMode(_darkMode);
    prefs.setFilledBlocks(_filledBlocks);
    prefs.setSoundEnabled(_soundEnabled);
  }

  Color get backgroundColor => _darkMode ? Colors.black : Colors.white;
  Color get foregroundColor => _darkMode ? Colors.white : Colors.black;
  Color get borderColor => _darkMode ? Colors.grey[800]! : Colors.grey[300]!;
  Color get textColor => _darkMode ? Colors.grey[500]! : Colors.grey[600]!;
  Color get lightTextColor => _darkMode ? Colors.grey[600]! : Colors.grey[500]!;
}
