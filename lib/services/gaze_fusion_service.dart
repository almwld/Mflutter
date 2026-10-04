import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class GazeScreenPoint {
  const GazeScreenPoint({
    required this.x,
    required this.y,
    required this.confidence,
  });
  final double x;
  final double y;
  final double confidence;
}

class GazeFusionService {
  GazeFusionService._();
  static final instance = GazeFusionService._();

  double _yawScale = 1.0;
  double _yawBias = 0.0;
  double _pitchScale = 1.0;
  double _pitchBias = 0.0;
  double _emaX = 0.5;
  double _emaY = 0.5;
  static const _alpha = 0.32;

  bool get isCalibrated => _yawScale != 1.0 || _yawBias != 0.0 || _pitchScale != 1.0 || _pitchBias != 0.0;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _yawScale = p.getDouble('gaze_cal_yaw_scale') ?? 1.0;
    _yawBias = p.getDouble('gaze_cal_yaw_bias') ?? 0.0;
    _pitchScale = p.getDouble('gaze_cal_pitch_scale') ?? 1.0;
    _pitchBias = p.getDouble('gaze_cal_pitch_bias') ?? 0.0;
  }

  Future<void> clear() async {
    _yawScale = 1.0; _yawBias = 0.0;
    _pitchScale = 1.0; _pitchBias = 0.0;
    final p = await SharedPreferences.getInstance();
    for (final k in [
      'gaze_cal_yaw_scale','gaze_cal_yaw_bias',
      'gaze_cal_pitch_scale','gaze_cal_pitch_bias',
    ]) { await p.remove(k); }
  }

  GazeScreenPoint map({
    required double yawDegrees,
    required double pitchDegrees,
    required double width,
    required double height,
    double confidence = 1.0,
  }) {
    final xRaw = 0.5 + ((_yawScale * yawDegrees + _yawBias) / 360.0);
    final yRaw = 0.5 - ((_pitchScale * pitchDegrees + _pitchBias) / 360.0);
    final x = _emaX + _alpha * (xRaw.clamp(0.0, 1.0) - _emaX);
    final y = _emaY + _alpha * (yRaw.clamp(0.0, 1.0) - _emaY);
    _emaX = x; _emaY = y;
    return GazeScreenPoint(
      x: x * width,
      y: y * height,
      confidence: confidence,
    );
  }

  Future<void> fit({
    required List<GazeCalibrationSample> samples,
  }) async {
    if (samples.length < 4) {
      throw StateError('تحتاج المعايرة إلى أربع نقاط على الأقل.');
    }
    final yaw = _fitAxis(samples.map((s) => s.yawDegrees).toList(), samples.map((s) => s.targetX).toList());
    final pitch = _fitAxis(samples.map((s) => s.pitchDegrees).toList(), samples.map((s) => s.targetY).toList());
    _yawScale = yaw.$1;
    _yawBias = yaw.$2;
    _pitchScale = pitch.$1;
    _pitchBias = pitch.$2;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('gaze_cal_yaw_scale', _yawScale);
    await p.setDouble('gaze_cal_yaw_bias', _yawBias);
    await p.setDouble('gaze_cal_pitch_scale', _pitchScale);
    await p.setDouble('gaze_cal_pitch_bias', _pitchBias);
  }

  (double, double) _fitAxis(List<double> input, List<double> target) {
    var sumX = 0.0, sumY = 0.0, sumXX = 0.0, sumXY = 0.0;
    for (var i = 0; i < input.length; i++) {
      sumX += input[i]; sumY += target[i];
      sumXX += input[i] * input[i]; sumXY += input[i] * target[i];
    }
    final n = input.length.toDouble();
    final det = n * sumXX - sumX * sumX;
    if (det.abs() < 1e-9) return (1.0, 0.0);
    return ((n * sumXY - sumX * sumY) / det, (sumXX * sumY - sumX * sumXY) / det);
  }
}

class GazeCalibrationSample {
  const GazeCalibrationSample({
    required this.yawDegrees,
    required this.pitchDegrees,
    required this.targetX,
    required this.targetY,
  });
  final double yawDegrees;
  final double pitchDegrees;
  final double targetX;
  final double targetY;
}
