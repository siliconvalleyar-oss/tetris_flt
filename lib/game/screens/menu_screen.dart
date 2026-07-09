import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/settings.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';
import 'game_screen.dart';

/// Minimalist menu screen with Playdate-inspired aesthetic.
class MenuScreen extends StatefulWidget {
  final GameSettings settings;

  const MenuScreen({super.key, required this.settings});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Difficulty _selected = Difficulty.normal;
  bool _soundEnabled = true;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _selected = PersistenceService.instance.getDifficulty();
    _soundEnabled = AudioService.instance.enabled;
  }

  void _onStartGame() {
    PersistenceService.instance.setDifficulty(_selected);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: _selected,
          settings: widget.settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: widget.settings.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 48),
                        _buildDifficultySelector(),
                        const SizedBox(height: 48),
                        _buildStartButton(),
                      ],
                    ),
                  ),
                ),
                // Settings button - top right corner
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => setState(() => _showSettings = !_showSettings),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.settings.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: widget.settings.lightTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Settings panel
                if (_showSettings) _buildSettingsPanel(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'TETRIS',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: 16,
            color: widget.settings.foregroundColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'PLAYDATE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 8,
            color: widget.settings.lightTextColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'DIFFICULTY',
            style: TextStyle(
              color: widget.settings.lightTextColor,
              fontSize: 10,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...DifficultyConfig.all.map((config) => _buildDifficultyCard(config)),
      ],
    );
  }

  Widget _buildDifficultyCard(DifficultyConfig config) {
    final isSelected = _selected == config.difficulty;
    final highScore = PersistenceService.instance.getHighScore(config.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selected = config.difficulty),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.settings.foregroundColor.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? widget.settings.foregroundColor
                  : widget.settings.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 32,
                color: isSelected
                    ? widget.settings.foregroundColor
                    : widget.settings.borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: TextStyle(
                        color: isSelected
                            ? widget.settings.foregroundColor
                            : widget.settings.lightTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.description,
                      style: TextStyle(
                        color: widget.settings.lightTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (highScore > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '$highScore',
                    style: TextStyle(
                      color: widget.settings.lightTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              if (isSelected)
                Icon(Icons.check, color: widget.settings.foregroundColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onStartGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.settings.foregroundColor,
          foregroundColor: widget.settings.backgroundColor,
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
        child: Text(
          'PLAY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Positioned(
      top: 60,
      right: 16,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.settings.backgroundColor,
          border: Border.all(color: widget.settings.borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: TextStyle(
                color: widget.settings.lightTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingToggle(
              label: widget.settings.darkMode ? 'DARK' : 'LIGHT',
              onTap: widget.settings.toggleDarkMode,
              value: widget.settings.darkMode,
            ),
            const SizedBox(height: 8),
            _buildSettingToggle(
              label: widget.settings.filledBlocks ? 'FILLED' : 'WIREFRAME',
              onTap: widget.settings.toggleFilledBlocks,
              value: widget.settings.filledBlocks,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required String label,
    required VoidCallback onTap,
    required bool value,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: widget.settings.borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: widget.settings.foregroundColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            Container(
              width: 32,
              height: 16,
              decoration: BoxDecoration(
                color: value
                    ? widget.settings.foregroundColor
                    : widget.settings.borderColor,
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  color: value
                      ? widget.settings.backgroundColor
                      : widget.settings.foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
