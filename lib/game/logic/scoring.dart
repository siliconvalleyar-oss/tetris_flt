import '../utils/constants.dart';
import '../models/difficulty.dart';

/// Sistema de puntuación y niveles con combos y bonificaciones.
///
/// Soporta:
/// - Puntaje base por líneas (1-4) con multiplicador por nivel.
/// - Combo consecutivo (+50% por cada limpieza seguida).
/// - Back-to-back Tetris (+100%).
/// - T-Spin (+100% + 50% por línea).
/// - Multiplicador por dificultad.
/// - Soft / Hard drop.
class Scoring {
  DifficultyConfig _config;

  int _score = 0;
  int _level = 1;
  int _lines = 0;
  int _combo = 0;
  int _backToBackCount = 0;
  bool _lastWasTetris = false;
  double _lastClearTime = 0;
  int _lastClearScore = 0;
  String _lastClearLabel = '';

  Scoring({DifficultyConfig? config})
      : _config = config ?? DifficultyConfig.normal {
    _level = _config.startLevel;
  }

  // ─── Getters ───────────────────────────────────────────

  DifficultyConfig get config => _config;
  int get score => _score;
  int get level => _level;
  int get lines => _lines;
  int get combo => _combo;
  int get backToBackCount => _backToBackCount;
  int get lastClearScore => _lastClearScore;
  String get lastClearLabel => _lastClearLabel;

  set config(DifficultyConfig value) {
    _config = value;
  }

  /// Intervalo de caída automática según nivel y dificultad.
  double get dropInterval {
    final effectiveLevel = _level - _config.startLevel + 1;
    final interval = _config.baseDropInterval -
        (effectiveLevel - 1) * _config.dropIntervalDecrement;
    return interval.clamp(_config.minDropInterval, _config.baseDropInterval);
  }

  // ─── Reset ─────────────────────────────────────────────

  void reset() {
    _score = 0;
    _level = _config.startLevel;
    _lines = 0;
    _combo = 0;
    _backToBackCount = 0;
    _lastWasTetris = false;
    _lastClearTime = 0;
    _lastClearScore = 0;
    _lastClearLabel = '';
  }

  // ─── Puntaje ───────────────────────────────────────────

  /// Procesa la eliminación de [count] líneas.
  ///
  /// [isTSpin] indica si fue un T-Spin.
  /// [dt] es el tiempo transcurrido desde la última llamada (para combo timeout).
  void addLinesCleared(int count, {bool isTSpin = false, double dt = 0}) {
    if (count <= 0) return;

    _updateCombo(dt);

    int baseScore = _getBaseScore(count);

    // Multiplicador de dificultad
    double multiplier = _config.scoreMultiplier;

    // Combo
    if (_combo > 1) {
      multiplier += (_combo - 1) * GameConstants.comboMultiplierPerLevel;
    }

    // Back-to-back Tetris
    if (count == 4) {
      if (_lastWasTetris) {
        _backToBackCount++;
        multiplier += GameConstants.backToBackBonus * _backToBackCount;
      } else {
        _backToBackCount = 1;
      }
      _lastWasTetris = true;
    } else {
      _lastWasTetris = false;
      _backToBackCount = 0;
    }

    // T-Spin
    if (isTSpin) {
      multiplier += GameConstants.tSpinBonus;
      multiplier += count * GameConstants.tSpinLineBonus;
    }

    final totalScore = (baseScore * _level * multiplier).round();
    _score += totalScore;

    _lastClearScore = totalScore;
    _lastClearLabel = _buildLabel(count, isTSpin);

    _lines += count;
    _level = (_lines ~/ GameConstants.linesPerLevel) + _config.startLevel;
  }

  void addSoftDrop(int cells) {
    _score += cells * GameConstants.pointsSoftDrop;
  }

  void addHardDrop(int cells) {
    _score += cells * GameConstants.pointsHardDrop;
  }

  /// Reinicia el combo (llamado al fijar sin limpiar líneas).
  void resetCombo() {
    _combo = 0;
    _lastWasTetris = false;
    _backToBackCount = 0;
  }

  // ─── Privado ───────────────────────────────────────────

  int _getBaseScore(int count) {
    switch (count) {
      case 1:
        return GameConstants.pointsSingle;
      case 2:
        return GameConstants.pointsDouble;
      case 3:
        return GameConstants.pointsTriple;
      case 4:
        return GameConstants.pointsTetris;
      default:
        return 0;
    }
  }

  void _updateCombo(double dt) {
    if (dt > 0 && dt < GameConstants.comboTimeout) {
      _combo++;
    } else {
      _combo = 1;
    }
    _lastClearTime = DateTime.now().millisecondsSinceEpoch / 1000;
  }

  String _buildLabel(int count, bool isTSpin) {
    final buffer = StringBuffer();
    if (isTSpin) buffer.write('T-SPIN ');
    switch (count) {
      case 1:
        buffer.write('SINGLE');
      case 2:
        buffer.write('DOUBLE');
      case 3:
        buffer.write('TRIPLE');
      case 4:
        buffer.write('TETRIS');
    }
    if (_combo > 1) buffer.write(' ×$_combo');
    if (_backToBackCount > 1) buffer.write(' B2B');
    return buffer.toString();
  }
}
