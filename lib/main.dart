import 'package:flutter/material.dart';
import 'game/screens/menu_screen.dart';
import 'game/services/persistence_service.dart';
import 'game/services/audio_service.dart';
import 'theme/app_theme.dart';

/// Entry point for the minimalist Playdate-inspired Tetris.
///
/// Initializes services and launches the app with a clean
/// black and white aesthetic.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService.instance.init();
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TETRIS',
      theme: AppTheme.darkTheme,
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
