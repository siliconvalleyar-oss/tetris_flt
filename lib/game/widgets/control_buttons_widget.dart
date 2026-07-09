import 'package:flutter/material.dart';

/// Minimalist control buttons with Playdate aesthetic.
class ControlButtonsWidget extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onPause;

  const ControlButtonsWidget({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                label: 'ROT',
                icon: Icons.rotate_90_degrees_ccw,
                onPressed: onRotate,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                label: 'DROP',
                icon: Icons.arrow_downward,
                onPressed: onSoftDrop,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                label: 'HARD',
                icon: Icons.vertical_align_bottom,
                onPressed: onHardDrop,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                label: 'PAUSE',
                icon: Icons.pause,
                onPressed: onPause,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DirectionButton(
                icon: Icons.chevron_left,
                onPressed: onLeft,
              ),
              const SizedBox(width: 16),
              _DirectionButton(
                icon: Icons.chevron_right,
                onPressed: onRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Minimalist action button.
class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[400], size: 18),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 8,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimalist direction button.
class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DirectionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Icon(icon, color: Colors.grey[400], size: 24),
      ),
    );
  }
}
