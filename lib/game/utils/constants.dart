/// Constantes globales del juego.
///
/// Centraliza valores de tamaño de tablero, puntajes,
/// velocidades y claves de persistencia para facilitar
/// el balanceo y la expansión futura.
class GameConstants {
  GameConstants._();

  // ─── Tablero ────────────────────────────────────────────
  static const int boardWidth = 10;
  static const int boardHeight = 20;

  // ─── Líneas por nivel ───────────────────────────────────
  static const int linesPerLevel = 10;

  // ─── Puntaje base ───────────────────────────────────────
  static const int pointsSingle = 100;
  static const int pointsDouble = 300;
  static const int pointsTriple = 500;
  static const int pointsTetris = 800;
  static const int pointsSoftDrop = 1;
  static const int pointsHardDrop = 2;

  // ─── Bonus de combos ────────────────────────────────────
  /// Multiplicador adicional por cada combo consecutivo (ej: 0.5 = +50%).
  static const double comboMultiplierPerLevel = 0.5;

  /// Multiplicador adicional por back-to-back Tetris.
  static const double backToBackBonus = 1.0;

  /// Multiplicador adicional por T-Spin.
  static const double tSpinBonus = 1.0;

  /// Multiplicador adicional por T-Spin con líneas.
  static const double tSpinLineBonus = 0.5;

  // ─── Límites de combo ───────────────────────────────────
  /// Ventana en segundos para mantener el combo vivo.
  static const double comboTimeout = 3.0;

  // ─── Animaciones ────────────────────────────────────────
  /// Duración del flash de líneas completadas (ms).
  static const int lineClearFlashMs = 150;

  /// Duración del popup de puntaje (ms).
  static const int scorePopupDurationMs = 1200;

  // ─── SharedPreferences ──────────────────────────────────
  static const String highScoreKey = 'high_score_';
  static const String lastLevelKey = 'last_level';
  static const String soundEnabledKey = 'sound_enabled';
  static const String difficultyKey = 'selected_difficulty';
  static const String darkModeKey = 'dark_mode';
  static const String filledBlocksKey = 'filled_blocks';
}
