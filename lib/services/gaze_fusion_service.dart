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
  bool _calibrated = false;
  static const _alpha = 0.32;

  bool get isCalibrated => _calibrated;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _yawScale = p.getDouble('gaze_cal_yaw_scale') ?? 1.0;
    _yawBias = p.getDouble('gaze_cal_yaw_bias') ?? 0.0;
    _pitchScale = p.getDouble('gaze_cal_pitch_scale') ?? 1.0;
    _pitchBias = p.getDouble('gaze_cal_pitch_bias') ?? 0.0;
    _calibrated = p.getBool('gaze_calibrated') ??
        (_yawScale != 1.0 || _yawBias != 0.0 || _pitchScale != 1.0 || _pitchBias != 0.0);
  }

  Future<void> clear() async {
    _yawScale = 1.0; _yawBias = 0.0;
    _pitchScale = 1.0; _pitchBias = 0.0;
    _emaX = 0.5; _emaY = 0.5; _calibrated = false;
    final p = await SharedPreferences.getInstance();
    for (final k in [
      'gaze_cal_yaw_scale','gaze_cal_yaw_bias',
      'gaze_cal_pitch_scale','gaze_cal_pitch_bias','gaze_calibrated',
    ]) { await p.remove(k); }
  }

  GazeScreenPoint map({
    required double yawDegrees,
    required double pitchDegrees,
    required double width,
    required double height,
    double confidence = 1.0,
  }) {
    final validSize = width.isFinite && height.isFinite && width > 0 && height > 0;
    final validSample = yawDegrees.isFinite &&
        pitchDegrees.isFinite &&
        confidence.isFinite;
    if (!validSize || !validSample) {
      // Ignore corrupt sensor frames without poisoning the EMA with NaN.
      return GazeScreenPoint(
        x: validSize ? _emaX * width : 0,
        y: validSize ? _emaY * height : 0,
        confidence: 0,
      );
    }

    final xRaw = isCalibrated ? (_yawScale * yawDegrees + _yawBias) : 0.5 + yawDegrees / 360.0;
    final yRaw = isCalibrated ? (_pitchScale * pitchDegrees + _pitchBias) : 0.5 - pitchDegrees / 360.0;
    final x = _emaX + _alpha * (xRaw.clamp(0.0, 1.0) - _emaX);
    final y = _emaY + _alpha * (yRaw.clamp(0.0, 1.0) - _emaY);
    _emaX = x; _emaY = y;
    return GazeScreenPoint(
      x: x * width,
      y: y * height,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }

  Future<void> fit({
    required List<GazeCalibrationSample> samples,
  }) async {
    if (samples.length < 9) {
      throw StateError('تحتاج المعايرة إلى تسع نقاط على الأقل.');
    }
    for (final sample in samples) {
      final values = <double>[
        sample.yawDegrees,
        sample.pitchDegrees,
        sample.targetX,
        sample.targetY,
      ];
      if (values.any((value) => !value.isFinite)) {
        throw StateError('بيانات المعايرة تحتوي على قيمة غير صالحة.');
      }
      if (sample.targetX < 0 || sample.targetX > 1 ||
          sample.targetY < 0 || sample.targetY > 1) {
        throw StateError('إحداثيات أهداف المعايرة يجب أن تكون بين 0 و1.');
      }
    }

    // Calculate both axes before mutating or persisting the current profile.
    // Constant sensor readings cannot define a mapping and must not silently
    // be accepted as a successful identity calibration.
    final yaw = _fitAxis(
      samples.map((s) => s.yawDegrees).toList(),
      samples.map((s) => s.targetX).toList(),
    );
    final pitch = _fitAxis(
      samples.map((s) => s.pitchDegrees).toList(),
      samples.map((s) => s.targetY).toList(),
    );

    _yawScale = yaw.$1;
    _yawBias = yaw.$2;
    _pitchScale = pitch.$1;
    _pitchBias = pitch.$2;
    _calibrated = true;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('gaze_cal_yaw_scale', _yawScale);
    await p.setDouble('gaze_cal_yaw_bias', _yawBias);
    await p.setDouble('gaze_cal_pitch_scale', _pitchScale);
    await p.setDouble('gaze_cal_pitch_bias', _pitchBias);
    await p.setBool('gaze_calibrated', true);
  }

  (double, double) _fitAxis(List<double> input, List<double> target) {
    var sumX = 0.0, sumY = 0.0, sumXX = 0.0, sumXY = 0.0;
    for (var i = 0; i < input.length; i++) {
      sumX += input[i];
      sumY += target[i];
      sumXX += input[i] * input[i];
      sumXY += input[i] * target[i];
    }
    final n = input.length.toDouble();
    final det = n * sumXX - sumX * sumX;
    if (!det.isFinite || det.abs() < 1e-9) {
      throw StateError(
        'المعايرة غير صالحة: حرّك الرأس بين أهداف مختلفة ثم أعد المحاولة.',
      );
    }
    final scale = (n * sumXY - sumX * sumY) / det;
    final bias = (sumXX * sumY - sumX * sumXY) / det;
    if (!scale.isFinite || !bias.isFinite) {
      throw StateError('تعذر حساب معاملات معايرة مستقرة.');
    }
    return (scale, bias);
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


enum GazeIntent { none, dwellActivated }

class GazeIntentEvent {
  const GazeIntentEvent({required this.intent, required this.x, required this.y});
  final GazeIntent intent;
  final double x;
  final double y;
}

class GazeDwellController {
  GazeDwellController({
    this.dwellDuration = const Duration(milliseconds: 850),
    this.activationRadius = 32,
    this.cooldown = const Duration(milliseconds: 900),
  });

  final Duration dwellDuration;
  final double activationRadius;
  final Duration cooldown;
  double? _x;
  double? _y;
  DateTime? _started;
  DateTime? _lastActivated;

  GazeIntentEvent update({
    required double x,
    required double y,
    required double confidence,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    if (confidence < 0.45) {
      reset();
      return GazeIntentEvent(intent: GazeIntent.none, x: x, y: y);
    }
    if (_x == null || _y == null ||
        math.sqrt(math.pow(x - _x!, 2) + math.pow(y - _y!, 2)) > activationRadius) {
      _x = x;
      _y = y;
      _started = t;
      return GazeIntentEvent(intent: GazeIntent.none, x: x, y: y);
    }
    final cooling = _lastActivated != null && t.difference(_lastActivated!) < cooldown;
    if (!cooling && t.difference(_started ?? t) >= dwellDuration) {
      _lastActivated = t;
      _started = t;
      return GazeIntentEvent(intent: GazeIntent.dwellActivated, x: x, y: y);
    }
    return GazeIntentEvent(intent: GazeIntent.none, x: x, y: y);
  }

  void reset() {
    _x = null;
    _y = null;
    _started = null;
  }
}
