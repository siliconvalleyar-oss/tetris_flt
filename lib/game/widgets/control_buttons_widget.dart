import 'package:flutter/material.dart';
import '../models/settings.dart';

/// Minimalist control buttons with Playdate aesthetic.
class ControlButtonsWidget extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onPause;
  final GameSettings settings;

  const ControlButtonsWidget({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onPause,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                settings: settings,
              ),
              const SizedBox(width: 16),
              _ControlButton(
                label: 'DROP',
                icon: Icons.arrow_downward,
                onPressed: onSoftDrop,
                settings: settings,
              ),
              const SizedBox(width: 16),
              _ControlButton(
                label: 'HARD',
                icon: Icons.vertical_align_bottom,
                onPressed: onHardDrop,
                settings: settings,
              ),
              const SizedBox(width: 16),
              _ControlButton(
                label: 'PAUSE',
                icon: Icons.pause,
                onPressed: onPause,
                settings: settings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DirectionButton(
                icon: Icons.chevron_left,
                onPressed: onLeft,
                settings: settings,
              ),
              const SizedBox(width: 32),
              _DirectionButton(
                icon: Icons.chevron_right,
                onPressed: onRight,
                settings: settings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Minimalist action button with press feedback.
class _ControlButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final GameSettings settings;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.settings,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final bg = _pressed
        ? (s.darkMode ? Colors.grey[700]! : Colors.grey[400]!)
        : s.backgroundColor;
    final fg = _pressed ? s.backgroundColor : s.lightTextColor;
    final border = _pressed ? s.foregroundColor : s.borderColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: _pressed ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: fg, size: 18),
            Text(
              widget.label,
              style: TextStyle(
                color: fg,
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

/// Minimalist direction button with press feedback.
class _DirectionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final GameSettings settings;

  const _DirectionButton({
    required this.icon,
    required this.onPressed,
    required this.settings,
  });

  @override
  State<_DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<_DirectionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final bg = _pressed
        ? (s.darkMode ? Colors.grey[700]! : Colors.grey[400]!)
        : s.backgroundColor;
    final fg = _pressed ? s.backgroundColor : s.lightTextColor;
    final border = _pressed ? s.foregroundColor : s.borderColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 88,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: _pressed ? 2 : 1),
        ),
        child: Icon(widget.icon, color: fg, size: 24),
      ),
    );
  }
}
