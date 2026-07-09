import 'package:flutter/material.dart';

/// Enum de dificultades seleccionables.
///
/// Cada valor tiene una [DifficultyConfig] asociada que define
/// velocidad, puntaje y apariencia.
enum Difficulty { easy, normal, hard, expert }

/// Configuración completa de una dificultad.
///
/// Controla la curva de velocidad, el multiplicador de puntaje,
/// el nivel inicial y los colores del tema.
class DifficultyConfig {
  final Difficulty difficulty;
  final String name;
  final String description;
  final Color color;
  final Color accentColor;

  /// Intervalo base de caída automática en segundos (nivel 1).
  final double baseDropInterval;

  /// Intervalo mínimo de caída (nunca más rápido que esto).
  final double minDropInterval;

  /// Reducción de intervalo por nivel.
  final double dropIntervalDecrement;

  /// Nivel en el que comienza la partida.
  final int startLevel;

  /// Multiplicador global de puntaje.
  final double scoreMultiplier;

  const DifficultyConfig({
    required this.difficulty,
    required this.name,
    required this.description,
    required this.color,
    required this.accentColor,
    required this.baseDropInterval,
    required this.minDropInterval,
    required this.dropIntervalDecrement,
    required this.startLevel,
    required this.scoreMultiplier,
  });

  // ─── Pre-sets ──────────────────────────────────────────

  static const easy = DifficultyConfig(
    difficulty: Difficulty.easy,
    name: 'EASY',
    description: 'Slow drop, standard score',
    color: Color(0xFFE0E0E0),      // Off-white for easy
    accentColor: Color(0xFF404040),
    baseDropInterval: 1.5,
    minDropInterval: 0.15,
    dropIntervalDecrement: 0.04,
    startLevel: 1,
    scoreMultiplier: 0.8,
  );

  static const normal = DifficultyConfig(
    difficulty: Difficulty.normal,
    name: 'NORMAL',
    description: 'Classic speed, standard score',
    color: Color(0xFFB0B0B0),      // Light gray for normal
    accentColor: Color(0xFF333333),
    baseDropInterval: 1.0,
    minDropInterval: 0.05,
    dropIntervalDecrement: 0.05,
    startLevel: 1,
    scoreMultiplier: 1.0,
  );

  static const hard = DifficultyConfig(
    difficulty: Difficulty.hard,
    name: 'HARD',
    description: 'Fast drop, bonus score',
    color: Color(0xFF808080),       // Medium gray for hard
    accentColor: Color(0xFF222222),
    baseDropInterval: 0.7,
    minDropInterval: 0.03,
    dropIntervalDecrement: 0.055,
    startLevel: 3,
    scoreMultiplier: 1.5,
  );

  static const expert = DifficultyConfig(
    difficulty: Difficulty.expert,
    name: 'EXPERT',
    description: 'Maximum speed, premium score',
    color: Color(0xFF404040),       // Dark gray for expert
    accentColor: Color(0xFF111111),
    baseDropInterval: 0.45,
    minDropInterval: 0.02,
    dropIntervalDecrement: 0.06,
    startLevel: 5,
    scoreMultiplier: 2.0,
  );

  static const List<DifficultyConfig> all = [easy, normal, hard, expert];

  static DifficultyConfig fromEnum(Difficulty d) {
    return all.firstWhere((c) => c.difficulty == d);
  }
}
