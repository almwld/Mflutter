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
class GazeModelService {
  GazeModelService._();
  static final instance = GazeModelService._();

  static const assetPath = 'assets/models/gaze_fp16.tflite';

  Interpreter? _interpreter;
  bool _loading = false;

  bool get isLoaded => _interpreter != null;
  List<int> get inputShape => _interpreter?.getInputTensor(0).shape ?? const [];
  String get inputType => _interpreter?.getInputTensor(0).type.toString() ?? 'unknown';

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
    double minAngle = -99.0,
    double maxAngle = 99.0,
  }) {
    if (logits.length != bins || bins < 2) {
      throw ArgumentError('عدد bins لا يطابق مخرجات نموذج L2CS.');
    }

    final maxLogit = logits.reduce(math.max);
    var denominator = 0.0;
    var weighted = 0.0;
    final step = (maxAngle - minAngle) / bins;

    for (var i = 0; i < logits.length; i++) {
      final probability = math.exp(logits[i] - maxLogit);
      denominator += probability;
      weighted += probability * (minAngle + (i + 0.5) * step);
    }
    return denominator == 0 ? 0 : weighted / denominator;
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
