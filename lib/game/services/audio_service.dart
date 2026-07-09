import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/sound_generator.dart';
import 'persistence_service.dart';

/// Servicio singleton de efectos de sonido.
///
/// Genera sonidos WAV sintéticos programáticamente ([SoundGenerator])
/// y los reproduce con [audioplayers]. No requiere archivos de audio externos.
class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._();

  bool _enabled = true;
  bool _initialized = false;
  final Map<String, Uint8List> _sounds = {};
  final List<AudioPlayer> _players = [];

  bool get enabled => _enabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _enabled = PersistenceService.instance.isSoundEnabled();

    _sounds['move'] = SoundGenerator.generateMoveSound();
    _sounds['rotate'] = SoundGenerator.generateRotateSound();
    _sounds['line_clear'] = SoundGenerator.generateLineClearSound();
    _sounds['game_over'] = SoundGenerator.generateGameOverSound();
    _sounds['drop'] = SoundGenerator.generateDropSound();
    _sounds['hard_drop'] = SoundGenerator.generateHardDropSound();
  }

  void setEnabled(bool value) {
    _enabled = value;
    PersistenceService.instance.setSoundEnabled(value);
  }

  Future<void> playMove() async {
    await _play('move');
  }

  Future<void> playRotate() async {
    await _play('rotate');
  }

  Future<void> playLineClear() async {
    await _play('line_clear');
  }

  Future<void> playGameOver() async {
    await _play('game_over');
  }

  Future<void> playDrop() async {
    await _play('drop');
  }

  Future<void> playHardDrop() async {
    await _play('hard_drop');
  }

  Future<void> _play(String name) async {
    if (!_enabled) return;
    final bytes = _sounds[name];
    if (bytes == null) return;

    try {
      final player = AudioPlayer();
      _players.add(player);
      player.onPlayerComplete.listen((_) {
        _players.remove(player);
        player.dispose();
      });
      await player.setSourceBytes(bytes);
      player.resume();
    } catch (e) {
      debugPrint('[Audio] Error playing $name: $e');
    }
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
    _players.clear();
  }
}
