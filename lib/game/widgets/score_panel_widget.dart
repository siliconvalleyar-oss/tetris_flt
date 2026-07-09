import 'package:flutter/material.dart';
import '../models/settings.dart';

/// Minimalist score panel with Playdate aesthetic.
class ScorePanelWidget extends StatelessWidget {
  final int score;
  final int level;
  final int lines;
  final int highScore;
  final int combo;
  final String difficultyName;
  final Color difficultyColor;
  final GameSettings settings;

  const ScorePanelWidget({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
    required this.highScore,
    this.combo = 0,
    this.difficultyName = 'NORMAL',
    this.difficultyColor = const Color(0xFFB0B0B0),
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: settings.backgroundColor,
        border: Border.all(color: settings.borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LabelValue(label: 'SCORE', value: '$score', settings: settings),
          _divider(),
          _LabelValue(label: 'LV', value: '$level', settings: settings),
          _divider(),
          _LabelValue(label: 'LINES', value: '$lines', settings: settings),
          _divider(),
          _LabelValue(label: 'BEST', value: '$highScore', settings: settings),
          if (combo > 1) ...[
            _divider(),
            _ComboBadge(combo: combo, settings: settings),
          ],
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 28, color: settings.borderColor);
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final GameSettings settings;

  const _LabelValue({
    required this.label,
    required this.value,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: settings.lightTextColor,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: settings.foregroundColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _ComboBadge extends StatelessWidget {
  final int combo;
  final GameSettings settings;

  const _ComboBadge({required this.combo, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COMBO',
          style: TextStyle(
            color: settings.lightTextColor,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '×$combo',
          style: TextStyle(
            color: settings.foregroundColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
