import 'package:flutter/material.dart';
import '../logic/tetris_engine.dart';
import '../models/piece.dart';
import '../models/settings.dart';
import '../utils/constants.dart';
import '../utils/tetromino_data.dart';

/// Minimalist game board with Playdate-inspired aesthetic.
class GameBoardWidget extends StatelessWidget {
  final TetrisEngine engine;
  final GameSettings settings;

  const GameBoardWidget({
    super.key,
    required this.engine,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = _calculateCellSize(constraints);
        return Container(
          decoration: BoxDecoration(
            color: settings.backgroundColor,
            border: Border.all(color: settings.borderColor, width: 1),
          ),
          child: CustomPaint(
            size: Size(
              GameConstants.boardWidth * cellSize,
              GameConstants.boardHeight * cellSize,
            ),
            painter: _GameBoardPainter(
              grid: engine.board.grid,
              currentPiece: engine.currentPiece,
              clearingLines: engine.clearingLines,
              cellSize: cellSize,
              darkMode: settings.darkMode,
              filledBlocks: settings.filledBlocks,
            ),
          ),
        );
      },
    );
  }

  double _calculateCellSize(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final maxHeight = constraints.maxHeight;
    final widthBased = maxWidth / GameConstants.boardWidth;
    final heightBased = maxHeight / GameConstants.boardHeight;
    return widthBased < heightBased ? widthBased : heightBased;
  }
}

/// Minimalist painter for the game board.
class _GameBoardPainter extends CustomPainter {
  final List<List<int?>> grid;
  final Piece? currentPiece;
  final Set<int> clearingLines;
  final double cellSize;
  final bool darkMode;
  final bool filledBlocks;

  _GameBoardPainter({
    required this.grid,
    required this.currentPiece,
    required this.clearingLines,
    required this.cellSize,
    required this.darkMode,
    required this.filledBlocks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);
    _drawFixedBlocks(canvas);
    _drawCurrentPiece(canvas);
    _drawClearingFlash(canvas);
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = settings.borderColor
      ..strokeWidth = 0.5;

    for (int r = 0; r <= GameConstants.boardHeight; r++) {
      canvas.drawLine(
        Offset(0, r * cellSize),
        Offset(GameConstants.boardWidth * cellSize, r * cellSize),
        paint,
      );
    }
    for (int c = 0; c <= GameConstants.boardWidth; c++) {
      canvas.drawLine(
        Offset(c * cellSize, 0),
        Offset(c * cellSize, GameConstants.boardHeight * cellSize),
        paint,
      );
    }
  }

  void _drawFixedBlocks(Canvas canvas) {
    for (int r = 0; r < GameConstants.boardHeight; r++) {
      if (clearingLines.contains(r)) continue;
      for (int c = 0; c < GameConstants.boardWidth; c++) {
        final cellType = grid[r][c];
        if (cellType != null) {
          final color = TetrominoData.pieceColors[PieceType.values[cellType]]!;
          _drawBlock(canvas, r, c, _adjustColorForMode(color));
        }
      }
    }
  }

  void _drawCurrentPiece(Canvas canvas) {
    if (currentPiece == null) return;

    final color = _adjustColorForMode(TetrominoData.pieceColors[currentPiece!.type]!);
    for (final cell in currentPiece!.cells) {
      final int r = currentPiece!.row + cell.row;
      final int c = currentPiece!.col + cell.col;
      if (r >= 0 && r < GameConstants.boardHeight &&
          c >= 0 && c < GameConstants.boardWidth) {
        _drawBlock(canvas, r, c, color);
      }
    }
  }

  void _drawClearingFlash(Canvas canvas) {
    if (clearingLines.isEmpty) return;

    final flashPaint = Paint()..color = settings.foregroundColor;

    for (final r in clearingLines) {
      canvas.drawRect(
        Rect.fromLTWH(0, r * cellSize, GameConstants.boardWidth * cellSize, cellSize),
        flashPaint,
      );
    }
  }

  Color _adjustColorForMode(Color color) {
    if (darkMode) return color;
    return HSLColor.fromColor(color).withLightness(
      (HSLColor.fromColor(color).lightness * 0.6).clamp(0.0, 1.0),
    ).toColor();
  }

  void _drawBlock(Canvas canvas, int row, int col, Color color) {
    final rect = Rect.fromLTWH(
      col * cellSize + 1,
      row * cellSize + 1,
      cellSize - 2,
      cellSize - 2,
    );

    if (filledBlocks) {
      canvas.drawRect(rect, Paint()..color = color);
    } else {
      // Wireframe mode - just the outline
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_GameBoardPainter oldDelegate) => true;
}
