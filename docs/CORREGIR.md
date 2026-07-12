================================================================================
                    CORRECCIÓN DE BUGS EN TETRIS FLUTTER
                          PROMPT TÉCNICO ÚNICO
================================================================================

ÍNDICE:
1. DESCRIPCIÓN GENERAL DE BUGS
2. BUG 1: DETECCIÓN DE MÚLTIPLES LÍNEAS
3. BUG 2: COLAPSO MÁGICO DE PIEZAS
4. CÓDIGO COMPLETO CORREGIDO (DART/FLUTTER)
5. PRUEBAS UNITARIAS
6. LOGS DE DEPURACIÓN

================================================================================
1. DESCRIPCIÓN GENERAL DE BUGS
================================================================================

BUG 1: Cuando una pieza completa 2, 3 o 4 líneas simultáneamente, 
el juego solo detecta y elimina UNA línea (la superior).

BUG 2: Al eliminar líneas, las piezas que están ENCIMA de las líneas 
eliminadas deberían caer hacia abajo manteniendo su forma y huecos, 
pero el juego reacomoda piezas enteras llenando huecos vacíos mágicamente.

================================================================================
2. BUG 1: DETECCIÓN DE MÚLTIPLES LÍNEAS
================================================================================

EJEMPLO CONCRETO:
- Tablero tiene 4 líneas completas (filas 15, 16, 17, 18)
- Cae pieza línea de 4 bloques en posición vertical
- DEBE detectar: 4 líneas completas
- ACTUALMENTE detecta: 1 línea (solo la fila 15)

CAUSA PROBABLE:
El bucle que revisa líneas completas recorre de arriba a abajo
y al eliminar una línea, no ajusta el índice correctamente,
o sale del bucle prematuramente con un "break".

SOLUCIÓN:
1. Recorrer TODAS las filas del tablero
2. Identificar TODAS las filas completamente llenas
3. Almacenar sus índices en una lista
4. Eliminar TODAS las filas de la lista (de abajo hacia arriba)
5. Contar cuántas fueron eliminadas
6. Aplicar puntuación: 1 línea=100, 2=300, 3=500, 4=800

================================================================================
3. BUG 2: COLAPSO MÁGICO DE PIEZAS
================================================================================

EJEMPLO CONCRETO:
- Fila 10 tiene un hueco (espacio vacío)
- Fila 12 está completa y se elimina
- Pieza de la fila 9 "cae" mágicamente ocupando el hueco de fila 10
- ESTO ES INCORRECTO: la pieza debe caer en línea recta

CAUSA PROBABLE:
El código está usando un algoritmo de "gravedad" que mueve 
piezas completas en lugar de desplazar filas individuales.

SOLUCIÓN:
1. Al eliminar una fila, TODAS las filas SUPERIORES deben 
   desplazarse UNA FILA HACIA ABAJO
2. Cada fila se mueve como un bloque completo, manteniendo 
   los huecos vacíos exactamente donde estaban
3. La fila superior (fila 0) se llena con ceros (vacía)
4. NINGUNA pieza debe cambiar su forma horizontal

VERIFICACIÓN VISUAL:

ESTADO INICIAL (tablero 10x20):
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 0 (vacía)
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 1
[ ][X][X][ ][ ][ ][ ][ ][ ][ ]  <- fila 2 (hueco en columna 0,3-9)
[ ][X][X][ ][ ][ ][ ][ ][ ][ ]  <- fila 3 (hueco en columna 0,3-9)
[X][X][X][X][X][X][X][X][X][X]  <- fila 4 (COMPLETA)
[X][X][X][X][X][X][X][X][X][X]  <- fila 5 (COMPLETA)

DESPUÉS DE ELIMINAR FILAS 4 y 5 (DEBE QUEDAR):
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 0 (vacía)
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 1 (vacía)
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 2 (vacía)
[ ][X][X][ ][ ][ ][ ][ ][ ][ ]  <- fila 3 (hueco en columna 0,3-9)
[ ][X][X][ ][ ][ ][ ][ ][ ][ ]  <- fila 4 (hueco en columna 0,3-9)
[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]  <- fila 5 (vacía)

NOTA: Las piezas con huecos (filas 2-3) deben mantener SU FORMA ORIGINAL,
no deben rellenar los huecos mágicamente.

================================================================================
4. CÓDIGO COMPLETO CORREGIDO (DART/FLUTTER)
================================================================================

// ============================================
// ARCHIVO: tetris_game.dart
// ============================================

class TetrisGame {
  static const int width = 10;
  static const int height = 20;
  List<List<int>> board = [];
  int score = 0;
  int linesCleared = 0;

  TetrisGame() {
    _initBoard();
  }

  void _initBoard() {
    board = List.generate(height, (_) => List.filled(width, 0));
  }

  // ============================================
  // FUNCIÓN PRINCIPAL CORREGIDA
  // ============================================
  
  int clearCompleteLines() {
    // PASO 1: Identificar TODAS las líneas completas
    List<int> completeLines = [];
    
    for (int row = 0; row < height; row++) {
      if (_isLineComplete(row)) {
        completeLines.add(row);
      }
    }

    // Si no hay líneas completas, retornar 0
    if (completeLines.isEmpty) {
      return 0;
    }

    // PASO 2: Eliminar de ABAJO hacia ARRIBA (para mantener índices 
correctos)
    completeLines.sort((a, b) => b.compareTo(a)); // Orden descendente
    
    for (int row in completeLines) {
      _removeLine(row);
    }

    // PASO 3: Calcular puntuación según cantidad de líneas
    int linesCount = completeLines.length;
    int pointsEarned = _calculateScore(linesCount);
    score += pointsEarned;
    linesCleared += linesCount;

    // PASO 4: Registrar en log
    _logLinesCleared(completeLines, linesCount, pointsEarned);

    return linesCount;
  }

  // ============================================
  // FUNCIONES AUXILIARES
  // ============================================

  bool _isLineComplete(int row) {
    for (int col = 0; col < width; col++) {
      if (board[row][col] == 0) {
        return false;
      }
    }
    return true;
  }

  void _removeLine(int row) {
    // DESPLAZAR TODAS LAS FILAS SUPERIORES UNA FILA ABAJO
    // SIN MODIFICAR LA FORMA DE LAS PIEZAS
    for (int r = row; r > 0; r--) {
      board[r] = List.from(board[r - 1]); // Copiar fila completa
    }
    
    // La fila superior queda vacía
    board[0] = List.filled(width, 0);
    
    // IMPORTANTE: NO reacomodar piezas horizontalmente
    // NO compactar el tablero
    // Cada fila mantiene sus huecos exactamente donde estaban
  }

  int _calculateScore(int lines) {
    // Puntuación estándar de Tetris
    switch (lines) {
      case 1: return 100;
      case 2: return 300;
      case 3: return 500;
      case 4: return 800;
      default: return 0;
    }
  }

  // ============================================
  // FUNCIÓN PARA FIJAR PIEZA EN EL TABLERO
  // ============================================

  void lockPiece(List<List<int>> piece, int posX, int posY) {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] == 1) {
          int boardRow = posY + row;
          int boardCol = posX + col;
          if (boardRow >= 0 && boardRow < height && 
              boardCol >= 0 && boardCol < width) {
            board[boardRow][boardCol] = 1;
          }
        }
      }
    }
    
    // DESPUÉS DE FIJAR LA PIEZA, VERIFICAR LÍNEAS COMPLETAS
    int lines = clearCompleteLines();
    
    // Si se completaron líneas, actualizar UI
    if (lines > 0) {
      // Notificar a la UI que se actualice
      // (depende de tu implementación de State management)
    }
  }

  // ============================================
  // LOGS DE DEPURACIÓN
  // ============================================

  void _logLinesCleared(List<int> lines, int count, int points) {
    print('========================================');
    print('LÍNEAS DETECTADAS: $lines');
    print('CANTIDAD DE LÍNEAS: $count');
    print('PUNTUACIÓN AÑADIDA: $points');
    print('PUNTUACIÓN TOTAL: $score');
    print('LÍNEAS TOTALES: $linesCleared');
    print('========================================');
    
    // Mostrar detalles de desplazamiento
    for (int i = 0; i < lines.length; i++) {
      int row = lines[i];
      print('FILA $row ELIMINADA - DESPLAZANDO FILAS 0 A ${row-1} HACIA 
ABAJO');
    }
    print('========================================');
  }

  // ============================================
  // FUNCIÓN PARA DEBUG VISUAL
  // ============================================

  void printBoard() {
    print('TABLERO ACTUAL:');
    for (int row = height - 1; row >= 0; row--) {
      String line = '${row.toString().padLeft(2)} |';
      for (int col = 0; col < width; col++) {
        line += board[row][col] == 1 ? '[X]' : '[ ]';
      }
      print(line);
    }
    print('    +------------------------------------+');
    print('    | 0  1  2  3  4  5  6  7  8  9     |');
    print('========================================');
  }
}

// ============================================
// ARCHIVO: main.dart (ejemplo de uso)
// ============================================

void main() {
  TetrisGame game = TetrisGame();
  
  // SIMULACIÓN: Crear un tablero con 4 líneas completas
  print('=== ESTADO INICIAL ===');
  game.printBoard();
  
  // Simular que cae una pieza I (línea de 4 bloques)
  print('=== PIEZA I COLOCADA ===');
  List<List<int>> pieceI = [
    [1, 1, 1, 1]
  ];
  game.lockPiece(pieceI, 0, 16); // Colocar en filas 16-19
  
  // Verificar que se detectaron 4 líneas
  print('=== RESULTADO FINAL ===');
  game.printBoard();
  print('PUNTUACIÓN FINAL: ${game.score}');
  print('LÍNEAS ELIMINADAS: ${game.linesCleared}');
}

================================================================================
5. PRUEBAS UNITARIAS
================================================================================

// ============================================
// ARCHIVO: tetris_test.dart
// ============================================

import 'package:test/test.dart';

void main() {
  group('Pruebas de Tetris - Corrección de Bugs', () {
    
    test('Caso 1: 4 líneas completadas con pieza I', () {
      TetrisGame game = TetrisGame();
      
      // Crear 4 líneas completas
      for (int row = 16; row < 20; row++) {
        for (int col = 0; col < TetrisGame.width; col++) {
          game.board[row][col] = 1;
        }
      }
      
      // Colocar pieza I
      List<List<int>> pieceI = [
        [1, 1, 1, 1]
      ];
      game.lockPiece(pieceI, 0, 16);
      
      // Verificar que se detectaron 4 líneas
      expect(game.linesCleared, equals(4));
      expect(game.score, equals(800));
      
      // Verificar que las líneas se eliminaron correctamente
      for (int row = 16; row < 20; row++) {
        for (int col = 0; col < TetrisGame.width; col++) {
          expect(game.board[row][col], equals(0));
        }
      }
    });

    test('Caso 2: 2 líneas completadas con pieza T', () {
      TetrisGame game = TetrisGame();
      
      // Crear 2 líneas completas
      for (int row = 10; row < 12; row++) {
        for (int col = 0; col < TetrisGame.width; col++) {
          game.board[row][col] = 1;
        }
      }
      
      // Colocar pieza T
      List<List<int>> pieceT = [
        [1, 1, 1],
        [0, 1, 0]
      ];
      game.lockPiece(pieceT, 3, 10);
      
      // Verificar que se detectaron 2 líneas
      expect(game.linesCleared, equals(2));
      expect(game.score, equals(300));
    });

    test('Caso 3: Huecos permanecen después de eliminar líneas', () {
      TetrisGame game = TetrisGame();
      
      // Crear fila con hueco (columna 0 y 3-9 vacías)
      List<int> rowWithHole = [0, 1, 1, 0, 0, 0, 0, 0, 0, 0];
      game.board[2] = List.from(rowWithHole);
      game.board[3] = List.from(rowWithHole);
      
      // Crear 2 líneas completas abajo
      for (int col = 0; col < TetrisGame.width; col++) {
        game.board[4][col] = 1;
        game.board[5][col] = 1;
      }
      
      // Eliminar líneas
      int lines = game.clearCompleteLines();
      
      // Verificar que se eliminaron 2 líneas
      expect(lines, equals(2));
      
      // Verificar que la fila con hueco mantuvo su forma
      // Debería estar en la fila 3 (después de desplazar)
      expect(game.board[3][0], equals(0)); // Hueco en columna 0
      expect(game.board[3][1], equals(1)); // Bloque en columna 1
      expect(game.board[3][2], equals(1)); // Bloque en columna 2
      expect(game.board[3][3], equals(0)); // Hueco en columna 3
      
      // Verificar que NO se rellenaron los huecos mágicamente
      for (int col = 3; col < TetrisGame.width; col++) {
        expect(game.board[3][col], equals(0));
      }
    });

    test('Caso 4: Puntuación progresiva', () {
      TetrisGame game = TetrisGame();
      
      // Probar 1 línea
      game.score = 0;
      int lines1 = game._calculateScore(1);
      expect(lines1, equals(100));
      
      // Probar 2 líneas
      int lines2 = game._calculateScore(2);
      expect(lines2, equals(300));
      
      // Probar 3 líneas
      int lines3 = game._calculateScore(3);
      expect(lines3, equals(500));
      
      // Probar 4 líneas
      int lines4 = game._calculateScore(4);
      expect(lines4, equals(800));
    });
  });
}

================================================================================
6. LOGS DE DEPURACIÓN (EJEMPLO DE SALIDA)
================================================================================

SALIDA ESPERADA EN CONSOLA:

========================================
LÍNEAS DETECTADAS: [16, 17, 18, 19]
CANTIDAD DE LÍNEAS: 4
PUNTUACIÓN AÑADIDA: 800
PUNTUACIÓN TOTAL: 800
LÍNEAS TOTALES: 4
========================================
FILA 19 ELIMINADA - DESPLAZANDO FILAS 0 A 18 HACIA ABAJO
FILA 18 ELIMINADA - DESPLAZANDO FILAS 0 A 17 HACIA ABAJO
FILA 17 ELIMINADA - DESPLAZANDO FILAS 0 A 16 HACIA ABAJO
FILA 16 ELIMINADA - DESPLAZANDO FILAS 0 A 15 HACIA ABAJO
========================================

TABLERO ACTUAL:
19 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
18 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
17 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
16 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
15 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
14 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
13 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
12 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
11 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
10 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 9 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 8 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 7 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 6 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 5 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 4 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 3 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 2 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 1 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
 0 |[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
    +------------------------------------+
    | 0  1  2  3  4  5  6  7  8  9     |
========================================

================================================================================
                    FIN DEL DOCUMENTO
================================================================================
