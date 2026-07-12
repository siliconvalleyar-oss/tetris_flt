import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/difficulty.dart';

/// Servicio singleton para persistencia local via SharedPreferences.
///
/// Guarda: puntaje máximo por dificultad, último nivel alcanzado,
/// preferencia de sonido y dificultad seleccionada.
class PersistenceService {
  static final PersistenceService instance = PersistenceService._();
  PersistenceService._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  SharedPreferences get _p {
    assert(_initialized, 'PersistenceService not initialized. Call init() first.');
    return _prefs!;
  }

  /// High score para una dificultad específica.
  int getHighScore([Difficulty d = Difficulty.normal]) {
    return _p.getInt('${GameConstants.highScoreKey}${d.name}') ?? 0;
  }

  Future<void> setHighScore(int score, [Difficulty d = Difficulty.normal]) async {
    final current = getHighScore(d);
    if (score > current) {
      await _p.setInt('${GameConstants.highScoreKey}${d.name}', score);
    }
  }

  int getLastLevel() => _p.getInt(GameConstants.lastLevelKey) ?? 1;

  Future<void> setLastLevel(int level) async {
    await _p.setInt(GameConstants.lastLevelKey, level);
  }

  bool isSoundEnabled() => _p.getBool(GameConstants.soundEnabledKey) ?? true;

  Future<void> setSoundEnabled(bool enabled) async {
    await _p.setBool(GameConstants.soundEnabledKey, enabled);
  }

  /// Dificultad guardada por el usuario.
  Difficulty getDifficulty() {
    final name = _p.getString(GameConstants.difficultyKey);
    if (name == null) return Difficulty.normal;
    return Difficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => Difficulty.normal,
    );
  }

  Future<void> setDifficulty(Difficulty d) async {
    await _p.setString(GameConstants.difficultyKey, d.name);
  }

  bool isDarkMode() => _p.getBool(GameConstants.darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _p.setBool(GameConstants.darkModeKey, value);
  }

  bool isFilledBlocks() => _p.getBool(GameConstants.filledBlocksKey) ?? true;

  Future<void> setFilledBlocks(bool value) async {
    await _p.setBool(GameConstants.filledBlocksKey, value);
  }
}
