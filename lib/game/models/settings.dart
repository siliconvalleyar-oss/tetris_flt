import 'package:flutter/material.dart';

/// Minimalist settings for the Playdate Tetris.
class GameSettings extends ChangeNotifier {
  bool _darkMode = true;
  bool _filledBlocks = true;

  bool get darkMode => _darkMode;
  bool get filledBlocks => _filledBlocks;

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void toggleFilledBlocks() {
    _filledBlocks = !_filledBlocks;
    notifyListeners();
  }

  Color get backgroundColor => _darkMode ? Colors.black : Colors.white;
  Color get foregroundColor => _darkMode ? Colors.white : Colors.black;
  Color get borderColor => _darkMode ? Colors.grey[800]! : Colors.grey[300]!;
  Color get textColor => _darkMode ? Colors.grey[500]! : Colors.grey[600]!;
  Color get lightTextColor => _darkMode ? Colors.grey[600]! : Colors.grey[500]!;
}
