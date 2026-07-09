import 'dart:math';
import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/settings.dart';
import '../utils/tetromino_data.dart';

/// Minimalist next piece preview with Playdate aesthetic.
class PiecePreviewWidget extends StatelessWidget {
  final Piece? piece;
  final GameSettings settings;

  const PiecePreviewWidget({
    super.key,
    required this.piece,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 20.0;
    const previewSize = 4 * cellSize;

    return Container(
      width: previewSize + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: settings.backgroundColor,
        border: Border.all(color: settings.borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              color: settings.lightTextColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          CustomPaint(
            size: const Size(previewSize, previewSize),
            painter: _PiecePreviewPainter(
              piece: piece,
              cellSize: cellSize,
              darkMode: settings.darkMode,
              filledBlocks: settings.filledBlocks,
            ),
          ),
        ],
      ),
    );
  }
}

class _PiecePreviewPainter extends CustomPainter {
  final Piece? piece;
  final double cellSize;
  final bool darkMode;
  final bool filledBlocks;

  _PiecePreviewPainter({
    required this.piece,
    required this.cellSize,
    required this.darkMode,
    required this.filledBlocks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (piece == null) return;

    var color = TetrominoData.pieceColors[piece!.type]!;
    if (!darkMode) {
      color = HSLColor.fromColor(color).withLightness(
        (HSLColor.fromColor(color).lightness * 0.6).clamp(0.0, 1.0),
      ).toColor();
    }

    final cells = piece!.cells;

    double minRow = double.infinity;
    double minCol = double.infinity;
    double maxRow = double.negativeInfinity;
    double maxCol = double.negativeInfinity;

    for (final cell in cells) {
      minRow = min(minRow, cell.row.toDouble());
      minCol = min(minCol, cell.col.toDouble());
      maxRow = max(maxRow, cell.row.toDouble());
      maxCol = max(maxCol, cell.col.toDouble());
    }

    final pieceWidth = (maxCol - minCol + 1) * cellSize;
    final pieceHeight = (maxRow - minRow + 1) * cellSize;
    final offsetX = (size.width - pieceWidth) / 2;
    final offsetY = (size.height - pieceHeight) / 2;

    for (final cell in cells) {
      final x = offsetX + (cell.col - minCol) * cellSize;
      final y = offsetY + (cell.row - minRow) * cellSize;
      final rect = Rect.fromLTWH(x + 1, y + 1, cellSize - 2, cellSize - 2);

      if (filledBlocks) {
        canvas.drawRect(rect, Paint()..color = color);
      } else {
        final strokePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRect(rect, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PiecePreviewPainter oldDelegate) => true;
}
