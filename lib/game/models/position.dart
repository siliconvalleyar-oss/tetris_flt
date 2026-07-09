/// Coordenada (fila, columna) en el tablero de juego.
///
/// Se usa tanto para las celdas de las piezas como para
/// los desplazamientos (wall kicks) durante la rotación.
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) => Position(row + other.row, col + other.col);

  Position operator -(Position other) => Position(row - other.row, col - other.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode << 16);

  @override
  String toString() => '($row, $col)';
}
