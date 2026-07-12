import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import '../logic/tetris_engine.dart';
import '../models/game_state.dart';
import '../models/difficulty.dart';
import '../models/settings.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/piece_preview_widget.dart';
import '../widgets/score_panel_widget.dart';
import '../widgets/control_buttons_widget.dart';
import '../services/audio_service.dart';
import 'menu_screen.dart';

/// Minimalist game screen with Playdate-inspired aesthetic.
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  final GameSettings settings;

  const GameScreen({
    super.key,
    this.difficulty = Difficulty.normal,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final TetrisEngine _engine;
  late final Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  Duration _previousTime = Duration.zero;
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _engine = TetrisEngine();
    _engine.setConfig(DifficultyConfig.fromEnum(widget.difficulty));
    _engine.addListener(_onEngineChanged);
    _ticker = createTicker(_onTick);
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await AudioService.instance.init();
      AudioService.instance.setEnabled(widget.settings.soundEnabled);
      _engine.init();
      _engine.startGame();
      _previousTime = Duration.zero;
      _ticker.start();
      if (mounted) {
        setState(() => _initialized = true);
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        _focusNode.requestFocus();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _initError = e.toString());
      }
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _previousTime == Duration.zero
        ? 0.0
        : (elapsed - _previousTime).inMicroseconds / 1000000;
    _previousTime = elapsed;
    _engine.update(dt);
  }

  void _onEngineChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _ticker.dispose();
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _engine.moveLeft();
      case LogicalKeyboardKey.arrowRight:
        _engine.moveRight();
      case LogicalKeyboardKey.arrowUp:
        _engine.rotate();
      case LogicalKeyboardKey.arrowDown:
        _engine.softDrop();
      case LogicalKeyboardKey.space:
        _engine.hardDrop();
      case LogicalKeyboardKey.keyP:
      case LogicalKeyboardKey.escape:
        _engine.togglePause();
      default:
        break;
    }
  }

  void _goToMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MenuScreen(settings: widget.settings),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) {
        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: Scaffold(
            backgroundColor: widget.settings.backgroundColor,
            body: isLandscape ? _buildBody() : SafeArea(child: _buildBody()),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_initError != null) {
      return _buildErrorScreen();
    }
    return _initialized ? _buildGameLayout() : _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: widget.settings.foregroundColor,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LOADING...',
            style: TextStyle(
              color: widget.settings.lightTextColor,
              fontSize: 10,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: widget.settings.lightTextColor, size: 48),
            const SizedBox(height: 16),
            Text(
              'ERROR',
              style: TextStyle(
                color: widget.settings.foregroundColor,
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _initError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.settings.lightTextColor, fontSize: 11),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initError = null;
                  _initialized = false;
                });
                _initializeGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.settings.foregroundColor,
                foregroundColor: widget.settings.backgroundColor,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('RETRY'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _goToMenu,
              child: Text(
                'MENU',
                style: TextStyle(color: widget.settings.lightTextColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameLayout() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Stack(
      children: [
        if (isLandscape) _buildLandscapeLayout() else _buildPortraitLayout(),
        if (_engine.state == GameState.paused) _buildPauseOverlay(),
        if (_engine.state == GameState.gameOver) _buildGameOverOverlay(),
        _buildScorePopups(),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        const SizedBox(height: 8),
        ScorePanelWidget(
          score: _engine.score,
          level: _engine.level,
          lines: _engine.lines,
          highScore: _engine.highScore,
          combo: _engine.combo,
          difficultyName: _engine.config.name,
          difficultyColor: _engine.config.color,
          settings: widget.settings,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GameBoardWidget(
                    engine: _engine,
                    settings: widget.settings,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PiecePreviewWidget(
                        piece: _engine.nextPiece,
                        settings: widget.settings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ControlButtonsWidget(
          onLeft: _engine.moveLeft,
          onRight: _engine.moveRight,
          onRotate: _engine.rotate,
          onSoftDrop: _engine.softDrop,
          onHardDrop: _engine.hardDrop,
          onPause: _engine.togglePause,
          settings: widget.settings,
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    final s = widget.settings;
    final screenH = MediaQuery.of(context).size.height;
    final boardW = screenH * 0.5;
    final cellSize = screenH / 20;

    return Row(
      children: [
        // ─── Left panel: Score + ROT/DROP + ← ───
        SizedBox(
          width: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: [
                _LandscapeLabel(label: 'SCORE', value: '${_engine.score}', settings: s),
                const SizedBox(height: 6),
                _LandscapeLabel(label: 'LEVEL', value: '${_engine.level}', settings: s),
                const SizedBox(height: 6),
                _LandscapeLabel(label: 'LINES', value: '${_engine.lines}', settings: s),
                const SizedBox(height: 6),
                _LandscapeLabel(label: 'BEST', value: '${_engine.highScore}', settings: s),
                if (_engine.combo > 1) ...[
                  const SizedBox(height: 6),
                  _LandscapeLabel(label: 'COMBO', value: '×${_engine.combo}', settings: s),
                ],
                const Spacer(),
                _LandscapeActionBtn(label: 'ROT', icon: Icons.rotate_90_degrees_ccw, onPressed: _engine.rotate, settings: s),
                const SizedBox(height: 4),
                _LandscapeActionBtn(label: 'DROP', icon: Icons.arrow_downward, onPressed: _engine.softDrop, settings: s),
                const SizedBox(height: 4),
                _LandscapeDirBtn(icon: Icons.chevron_left, onPressed: _engine.moveLeft, settings: s),
              ],
            ),
          ),
        ),
        // ─── Center: Game board (full height, centered) ───
        Expanded(
          child: Center(
            child: SizedBox(
              width: boardW,
              height: screenH,
              child: GameBoardWidget(
                engine: _engine,
                settings: s,
              ),
            ),
          ),
        ),
        // ─── Right panel: NEXT + HARD/PAUSE + → ───
        SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: [
                PiecePreviewWidget(
                  piece: _engine.nextPiece,
                  settings: s,
                  cellSize: cellSize,
                ),
                const Spacer(),
                _LandscapeActionBtn(label: 'HARD', icon: Icons.vertical_align_bottom, onPressed: _engine.hardDrop, settings: s),
                const SizedBox(height: 4),
                _LandscapeActionBtn(label: 'PAUSE', icon: Icons.pause, onPressed: _engine.togglePause, settings: s),
                const SizedBox(height: 4),
                _LandscapeDirBtn(icon: Icons.chevron_right, onPressed: _engine.moveRight, settings: s),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScorePopups() {
    if (_engine.scorePopups.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: _engine.scorePopups.map((popup) {
          return Positioned(
            top: 80.0 + (popup.row / 20) * 120,
            left: 0,
            right: 0,
            child: _ScorePopupWidget(
              key: ValueKey(popup.id),
              amount: popup.amount,
              label: popup.label,
              settings: widget.settings,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: widget.settings.backgroundColor.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: TextStyle(
                color: widget.settings.foregroundColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _engine.config.name,
              style: TextStyle(
                color: widget.settings.lightTextColor,
                fontSize: 12,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _engine.togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.settings.foregroundColor,
                  foregroundColor: widget.settings.backgroundColor,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  'RESUME',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _goToMenu,
              child: Text(
                'MENU',
                style: TextStyle(color: widget.settings.lightTextColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final isNewHighScore = _engine.score >= _engine.highScore && _engine.score > 0;
    return Container(
      color: widget.settings.backgroundColor.withOpacity(0.9),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: TextStyle(
                  color: widget.settings.foregroundColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.settings.borderColor),
                ),
                child: Text(
                  _engine.config.name,
                  style: TextStyle(
                    color: widget.settings.lightTextColor,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
              ),
              if (isNewHighScore) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.settings.foregroundColor),
                  ),
                  child: Text(
                    'NEW RECORD',
                    style: TextStyle(
                      color: widget.settings.foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '${_engine.score}',
                style: TextStyle(
                  color: widget.settings.foregroundColor,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LV ${_engine.level}  ·  ${_engine.lines} LINES',
                style: TextStyle(
                  color: widget.settings.lightTextColor,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: _engine.restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.settings.foregroundColor,
                    foregroundColor: widget.settings.backgroundColor,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _goToMenu,
                child: Text(
                  'MENU',
                  style: TextStyle(color: widget.settings.lightTextColor, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimalist score popup that appears when clearing lines.
class _ScorePopupWidget extends StatefulWidget {
  final int amount;
  final String label;
  final GameSettings settings;

  const _ScorePopupWidget({
    super.key,
    required this.amount,
    required this.label,
    required this.settings,
  });

  @override
  State<_ScorePopupWidget> createState() => _ScorePopupWidgetState();
}

class _ScorePopupWidgetState extends State<_ScorePopupWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Column(
          children: [
            Text(
              '+${widget.amount}',
              style: TextStyle(
                color: widget.settings.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            if (widget.label.isNotEmpty)
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.settings.lightTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Landscape score label for side panel.
class _LandscapeLabel extends StatelessWidget {
  final String label;
  final String value;
  final GameSettings settings;

  const _LandscapeLabel({
    required this.label,
    required this.value,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: settings.lightTextColor,
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: settings.foregroundColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// Landscape action button (ROT, DROP, HARD, PAUSE).
class _LandscapeActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final GameSettings settings;

  const _LandscapeActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.settings,
  });

  @override
  State<_LandscapeActionBtn> createState() => _LandscapeActionBtnState();
}

class _LandscapeActionBtnState extends State<_LandscapeActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final bg = _pressed ? s.borderColor : s.backgroundColor;
    final fg = _pressed ? s.backgroundColor : s.lightTextColor;
    final border = _pressed ? s.foregroundColor : s.borderColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 64,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: _pressed ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: fg, size: 16),
            Text(
              widget.label,
              style: TextStyle(
                color: fg,
                fontSize: 7,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Landscape direction button (← →).
class _LandscapeDirBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final GameSettings settings;

  const _LandscapeDirBtn({
    required this.icon,
    required this.onPressed,
    required this.settings,
  });

  @override
  State<_LandscapeDirBtn> createState() => _LandscapeDirBtnState();
}

class _LandscapeDirBtnState extends State<_LandscapeDirBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final bg = _pressed ? s.borderColor : s.backgroundColor;
    final fg = _pressed ? s.backgroundColor : s.lightTextColor;
    final border = _pressed ? s.foregroundColor : s.borderColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 64,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: _pressed ? 2 : 1),
        ),
        child: Icon(widget.icon, color: fg, size: 22),
      ),
    );
  }
}
