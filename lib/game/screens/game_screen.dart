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
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) {
        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: Scaffold(
            backgroundColor: widget.settings.backgroundColor,
            body: SafeArea(
              child: _buildBody(),
            ),
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
    return Stack(
      children: [
        Column(
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
        ),
        if (_engine.state == GameState.paused) _buildPauseOverlay(),
        if (_engine.state == GameState.gameOver) _buildGameOverOverlay(),
        _buildScorePopups(),
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
