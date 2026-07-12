---
name: tetris-game
description: Use when working on the Flutter Tetris game project. Covers build, run, architecture, difficulty levels, scoring, and common modifications for this arcade-style Tetris clone built with Flutter.
---

# Tetris Game

Minimalist Playdate-inspired Tetris con estética grayscale. Flutter para Android.

## Quick Start

```bash
cd tetris_flt
flutter pub get
flutter run
```

## Project Architecture

```
lib/
├── main.dart                          # Entry point → PersistenceService init → MenuScreen
├── theme/
│   ├── app_theme.dart                 # 4 themes: light, dark, lightGray, darkGray
│   └── playdate_theme.dart            # Grayscale palette (legacy, not actively used)
├── game/
│   ├── models/
│   │   ├── position.dart              # (row, col) coordinate class
│   │   ├── piece.dart                 # PieceType enum + Piece class
│   │   ├── game_state.dart            # GameState enum (playing/paused/gameOver)
│   │   ├── difficulty.dart            # 4 difficulty presets with configs
│   │   ├── theme_mode.dart            # GameThemeMode enum (light/dark/lightGray/darkGray)
│   │   └── settings.dart              # GameSettings (ChangeNotifier) — theme, sound, filled
│   ├── logic/
│   │   ├── board.dart                 # Grid 10×20, collision, fixPiece, clearLines, removeRows
│   │   ├── scoring.dart               # Score + combos + back-to-back + T-Spin + difficulty
│   │   └── tetris_engine.dart         # Main game controller (ChangeNotifier + Ticker loop)
│   ├── widgets/
│   │   ├── game_board_widget.dart     # CustomPainter board + clearing lines flash
│   │   ├── piece_preview_widget.dart  # Next piece display
│   │   ├── score_panel_widget.dart    # Score / Level / Lines / Combo / Best
│   │   └── control_buttons_widget.dart # Touch controls with press feedback
│   ├── screens/
│   │   ├── menu_screen.dart           # Difficulty + theme selector + settings panel
│   │   └── game_screen.dart           # Game loop (Ticker) + score popups + overlays
│   ├── services/
│   │   ├── audio_service.dart         # Synthetic WAV sounds via audioplayers
│   │   └── persistence_service.dart   # SharedPreferences (high scores, settings)
│   └── utils/
│       ├── constants.dart             # Board size, scoring values, combo configs
│       ├── tetromino_data.dart        # 7 pieces × 4 rotations + grayscale colors
│       └── sound_generator.dart       # Programmatic WAV generation (no audio files)
docs/
├── COMPILE.md                         # Remote compilation commands
├── LEARNINGS.md                       # Git push, remote build, common errors
└── README.md                          # (if exists)
```

## Temas (4 modos)

| Modo       | Botón   | Fondo      | Texto      |
|------------|---------|------------|------------|
| Light      | WHITE   | `#FFFFFF`  | negro      |
| Dark       | BLACK   | `#000000`  | blanco     |
| Light Gray | GRAY+   | `#D0D0D0`  | oscuro     |
| Dark Gray  | GRAY-   | `#2A2A2A`  | claro      |

- Selector en Settings del menú (4 botones en fila)
- Se persiste via `SharedPreferences` (`theme_mode` key)
- `settings.darkMode` retorna `true` para dark y darkGray

## Configuración Persistida

| Key               | Tipo   | Default | Descripción                    |
|-------------------|--------|---------|--------------------------------|
| `theme_mode`      | String | light   | Modo de tema activo            |
| `filled_blocks`   | Bool   | true    | Bloques sólidos vs wireframe   |
| `sound_enabled`   | Bool   | true    | Sonido activado                |
| `difficulty`      | String | normal  | Última dificultad seleccionada |
| `high_score_<d>`  | Int    | 0       | High score por dificultad      |
| `last_level`      | Int    | 1       | Último nivel alcanzado         |

## Dificultades

| Nivel    | Caída base | Reducción/nivel | Nivel inicial | Multiplicador | Color     |
|----------|------------|-----------------|---------------|---------------|-----------|
| EASY     | 1.5s       | 0.04s           | 1             | 0.8×          | `#E0E0E0` |
| NORMAL   | 1.0s       | 0.05s           | 1             | 1.0×          | `#B0B0B0` |
| HARD     | 0.7s       | 0.055s          | 3             | 1.5×          | `#808080` |
| EXPERT   | 0.45s      | 0.06s           | 5             | 2.0×          | `#404040` |

## Sistema de Puntaje

- **Base**: Single=100, Double=300, Triple=500, Tetris=800 (× nivel × multiplicador dificultad)
- **Combo**: +50% por cada limpieza consecutiva (ventana de 3s)
- **Back-to-back Tetris**: +100% por cada Tetris consecutivo
- **T-Spin**: +100% + 50% por línea eliminada. Detección: ≥3 esquinas ocupadas
- **Soft drop**: 1pt/celda. **Hard drop**: 2pts/celda
- **Popups**: Animados con label (ej: "T-SPIN TETRIS ×3 B2B")

## Controles

- **Teclado**: ← → mover, ↑ rotar, ↓ soft drop, Espacio hard drop, P/Esc pausa
- **Touch**: Botones ROT/DROP/HARD/PAUSE + ← → con feedback visual (cambia color al presionar)

## State Management

`TetrisEngine` (ChangeNotifier) contiene:
- Board + Scoring + Difficulty + HighScore
- currentPiece / nextPiece
- Game loop via `update(dt)` desde `Ticker`
- Cola de popups animados (`ScorePopupEvent`)
- Timer para flash de líneas (150ms)
- T-Spin detection

## Key Architecture Decisions

- **Sin assets externos**: Sonidos WAV sintéticos (`SoundGenerator`), no archivos de audio
- **60 FPS**: Ticker de Flutter; engine acumula delta time para auto-drop
- **Rotación con wall kicks**: 8 offsets probados en orden
- **Async line clear**: Flash 150ms antes de eliminar líneas
- **Persistencia**: SharedPreferences con singleton `PersistenceService`
- **4 temas grayscale**: Selector visual con persistencia

## Build Commands

```bash
# Local
flutter run
flutter build apk --release

# Remoto (ver COMPILE.md para detalles)
sshpass -p '<PASS>' ssh <USER>@<HOST> "cd <PATH> && git pull && flutter clean && flutter pub get && flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk"
```

## Git Push (con token)

Cada push requiere token temporal + limpieza posterior:

```bash
# 1. Set URL con token
git remote set-url origin https://<USER>:<TOKEN>@github.com/<USER>/<REPO>.git

# 2. Push
git push origin <BRANCH>

# 3. Limpiar URL (quitar token)
git remote set-url origin https://github.com/<USER>/<REPO>.git
```

**NUNCA** commitear tokens o passwords en el repositorio.

## Version Tagging

Cada push debe incluir un tag que coincida con `pubspec.yaml`:

```bash
# Verificar versión
grep "^version:" pubspec.yaml

# Crear tag
git tag v1.1.0

# Push con tags
git push origin <BRANCH> --tags

# Actualizar tag existente
git tag -d v1.1.0 && git tag v1.1.0
git push origin <BRANCH> --tags --force
```

## Adding a New Piece Type

1. Add to `PieceType` enum in `models/piece.dart`
2. Add cells + bounding size in `utils/tetromino_data.dart`
3. Add color in `pieceColors` map (mismo archivo)
4. Ajustar `spawnColumn()` si el ancho difiere

## Adding a New Difficulty

1. Add enum value in `models/difficulty.dart`
2. Add config constant in `DifficultyConfig` (mismo archivo)
3. Add to `all` list
4. Ajustar `scoreMultiplier` y curvas de velocidad

## Adding a New Theme Mode

1. Add value to `GameThemeMode` enum in `models/theme_mode.dart`
2. Add colors in `GameSettings` getters (`backgroundColor`, `foregroundColor`, etc.)
3. Add `ThemeData` in `theme/app_theme.dart`
4. Update `AppTheme.forMode()` switch
5. Update `_themeModeShortLabel()` in `menu_screen.dart`

## Known Bugs

### Line clearing — solo detecta 1 línea
**Estado**: En investigación (logging agregado en `_lockPiece` y `removeRows`)
**Síntoma**: Cuando una pieza completa varias líneas simultáneamente, solo se reconoce 1
**Líneas afectadas**: `tetris_engine.dart:_lockPiece()`, `board.dart:removeRows()`
**Debug**: Buscar logs `[LINE]` y `[REMOVE]` en flutter logcat

### Errores conocidos
- `INSTALL_FAILED_USER_RESTRICTED`: usar `adb install -r` en vez de `flutter install`
- `ssh: connect timed out`: host remoto apagado o sin conexión
- `403 Permission denied`: usar token de GitHub para push

## Docs del Proyecto

- `docs/COMPILE.md` — Comandos de compilación remota (con credenciales del host)
- `docs/LEARNINGS.md` — Git push, remote build, errores comunes, tagging
