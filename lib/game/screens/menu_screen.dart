import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';
import 'game_screen.dart';

/// Minimalist menu screen with Playdate-inspired aesthetic.
///
/// Clean black and white design with simple typography
/// and no visual distractions.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Difficulty _selected = Difficulty.normal;
  bool _soundEnabled = true;

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
        builder: (_) => GameScreen(difficulty: _selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
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
                const SizedBox(height: 24),
                _buildSoundToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'TETRIS',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'PLAYDATE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 8,
            color: Colors.grey[600],
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
              color: Colors.grey[500],
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
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[800]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 32,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.description,
                      style: TextStyle(
                        color: Colors.grey[600],
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
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              if (isSelected)
                const Icon(Icons.check, color: Colors.white, size: 18),
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
        child: const Text(
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

  Widget _buildSoundToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _soundEnabled = !_soundEnabled;
          AudioService.instance.setEnabled(_soundEnabled);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: _soundEnabled ? Colors.grey[400] : Colors.grey[700],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _soundEnabled ? 'SOUND ON' : 'SOUND OFF',
              style: TextStyle(
                color: _soundEnabled ? Colors.grey[400] : Colors.grey[700],
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
