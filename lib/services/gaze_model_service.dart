import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Loads and validates the on-device gaze model supplied in assets.
///
/// The model file is intentionally not bundled by this source change.
/// Put the real model at:
///   assets/models/gaze_fp16.tflite
///
/// The runtime inspects tensors at startup instead of assuming a fixed
/// graph, which lets us fail clearly when a different model is supplied.
class GazeAngles {
  const GazeAngles({required this.yaw, required this.pitch});
  final double yaw;
  final double pitch;
}

class GazeModelService {
  GazeModelService._();
  static final instance = GazeModelService._();

  static const assetPath = 'assets/models/gaze_fp16.tflite';

  Interpreter? _interpreter;
  bool _loading = false;

  bool get isLoaded => _interpreter != null;
  List<int> get inputShape => _interpreter?.getInputTensor(0).shape ?? const [];
  String get inputType => _interpreter?.getInputTensor(0).type.toString() ?? 'unknown';

  bool get hasExpectedL2csContract =>
      inputShape.length == 4 && inputShape[0] == 1 && inputShape[1] == 3 &&
      inputShape[2] == 448 && inputShape[3] == 448 &&
      outputShapes.length >= 2 && outputShapes[0].reduce((a, b) => a * b) == 90 &&
      outputShapes[1].reduce((a, b) => a * b) == 90;

  List<List<int>> get outputShapes =>
      _interpreter?.getOutputTensors().map((t) => List<int>.from(t.shape)).toList() ??
      const [];

  Future<void> load() async {
    if (_interpreter != null || _loading) return;
    _loading = true;
    try {
      final options = InterpreterOptions()..threads = 2;
      final interpreter = await Interpreter.fromAsset(assetPath, options: options);
      interpreter.allocateTensors();

      if (interpreter.getInputTensors().isEmpty ||
          interpreter.getOutputTensors().isEmpty) {
        interpreter.close();
        throw StateError('نموذج النظر لا يحتوي على مدخلات أو مخرجات صالحة.');
      }

      _interpreter = interpreter;
    } on FlutterError {
      rethrow;
    } finally {
      _loading = false;
    }
  }

  GazeAngles inferRgb({
    required List<int> rgb,
    required int width,
    required int height,
    required int left,
    required int top,
    required int right,
    required int bottom,
  }) {
    if (rgb.length != width * height * 3) {
      throw ArgumentError('RGB frame size does not match dimensions.');
    }
    final crop = _squareCrop(rgb, width, height, left, top, right, bottom);
    final input = List.generate(
      3,
      (channel) => List.generate(
        448,
        (y) => List.generate(448, (x) {
          final offset = (y * 448 + x) * 3 + channel;
          final value = crop[offset] / 255.0;
          const mean = [0.485, 0.456, 0.406];
          const std = [0.229, 0.224, 0.225];
          return (value - mean[channel]) / std[channel];
        }),
      ),
    );
    final outputs = run(input);
    if (!hasExpectedL2csContract) throw StateError('بنية نموذج L2CS غير متوافقة مع العقد 1x3x448x448 → 90/90.');
    if (outputs.length < 2) throw StateError('L2CS يجب أن يعيد رأسي yaw و pitch.');
    final yaw = _flatten(outputs[0]).map((e) => e.toDouble()).toList();
    final pitch = _flatten(outputs[1]).map((e) => e.toDouble()).toList();
    if (yaw.length != 90 || pitch.length != 90) {
      throw StateError('مخرجات L2CS غير متوافقة: yaw=${yaw.length} pitch=${pitch.length}.');
    }
    return GazeAngles(
      yaw: decodeAngle(yaw, bins: 90),
      pitch: decodeAngle(pitch, bins: 90),
    );
  }

  List<int> _squareCrop(List<int> rgb, int width, int height, int left, int top, int right, int bottom) {
    final l = left.clamp(0, width - 1);
    final t = top.clamp(0, height - 1);
    final r = right.clamp(l + 1, width);
    final b = bottom.clamp(t + 1, height);
    final size = math.max(r - l, b - t).clamp(1, math.min(width, height));
    final cx = (l + r) ~/ 2;
    final cy = (t + b) ~/ 2;
    final x0 = (cx - size ~/ 2).clamp(0, width - size);
    final y0 = (cy - size ~/ 2).clamp(0, height - size);
    final out = List<int>.filled(448 * 448 * 3, 0);
    for (var y = 0; y < 448; y++) {
      final sy = y0 + ((y * size) ~/ 448).clamp(0, size - 1);
      for (var x = 0; x < 448; x++) {
        final sx = x0 + ((x * size) ~/ 448).clamp(0, size - 1);
        final src = (sy * width + sx) * 3;
        final dst = (y * 448 + x) * 3;
        out[dst] = rgb[src];
        out[dst + 1] = rgb[src + 1];
        out[dst + 2] = rgb[src + 2];
      }
    }
    return out;
  }

  List<num> _flatten(Object value) {
    if (value is num) return [value];
    if (value is List) return value.expand<num>((e) => _flatten(e)).toList();
    throw StateError('مخرج Tensor غير قابل للفك.');
  }

  /// Runs a single-input floating-point model.
  ///
  /// [input] must already be shaped exactly like the model input tensor.
  /// This method deliberately does not guess preprocessing or output semantics.
  List<Object> run(Object input) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('نموذج النظر غير محمّل.');
    }

    final outputs = <int, Object>{};
    final tensors = interpreter.getOutputTensors();
    for (var i = 0; i < tensors.length; i++) {
      outputs[i] = _zeroBuffer(tensors[i].shape, tensors[i].type.toString());
    }

    interpreter.runForMultipleInputs([input], outputs);
    return List<Object>.generate(tensors.length, (i) => outputs[i]!);
  }

  /// Standard L2CS decoder for two classification heads (yaw/pitch).
  ///
  /// It is only used when both heads have the same number of bins and at
  /// least two bins. The caller can provide the expected bin count explicitly
  /// after validating the supplied model.
  static double decodeAngle(
    List<double> logits, {
    required int bins,
    double minAngle = -180.0,
    double maxAngle = 180.0,
  }) {
    if (logits.length != bins || bins < 2) {
      throw ArgumentError('عدد bins لا يطابق مخرجات نموذج L2CS.');
    }

    final looksLikeProbabilities = logits.every((v) => v >= 0 && v <= 1) &&
        (logits.fold<double>(0, (sum, v) => sum + v) - 1.0).abs() < 0.05;
    final probabilities = looksLikeProbabilities
        ? logits
        : _softmax(logits);
    final step = (maxAngle - minAngle) / bins;
    var weighted = 0.0;
    for (var i = 0; i < probabilities.length; i++) {
      weighted += probabilities[i] * (minAngle + i * step);
    }
    return weighted;
  }

  static List<double> _softmax(List<double> values) {
    final maxValue = values.reduce(math.max);
    final exps = values.map((v) => math.exp(v - maxValue)).toList();
    final sum = exps.fold<double>(0, (a, b) => a + b);
    return sum == 0 ? List<double>.filled(values.length, 1 / values.length) : exps.map((v) => v / sum).toList();
  }

  Object _zeroBuffer(List<int> shape, String type) {
    final size = shape.fold<int>(1, (a, b) => a * b);
    if (type.contains('float32')) {
      return List<double>.filled(size, 0).reshape(shape);
    }
    if (type.contains('uint8')) {
      return List<int>.filled(size, 0).reshape(shape);
    }
    if (type.contains('int8')) {
      return List<int>.filled(size, 0).reshape(shape);
    }
    throw UnsupportedError('نوع Tensor غير مدعوم: $type');
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
