import 'package:flutter/material.dart';
import '../models/position.dart';
import '../models/piece.dart';

/// Datos geométricos y cromáticos de los 7 tetrominós.
///
/// Cada pieza define sus celdas para los 4 estados de rotación
/// (0°, 90°, 180°, 270°). Las rotaciones se calculan mediante
/// la fórmula de rotación horaria: (r, c) → (c, size-1-r).
class TetrominoData {
  TetrominoData._();

  static Map<PieceType, List<List<Position>>>? _data;
  static Map<PieceType, int>? _boundingSizes;

  /// Inicializa los datos de piezas (perezosamente, una sola vez).
  static void _init() {
    if (_data != null) return;

    _boundingSizes = {
      PieceType.I: 4,
      PieceType.O: 2,
      PieceType.T: 3,
      PieceType.S: 3,
      PieceType.Z: 3,
      PieceType.J: 3,
      PieceType.L: 3,
    };

    _data = {
      PieceType.I: _generateRotations([
        const Position(1, 0),
        const Position(1, 1),
        const Position(1, 2),
        const Position(1, 3),
      ], 4),
      PieceType.O: List.generate(4, (_) => [
        const Position(0, 0),
        const Position(0, 1),
        const Position(1, 0),
        const Position(1, 1),
      ]),
      PieceType.T: _generateRotations([
        const Position(0, 1),
        const Position(1, 0),
        const Position(1, 1),
        const Position(1, 2),
      ], 3),
      PieceType.S: _generateRotations([
        const Position(0, 1),
        const Position(0, 2),
        const Position(1, 0),
        const Position(1, 1),
      ], 3),
      PieceType.Z: _generateRotations([
        const Position(0, 0),
        const Position(0, 1),
        const Position(1, 1),
        const Position(1, 2),
      ], 3),
      PieceType.J: _generateRotations([
        const Position(0, 0),
        const Position(1, 0),
        const Position(1, 1),
        const Position(1, 2),
      ], 3),
      PieceType.L: _generateRotations([
        const Position(0, 2),
        const Position(1, 0),
        const Position(1, 1),
        const Position(1, 2),
      ], 3),
    };
  }

  /// Genera las 4 rotaciones aplicando la transformación horaria.
  static List<List<Position>> _generateRotations(List<Position> state0, int size) {
    final rotations = <List<Position>>[List.unmodifiable(state0)];
    for (int i = 1; i < 4; i++) {
      rotations.add(List.unmodifiable(_rotateCW(rotations[i - 1], size)));
    }
    return rotations;
  }

  /// Rotación horaria: (r, c) → (c, size-1-r).
  static List<Position> _rotateCW(List<Position> cells, int size) {
    return cells.map((p) => Position(p.col, size - 1 - p.row)).toList();
  }

  /// Devuelve las celdas (offsets relativos) para un [type] y [rotation] dados.
  static List<Position> getCells(PieceType type, int rotation) {
    _init();
    return _data![type]![rotation % 4];
  }

  static int getBoundingSize(PieceType type) {
    _init();
    return _boundingSizes![type]!;
  }

  /// Columna de aparición centrada según el ancho de la pieza.
  static int spawnColumn(PieceType type) {
    switch (type) {
      case PieceType.I:
        return 3;
      case PieceType.O:
        return 4;
      default:
        return 3;
    }
  }

  static int spawnRow(PieceType type) => 0;

  /// Grayscale colors for minimalist Playdate aesthetic.
  /// Each piece type has a distinct gray value for visual clarity.
  static const Map<PieceType, Color> pieceColors = {
    PieceType.I: Color(0xFFFFFFFF),  // Pure white - brightest
    PieceType.O: Color(0xFFE0E0E0),  // Off-white
    PieceType.T: Color(0xFFB0B0B0),  // Light gray
    PieceType.S: Color(0xFF808080),  // Medium gray
    PieceType.Z: Color(0xFF606060),  // Gray
    PieceType.J: Color(0xFF404040),  // Dark gray
    PieceType.L: Color(0xFF505050),  // Slightly lighter dark gray
  };
}
