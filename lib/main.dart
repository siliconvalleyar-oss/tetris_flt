import 'package:flutter/material.dart';
import 'game/screens/menu_screen.dart';
import 'game/models/settings.dart';
import 'game/services/persistence_service.dart';
import 'theme/app_theme.dart';

/// Entry point for the minimalist Playdate-inspired Tetris.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistenceService.instance.init();
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GameSettings();
    settings.load();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'TETRIS',
          theme: AppTheme.forMode(settings.themeMode.index),
          home: MenuScreen(settings: settings),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
