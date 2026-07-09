import 'dart:math' show pi, sin;
import 'dart:typed_data';

/// Genera bytes WAV válidos para efectos de sonido del juego.
///
/// Cada método produce un tono sintético diferente (movimiento, rotación,
/// línea completada, game over, drop) sin necesidad de archivos de audio externos.
class SoundGenerator {
  SoundGenerator._();

  static const int _sampleRate = 44100;

  /// Sonido corto para movimiento lateral (600 Hz, 50 ms).
  static Uint8List generateMoveSound() {
    return _generateWav(_generateTone(600, 0.05));
  }

  /// Sonido para rotación de pieza (800 Hz, 80 ms).
  static Uint8List generateRotateSound() {
    return _generateWav(_generateTone(800, 0.08));
  }

  /// Barrido ascendente para línea completada (500 → 1000 Hz, 300 ms).
  static Uint8List generateLineClearSound() {
    return _generateWav(_generateSweep(500, 1000, 0.3));
  }

  /// Barrido descendente para game over (400 → 100 Hz, 500 ms).
  static Uint8List generateGameOverSound() {
    return _generateWav(_generateSweep(400, 100, 0.5));
  }

  /// Tono grave para soft drop (150 Hz, 100 ms).
  static Uint8List generateDropSound() {
    return _generateWav(_generateTone(150, 0.1));
  }

  /// Tono muy grave para hard drop (100 Hz, 150 ms).
  static Uint8List generateHardDropSound() {
    return _generateWav(_generateTone(100, 0.15));
  }

  /// Genera samples de un tono senoidal puro con fade in/out.
  static List<int> _generateTone(double frequency, double duration) {
    final numSamples = (_sampleRate * duration).round();
    final samples = <int>[];
    const double fadeTime = 0.008;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / _sampleRate;
      final double value = sin(2 * pi * frequency * t);
      double envelope = 1.0;
      if (t < fadeTime) {
        envelope = t / fadeTime;
      } else if (t > duration - fadeTime) {
        envelope = (duration - t) / fadeTime;
      }
      samples.add((value * envelope * 30000).round().clamp(-32768, 32767));
    }
    return samples;
  }

  /// Genera samples con barrido de frecuencia (sweep) entre [startFreq] y [endFreq].
  ///
  /// Usa acumulación de fase para evitar discontinuidades en la onda.
  static List<int> _generateSweep(double startFreq, double endFreq, double duration) {
    final numSamples = (_sampleRate * duration).round();
    final samples = <int>[];
    const double fadeTime = 0.008;
    double phase = 0;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / _sampleRate;
      final double progress = t / duration;
      final double frequency = startFreq + (endFreq - startFreq) * progress;

      phase += 2 * pi * frequency / _sampleRate;

      final double value = sin(phase);
      double envelope = 1.0;
      if (t < fadeTime) {
        envelope = t / fadeTime;
      } else if (t > duration - fadeTime) {
        envelope = (duration - t) / fadeTime;
      }
      samples.add((value * envelope * 30000).round().clamp(-32768, 32767));
    }
    return samples;
  }

  /// Construye un archivo WAV válido (PCM 16-bit mono) a partir de samples.
  static Uint8List _generateWav(List<int> samples) {
    const int bitsPerSample = 16;
    const int numChannels = 1;
    final int sampleRate = _sampleRate;
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = samples.length * bitsPerSample ~/ 8;
    final int fileSize = 44 + dataSize;

    final bytes = ByteData(44 + dataSize);
    int offset = 0;

    void writeString(String s) {
      for (int i = 0; i < s.length; i++) {
        bytes.setUint8(offset++, s.codeUnitAt(i));
      }
    }

    void writeUint16(int value) {
      bytes.setUint16(offset, value, Endian.little);
      offset += 2;
    }

    void writeUint32(int value) {
      bytes.setUint32(offset, value, Endian.little);
      offset += 4;
    }

    writeString('RIFF');
    writeUint32(fileSize - 8);
    writeString('WAVE');

    writeString('fmt ');
    writeUint32(16);
    writeUint16(1);
    writeUint16(numChannels);
    writeUint32(sampleRate);
    writeUint32(byteRate);
    writeUint16(blockAlign);
    writeUint16(bitsPerSample);

    writeString('data');
    writeUint32(dataSize);

    for (final sample in samples) {
      writeUint16(sample);
    }

    return bytes.buffer.asUint8List();
  }
}
