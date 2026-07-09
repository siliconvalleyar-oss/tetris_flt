import 'dart:math';
import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../utils/tetromino_data.dart';

/// Minimalist next piece preview with Playdate aesthetic.
class PiecePreviewWidget extends StatelessWidget {
  final Piece? piece;

  const PiecePreviewWidget({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    const cellSize = 20.0;
    const previewSize = 4 * cellSize;

    return Container(
      width: previewSize + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          CustomPaint(
            size: const Size(previewSize, previewSize),
            painter: _PiecePreviewPainter(piece: piece, cellSize: cellSize),
          ),
        ],
      ),
    );
  }
}

class _PiecePreviewPainter extends CustomPainter {
  final Piece? piece;
  final double cellSize;

  _PiecePreviewPainter({required this.piece, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (piece == null) return;

    final color = TetrominoData.pieceColors[piece!.type]!;
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
      canvas.drawRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_PiecePreviewPainter oldDelegate) => true;
}
