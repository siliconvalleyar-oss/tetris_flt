import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/game_state.dart';
import '../models/difficulty.dart';
import 'board.dart';
import 'scoring.dart';
import '../services/persistence_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/tetromino_data.dart';

/// Evento de popup de puntaje para la UI.
class ScorePopupEvent {
  final String id;
  final int amount;
  final String label;
  final int row;

  ScorePopupEvent({
    required this.id,
    required this.amount,
    required this.label,
    required this.row,
  });
}

/// Controlador principal del juego. Hereda de [ChangeNotifier] para
/// notificar a la UI ante cualquier cambio de estado.
///
/// Mejoras respecto a la versión base:
/// - Dificultad seleccionable (Easy / Normal / Hard / Expert).
/// - Sistema de combos y back-to-back Tetris.
/// - Detección básica de T-Spin.
/// - Líneas con flash antes de eliminarse.
/// - Popups de puntaje animados.
class TetrisEngine extends ChangeNotifier {
  final Board board = Board();
  late Scoring scoring;
  final Random _random = Random();

  Piece? _currentPiece;
  Piece? _nextPiece;
  GameState _state = GameState.playing;
  double _dropAccumulator = 0;
  int _highScore = 0;

  // ─── Dificultad ────────────────────────────────────────
  DifficultyConfig _config = DifficultyConfig.normal;

  // ─── T-Spin ────────────────────────────────────────────
  bool _lastActionWasRotate = false;

  // ─── Líneas en flash ───────────────────────────────────
  Set<int> _clearingLines = {};
  Timer? _clearTimer;

  // ─── Popups ────────────────────────────────────────────
  final List<ScorePopupEvent> _scorePopups = [];
  int _popupCounter = 0;

  // ─── Getters ───────────────────────────────────────────

  Piece? get currentPiece => _currentPiece;
  Piece? get nextPiece => _nextPiece;
  GameState get state => _state;
  int get score => scoring.score;
  int get level => scoring.level;
  int get lines => scoring.lines;
  int get highScore => _highScore;
  int get combo => scoring.combo;
  DifficultyConfig get config => _config;
  Set<int> get clearingLines => _clearingLines;
  List<ScorePopupEvent> get scorePopups => List.unmodifiable(_scorePopups);
  ScorePopupEvent? get lastPopup => _scorePopups.isEmpty ? null : _scorePopups.last;

  // ─── Inicialización ────────────────────────────────────

  /// Carga el puntaje máximo guardado para la dificultad actual.
  void init() {
    _highScore = PersistenceService.instance.getHighScore(_config.difficulty);
    notifyListeners();
  }

  /// Configura la dificultad (debe llamarse antes de [startGame]).
  void setConfig(DifficultyConfig config) {
    _config = config;
    scoring = Scoring(config: config);
    _highScore = PersistenceService.instance.getHighScore(config.difficulty);
    notifyListeners();
  }

  // ─── Flujo del juego ───────────────────────────────────

  /// Inicia una nueva partida con la dificultad actual.
  void startGame() {
    _clearTimer?.cancel();
    _clearingLines.clear();
    _scorePopups.clear();
    board.clear();
    scoring = Scoring(config: _config);
    _dropAccumulator = 0;
    _currentPiece = null;
    _nextPiece = _randomPiece();
    _state = GameState.playing;
    _lastActionWasRotate = false;
    _spawnPiece();
    notifyListeners();
  }

  /// Loop principal del juego. Llamado desde el [Ticker] cada frame.
  void update(double dt) {
    if (_state != GameState.playing || _currentPiece == null) return;

    _dropAccumulator += dt;
    final interval = scoring.dropInterval;

    while (_dropAccumulator >= interval) {
      _dropAccumulator -= interval;
      if (_tryMoveDown()) {
        _currentPiece!.row++;
        notifyListeners();
      } else {
        _lockPiece();
        break;
      }
    }
  }

  // ─── Input del jugador ─────────────────────────────────

  void moveLeft() {
    if (_state != GameState.playing || _currentPiece == null) return;
    _lastActionWasRotate = false;
    if (_tryMove(_currentPiece!.col - 1)) {
      _currentPiece!.col--;
      _onPieceMoved();
    }
  }

  void moveRight() {
    if (_state != GameState.playing || _currentPiece == null) return;
    _lastActionWasRotate = false;
    if (_tryMove(_currentPiece!.col + 1)) {
      _currentPiece!.col++;
      _onPieceMoved();
    }
  }

  void rotate() {
    if (_state != GameState.playing || _currentPiece == null) return;

    final int newRotation = (_currentPiece!.rotation + 1) % 4;
    final cells = TetrominoData.getCells(_currentPiece!.type, newRotation);

    for (final kick in _getWallKicks()) {
      final int testRow = _currentPiece!.row + kick.row;
      final int testCol = _currentPiece!.col + kick.col;

      if (!board.isCollision(cells, testRow, testCol)) {
        _currentPiece!.rotation = newRotation;
        _currentPiece!.row = testRow;
        _currentPiece!.col = testCol;
        _lastActionWasRotate = true;
        AudioService.instance.playRotate();
        notifyListeners();
        return;
      }
    }
    _lastActionWasRotate = false;
  }

  void softDrop() {
    if (_state != GameState.playing || _currentPiece == null) return;
    _lastActionWasRotate = false;
    if (_tryMoveDown()) {
      _currentPiece!.row++;
      scoring.addSoftDrop(1);
      _dropAccumulator = 0;
      notifyListeners();
    }
  }

  void hardDrop() {
    if (_state != GameState.playing || _currentPiece == null) return;
    _lastActionWasRotate = false;

    int dropped = 0;
    while (_tryMoveDown()) {
      _currentPiece!.row++;
      dropped++;
    }
    scoring.addHardDrop(dropped);
    AudioService.instance.playHardDrop();
    _lockPiece();
  }

  void togglePause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
    } else if (_state == GameState.paused) {
      _state = GameState.playing;
      _dropAccumulator = 0;
    } else if (_state == GameState.gameOver) {
      startGame();
      return;
    }
    notifyListeners();
  }

  void restart() {
    startGame();
  }

  void removePopup(String id) {
    _scorePopups.removeWhere((p) => p.id == id);
    if (hasListeners) notifyListeners();
  }

  // ─── Colisiones ────────────────────────────────────────

  bool _tryMoveDown() {
    return !board.isCollision(
      _currentPiece!.cells,
      _currentPiece!.row + 1,
      _currentPiece!.col,
    );
  }

  bool _tryMove(int newCol) {
    return !board.isCollision(
      _currentPiece!.cells,
      _currentPiece!.row,
      newCol,
    );
  }

  // ─── Fijación de pieza ─────────────────────────────────

  void _lockPiece() {
    if (_currentPiece == null) return;

    board.fixPiece(_currentPiece!);

    // Game over: pieza fijada completamente arriba
    if (_currentPiece!.row < 1) {
      _gameOver();
      return;
    }

    // Detectar líneas completas
    final detectedLines = <int>[];
    for (int r = GameConstants.boardHeight - 1; r >= 0; r--) {
      if (board.grid[r].every((cell) => cell != null)) {
        detectedLines.add(r);
      }
    }

    if (detectedLines.isNotEmpty) {
      _startLineClear(detectedLines);
    } else {
      scoring.resetCombo();
      _lastActionWasRotate = false;
      _spawnPiece();
    }
  }

  /// Inicia la animación de flash en las líneas detectadas.
  void _startLineClear(List<int> rows) {
    _clearingLines = rows.toSet();
    notifyListeners();

    final bool isTSpin = _detectTSpin();
    final int count = rows.length;

    _clearTimer?.cancel();
    _clearTimer = Timer(
      Duration(milliseconds: GameConstants.lineClearFlashMs),
      () {
        board.removeRows(rows);
        AudioService.instance.playLineClear();
        scoring.addLinesCleared(
          count,
          isTSpin: isTSpin,
          dt: GameConstants.lineClearFlashMs / 1000,
        );

        _addScorePopup(scoring.lastClearScore, scoring.lastClearLabel, rows.last);
        _saveProgress();

        _clearingLines = {};
        _lastActionWasRotate = false;
        _spawnPiece();
      },
    );
  }

  /// Detección básica de T-Spin.
  ///
  /// Condiciones:
  /// 1. La pieza actual es tipo T.
  /// 2. La última acción fue una rotación.
  /// 3. Al menos 3 de las 4 esquinas del bounding box 3×3 están ocupadas.
  bool _detectTSpin() {
    if (_currentPiece == null) return false;
    if (_currentPiece!.type != PieceType.T) return false;
    if (!_lastActionWasRotate) return false;

    final r = _currentPiece!.row;
    final c = _currentPiece!.col;

    final corners = [
      Position(r, c),
      Position(r, c + 2),
      Position(r + 2, c),
      Position(r + 2, c + 2),
    ];

    int occupied = 0;
    for (final corner in corners) {
      if (corner.row < 0 || corner.row >= GameConstants.boardHeight ||
          corner.col < 0 || corner.col >= GameConstants.boardWidth) {
        occupied++;
        continue;
      }
      if (board.grid[corner.row][corner.col] != null) {
        occupied++;
      }
    }

    return occupied >= 3;
  }

  // ─── Spawn ─────────────────────────────────────────────

  void _spawnPiece() {
    _currentPiece = _nextPiece;
    _nextPiece = _randomPiece();

    if (_currentPiece != null) {
      if (board.isCollision(
        _currentPiece!.cells,
        _currentPiece!.row,
        _currentPiece!.col,
      )) {
        _gameOver();
        return;
      }
    }

    _dropAccumulator = 0;
    notifyListeners();
  }

  Piece _randomPiece() {
    final types = PieceType.values;
    final type = types[_random.nextInt(types.length)];
    return Piece(
      type: type,
      row: TetrominoData.spawnRow(type),
      col: TetrominoData.spawnColumn(type),
      rotation: 0,
    );
  }

  // ─── Game Over ─────────────────────────────────────────

  void _gameOver() {
    _clearTimer?.cancel();
    _clearingLines = {};
    _state = GameState.gameOver;
    AudioService.instance.playGameOver();

    final diff = _config.difficulty;
    if (scoring.score > _highScore) {
      _highScore = scoring.score;
      PersistenceService.instance.setHighScore(_highScore, diff);
    }

    notifyListeners();
  }

  // ─── Persistencia ──────────────────────────────────────

  void _saveProgress() {
    final diff = _config.difficulty;
    PersistenceService.instance.setLastLevel(scoring.level);
    if (scoring.score > _highScore) {
      _highScore = scoring.score;
      PersistenceService.instance.setHighScore(_highScore, diff);
    }
  }

  void _onPieceMoved() {
    AudioService.instance.playMove();
    notifyListeners();
  }

  // ─── Popups ────────────────────────────────────────────

  void _addScorePopup(int amount, String label, int row) {
    final id = 'popup_${_popupCounter++}';
    final popup = ScorePopupEvent(id: id, amount: amount, label: label, row: row);
    _scorePopups.add(popup);
    notifyListeners();

    Future.delayed(
      Duration(milliseconds: GameConstants.scorePopupDurationMs),
      () {
        removePopup(id);
      },
    );
  }

  // ─── Wall Kicks ────────────────────────────────────────

  List<Position> _getWallKicks() {
    return [
      const Position(0, 0),
      const Position(0, -1),
      const Position(0, 1),
      const Position(-1, 0),
      const Position(0, -2),
      const Position(0, 2),
      const Position(-1, -1),
      const Position(-1, 1),
    ];
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    super.dispose();
  }
}
