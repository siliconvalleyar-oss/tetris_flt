import 'position.dart';
import '../utils/tetromino_data.dart';

/// Los 7 tetrominós clásicos del Tetris.
enum PieceType { I, O, T, S, Z, J, L }

/// Representa una pieza activa en el tablero.
///
/// Guarda el [type], la posición actual ([row], [col]) y
/// el estado de rotación (0-3). Las celdas absolutas se
/// calculan bajo demanda desde [TetrominoData].
class Piece {
  final PieceType type;
  int row;
  int col;
  int rotation;

  Piece({
    required this.type,
    required this.row,
    required this.col,
    this.rotation = 0,
  });

  /// Celdas absolutas de la pieza según su tipo, rotación y posición.
  List<Position> get cells => TetrominoData.getCells(type, rotation);

  Piece copy() => Piece(type: type, row: row, col: col, rotation: rotation);
}
