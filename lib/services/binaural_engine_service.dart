import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// Generates a real stereo binaural tone locally and plays it through audioplayers.
/// The displayed beat frequency is the difference between the left and right channels.
class BinauralEngineService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _playing = false;
  static double _beatFrequency = 7.83;

  static bool get playing => _playing;
  static double get frequency => _beatFrequency;

  static Future<void> playTranquility() => _play(7.83);
  static Future<void> playFocus() => _play(14.0);
  static Future<void> playDeepMeditation() => _play(4.0);

  static Future<void> _play(double beatFrequency) async {
    _beatFrequency = beatFrequency;
    final bytes = _buildWav(
      durationSeconds: 8,
      sampleRate: 44100,
      carrierFrequency: 220,
      beatFrequency: beatFrequency,
    );
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(BytesSource(bytes), volume: 0.18);
    _playing = true;
  }

  static Future<void> stop() async {
    await _player.stop();
    _playing = false;
  }

  static String get currentMode {
    if (_beatFrequency <= 5) return 'تأمل عميق';
    if (_beatFrequency <= 10) return 'سكينة';
    return 'تركيز';
  }

  static Uint8List _buildWav({
    required int durationSeconds,
    required int sampleRate,
    required double carrierFrequency,
    required double beatFrequency,
  }) {
    final frames = durationSeconds * sampleRate;
    final dataSize = frames * 2 * 2;
    final bytes = ByteData(44 + dataSize);
    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 2, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 4, Endian.little);
    bytes.setUint16(32, 4, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    final fadeFrames = (sampleRate * 0.08).round();
    var offset = 44;
    for (var i = 0; i < frames; i++) {
      final t = i / sampleRate;
      var envelope = 1.0;
      if (i < fadeFrames) envelope = i / fadeFrames;
      final remaining = frames - i;
      if (remaining < fadeFrames) envelope = math.min(envelope, remaining / fadeFrames);
      final left = math.sin(2 * math.pi * carrierFrequency * t) * envelope * 0.75;
      final right = math.sin(2 * math.pi * (carrierFrequency + beatFrequency) * t) * envelope * 0.75;
      bytes.setInt16(offset, (left * 32767).round(), Endian.little);
      bytes.setInt16(offset + 2, (right * 32767).round(), Endian.little);
      offset += 4;
    }
    return bytes.buffer.asUint8List();
  }
}
