import 'package:flutter/material.dart';

/// Minimalist score panel with Playdate aesthetic.
class ScorePanelWidget extends StatelessWidget {
  final int score;
  final int level;
  final int lines;
  final int highScore;
  final int combo;
  final String difficultyName;
  final Color difficultyColor;

  const ScorePanelWidget({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
    required this.highScore,
    this.combo = 0,
    this.difficultyName = 'NORMAL',
    this.difficultyColor = const Color(0xFFB0B0B0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LabelValue(label: 'SCORE', value: '$score'),
          _divider(),
          _LabelValue(label: 'LV', value: '$level'),
          _divider(),
          _LabelValue(label: 'LINES', value: '$lines'),
          _divider(),
          _LabelValue(label: 'BEST', value: '$highScore'),
          if (combo > 1) ...[
            _divider(),
            _ComboBadge(combo: combo),
          ],
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 28, color: Colors.grey[800]);
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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

  const _ComboBadge({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COMBO',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '×$combo',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
