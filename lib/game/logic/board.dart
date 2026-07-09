import '../models/position.dart';
import '../models/piece.dart';
import '../utils/constants.dart';

/// Tablero de juego: cuadrícula de 10×20 que almacena los bloques fijados.
///
/// Responsabilidades:
/// - Detectar colisiones contra bordes y bloques existentes.
/// - Fijar piezas al llegar al fondo.
/// - Detectar y eliminar líneas completas.
class Board {
  final List<List<int?>> _grid;

  Board() : _grid = List.generate(
    GameConstants.boardHeight,
    (_) => List.filled(GameConstants.boardWidth, null),
  );

  /// Expone la grilla para renderizado (solo lectura externa).
  List<List<int?>> get grid => _grid;

  int? getCell(int row, int col) {
    if (row < 0 || row >= GameConstants.boardHeight) return null;
    if (col < 0 || col >= GameConstants.boardWidth) return null;
    return _grid[row][col];
  }

  /// Vacía todo el tablero.
  void clear() {
    for (int r = 0; r < GameConstants.boardHeight; r++) {
      for (int c = 0; c < GameConstants.boardWidth; c++) {
        _grid[r][c] = null;
      }
    }
  }

  /// Verifica si las celdas de una pieza en [pieceRow, pieceCol] colisionan.
  ///
  /// Celdas por encima del tablero (row < 0) NO cuentan como colisión
  /// (la pieza puede estar parcialmente fuera de la parte superior).
  bool isCollision(List<Position> cells, int pieceRow, int pieceCol) {
    for (final cell in cells) {
      final int r = pieceRow + cell.row;
      final int c = pieceCol + cell.col;

      if (c < 0 || c >= GameConstants.boardWidth) return true;
      if (r >= GameConstants.boardHeight) return true;
      if (r < 0) continue;
      if (_grid[r][c] != null) return true;
    }
    return false;
  }

  /// Escribe las celdas de la pieza en la grilla (fijación).
  void fixPiece(Piece piece) {
    final int typeIndex = piece.type.index;
    for (final cell in piece.cells) {
      final int r = piece.row + cell.row;
      final int c = piece.col + cell.col;
      if (r >= 0 && r < GameConstants.boardHeight && c >= 0 && c < GameConstants.boardWidth) {
        _grid[r][c] = typeIndex;
      }
    }
  }

  /// Elimina todas las filas completamente llenas y devuelve la cantidad.
  ///
  /// Las filas eliminadas se reemplazan por filas vacías en la parte superior.
  int clearLines() {
    int cleared = 0;
    for (int r = GameConstants.boardHeight - 1; r >= 0; r--) {
      if (_grid[r].every((cell) => cell != null)) {
        _grid.removeAt(r);
        _grid.insert(0, List.filled(GameConstants.boardWidth, null));
        cleared++;
        r++;
      }
    }
    return cleared;
  }

  /// Verifica si hay bloques en la fila superior (game over).
  bool isGameOver() {
    for (int c = 0; c < GameConstants.boardWidth; c++) {
      if (_grid[0][c] != null) return true;
    }
    return false;
  }

  /// Elimina las filas en [rows] (debe estar ordenado ascendentemente).
  ///
  /// Cada fila removida se reemplaza por una fila vacía al tope.
  void removeRows(List<int> rows) {
    final sorted = List<int>.from(rows)..sort();
    int removed = 0;
    for (final r in sorted) {
      _grid.removeAt(r - removed);
      _grid.insert(0, List.filled(GameConstants.boardWidth, null));
      removed++;
    }
  }
}
