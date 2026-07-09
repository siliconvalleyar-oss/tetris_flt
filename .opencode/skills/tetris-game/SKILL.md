---
name: tetris-game
description: Use when working on the Flutter Tetris game project. Covers build, run, architecture, difficulty levels, scoring, and common modifications for this arcade-style Tetris clone built with Flutter.
---

# Tetris Game

Classic Tetris clone built with Flutter para Android e iOS.

## Quick Start

```bash
cd tetris_game
flutter pub get
flutter run
```

## Project Architecture

```
lib/
├── main.dart                      # Entry point → MenuScreen
├── theme/app_theme.dart           # Dark arcade theme
├── game/
│   ├── models/
│   │   ├── position.dart          # (row, col) coordinate class
│   │   ├── piece.dart             # Tetromino piece with type/rotation/position
│   │   ├── game_state.dart        # GameState enum (playing/paused/gameOver)
│   │   └── difficulty.dart        # Difficulty presets (Easy/Normal/Hard/Expert)
│   ├── logic/
│   │   ├── board.dart             # Grid 10×20, collision, line clearing, removeRows
│   │   ├── scoring.dart           # Score + combos + back-to-back + T-Spin + difficulty multiplier
│   │   └── tetris_engine.dart     # Main game controller (ChangeNotifier + game loop)
│   ├── widgets/
│   │   ├── game_board_widget.dart     # CustomPainter board + clearing lines flash
│   │   ├── piece_preview_widget.dart  # Next piece display
│   │   ├── score_panel_widget.dart    # Score / Level / Lines / Combo / Best
│   │   └── control_buttons_widget.dart # Touch controls
│   ├── screens/
│   │   ├── menu_screen.dart       # Difficulty selection + high scores per difficulty
│   │   └── game_screen.dart       # Game loop (Ticker) + score popups + overlays
│   ├── services/
│   │   ├── audio_service.dart     # Sound effects via audioplayers (synthetic WAV)
│   │   └── persistence_service.dart # SharedPreferences wrapper
│   └── utils/
│       ├── constants.dart         # Game constants (speeds, scoring, combos)
│       ├── tetromino_data.dart    # Piece shape definitions + colors
│       └── sound_generator.dart   # Programmatic WAV generation
```

## Dificultades

| Nivel    | Caída base | Reducción/nivel | Nivel inicial | Multiplicador | Color  |
| -------- | ---------- | --------------- | ------------- | ------------- | ------ |
| FÁCIL    | 1.5s       | 0.04s           | 1             | 0.8×          | Verde  |
| NORMAL   | 1.0s       | 0.05s           | 1             | 1.0×          | Azul   |
| DIFÍCIL  | 0.7s       | 0.055s          | 3             | 1.5×          | Naranja|
| EXPERTO  | 0.45s      | 0.06s           | 5             | 2.0×          | Rojo   |

Seleccionables desde el menú principal. High score guardado por dificultad.

## Sistema de Puntaje

- **Base**: Single=100, Double=300, Triple=500, Tetris=800 (× nivel × multiplicador dificultad).
- **Combo**: +50% por cada limpieza consecutiva (ventana de 3s).
- **Back-to-back Tetris**: +100% por cada Tetris consecutivo.
- **T-Spin**: +100% + 50% por línea eliminada. Detección: ≥3 esquinas ocupadas.
- **Soft drop**: 1pt/celda. **Hard drop**: 2pts/celda.
- **Visual**: Popups animados con el puntaje + etiqueta (ej: "T-SPIN TETRIS ×3 B2B").

## State Management

`TetrisEngine` (ChangeNotifier) contiene toda la lógica del juego:
- Board + Scoring + Difficulty
- currentPiece / nextPiece
- Game loop via `update(dt)` llamado desde Ticker
- Cola de popups animados
- Timer para flash de líneas

## Key Architecture Decisions

- **Sin assets externos**: Sonidos generados como WAV sintéticos programáticamente (`SoundGenerator`) y reproducidos con `audioplayers` via `setSourceBytes()`. No se requieren archivos de audio.
- **60 FPS**: Game loop con `Ticker` de Flutter; engine acumula delta time para auto-drop (gravedad).
- **Rotación con wall kicks**: 8 offsets probados en orden.
- **Async line clear**: Flash de 150ms en líneas completadas antes de eliminar.
- **Persistencia**: SharedPreferences guarda high score por dificultad, último nivel, sonido y dificultad seleccionada.

## Build Commands

```bash
# Run on connected device / emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

## Adding a New Piece Type

1. Add to `PieceType` enum en `models/piece.dart`
2. Add cells + bounding box size in `utils/tetromino_data.dart`
3. Add color in `pieceColors` map (mismo archivo)
4. Opcional: ajustar `spawnColumn()` si el ancho difiere

## Adding a New Difficulty

1. Add enum value in `models/difficulty.dart` `Difficulty`
2. Add config constant in `DifficultyConfig` (mismo archivo)
3. Add to `all` list (mismo archivo)
4. Opcional: ajustar `scoreMultiplier` y curvas de velocidad

## Troubleshooting

### Pantalla negra después de seleccionar dificultad

Si al presionar "JUGAR" la pantalla se queda en negro (o con el spinner de carga indefinidamente):

1. **Verificar errores en consola**: Ejecutar `flutter run` y revisar los logs. La versión actual atrapa errores de inicialización y los muestra en pantalla con botón "REINTENTAR".

2. **Causas comunes**:
   - Error en `SharedPreferences` (dispositivo sin almacenamiento o permisos)
   - Error en `Ticker.start()` si el `SchedulerBinding` no está listo
   - Excepción no atrapada en `_initializeGame()` (corregido con try-catch)

3. **Solución rápida**: La pantalla de error muestra el mensaje específico y permite reintentar o volver al menú.

4. **Si el menú no responde al teclado**: El `FocusNode` ahora solicita foco automáticamente después de 100ms. Si aún no responde, toca la pantalla para activar el `KeyboardListener`.

5. **Limpiar datos de la app**: Ir a Ajustes del dispositivo > Apps > Tetris > Borrar datos. Esto reinicia `SharedPreferences`.

### El juego se ve muy oscuro

El tema es intencionalmente oscuro (`scaffoldBackgroundColor: 0xFF050510`). Si no se distingue el tablero, ajustar el brillo del dispositivo o modificar `app_theme.dart` para usar un fondo más claro.

## Mejoras Futuras

- Ghost Piece (pieza fantasma)
- Hold Piece (pieza guardada)
- Rankings online (Firebase)
- Modo multijugador (WebSocket)
- Logros
- Temas visuales intercambiables
- Música de fondo
- Más modos de juego (Ultra, Sprint, Marathon)
