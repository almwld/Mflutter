import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Generates a short stereo WAV in memory. The selected beat is the frequency
/// difference between channels, not an audible 7.83 Hz tone by itself.
class AudioSynthesisService {
  AudioSynthesisService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  static StreamSubscription<void>? _completionSubscription;
  static bool get isPlaying => _isPlaying;

  static Future<void> playBinauralBeat({
    required double beatHz,
    double carrierHz = 200,
    Duration duration = const Duration(seconds: 12),
    double volume = 0.18,
  }) async {
    if (beatHz <= 0 || beatHz > 40 || carrierHz <= 0 || carrierHz > 1500) {
      throw ArgumentError('Frequency is outside the supported safe range.');
    }
    if (duration <= Duration.zero || duration > const Duration(seconds: 60)) {
      throw ArgumentError('Duration must be between 1 ms and 60 seconds.');
    }

    await stop();
    final bytes = _buildStereoWav(
      leftHz: carrierHz,
      rightHz: carrierHz + beatHz,
      duration: duration,
      volume: volume.clamp(0.0, 0.5),
    );
    _isPlaying = true;
    await _completionSubscription?.cancel();
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
    try {
      await _player.play(BytesSource(bytes), volume: 1);
    } catch (_) {
      _isPlaying = false;
      rethrow;
    }
  }

  static Future<void> playTranquility() => playBinauralBeat(beatHz: 7.83);
  static Future<void> playFocus() => playBinauralBeat(beatHz: 14);
  static Future<void> playDeepMeditation() => playBinauralBeat(beatHz: 4);

  static Future<void> stop() async {
    _isPlaying = false;
    await _completionSubscription?.cancel();
    _completionSubscription = null;
    await _player.stop();
  }

  static Uint8List _buildStereoWav({
    required double leftHz,
    required double rightHz,
    required Duration duration,
    required double volume,
  }) {
    const sampleRate = 22050;
    const channels = 2;
    const bitsPerSample = 16;
    final sampleCount = (sampleRate * duration.inMicroseconds / 1000000).round();
    final dataSize = sampleCount * channels * (bitsPerSample ~/ 8);
    final bytes = ByteData(44 + dataSize);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
    bytes.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < sampleCount; i++) {
      final time = i / sampleRate;
      final fadeIn = math.min(1.0, time / 0.12);
      final remaining = duration.inMicroseconds / 1000000 - time;
      final fadeOut = math.min(1.0, remaining / 0.18);
      final envelope = math.min(fadeIn, fadeOut) * volume;
      final left = (math.sin(2 * math.pi * leftHz * time) * envelope * 32767).round();
      final right = (math.sin(2 * math.pi * rightHz * time) * envelope * 32767).round();
      final offset = 44 + i * 4;
      bytes.setInt16(offset, left, Endian.little);
      bytes.setInt16(offset + 2, right, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}