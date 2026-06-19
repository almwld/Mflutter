import 'package:tflite_flutter/tflite_flutter.dart';

/// =============================================================================
/// TFLiteDatasource - مصدر بيانات TFLite
/// =============================================================================

class TFLiteDatasource {
  final Map<String, Interpreter> _interpreters = {};
  final Map<String, bool> _isLoaded = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // تحميل النموذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل نموذج
  Future<bool> loadModel(String modelPath, {String? key}) async {
    try {
      final interpreter = await Interpreter.fromAsset(
        modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      _interpreters[modelPath] = interpreter;
      _isLoaded[modelPath] = true;
      return true;
    } catch (e) {
      _isLoaded[modelPath] = false;
      return false;
    }
  }

  /// إلغاء تحميل نموذج
  Future<void> unloadModel(String modelPath) async {
    _interpreters.remove(modelPath);
    _isLoaded[modelPath] = false;
  }

  /// التحقق من تحميل النموذج
  bool isModelLoaded(String modelPath) {
    return _isLoaded[modelPath] ?? false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الاستدلال
  // ═══════════════════════════════════════════════════════════════════════════

  /// تشغيل الاستدلال
  Future<Map<String, dynamic>> runInference(
    String modelPath,
    List<double> input, {
    List<int>? inputShape,
    List<int>? outputShape,
  }) async {
    if (!isModelLoaded(modelPath)) {
      final loaded = await loadModel(modelPath);
      if (!loaded) {
        return {'error': 'فشل تحميل النموذج'};
      }
    }

    final interpreter = _interpreters[modelPath];
    if (interpreter == null) {
      return {'error': 'النموذج غير موجود'};
    }

    try {
      // تحضير المدخلات
      final inputTensor = interpreter.getInputTensors().first;
      final outputTensor = interpreter.getOutputTensors().first;

      final inputShapeList = inputShape ?? inputTensor.shape;
      final outputShapeList = outputShape ?? outputTensor.shape;

      // إنشاء مصفوفات المدخلات والمخرجات
      final inputArray = _createInputArray(input, inputShapeList);
      final outputArray = List.filled(
        outputShapeList.reduce((a, b) => a * b),
        0.0,
      ).reshape(outputShapeList);

      // تشغيل الاستدلال
      interpreter.run(inputArray, outputArray);

      // تحويل النتيجة
      return _processOutput(outputArray);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  List<dynamic> _createInputArray(List<double> input, List<int> shape) {
    if (shape.length == 2) {
      return [input];
    }
    return input;
  }

  Map<String, dynamic> _processOutput(List<dynamic> output) {
    return {
      'output': output,
      'shape': output.shape,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات النموذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب معلومات النموذج
  Future<Map<String, dynamic>> getModelInfo(String modelPath) async {
    if (!isModelLoaded(modelPath)) {
      return {'error': 'النموذج غير مُحمَّل'};
    }

    final interpreter = _interpreters[modelPath];
    if (interpreter == null) {
      return {'error': 'النموذج غير موجود'};
    }

    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();

    return {
      'inputCount': inputTensors.length,
      'outputCount': outputTensors.length,
      'inputShape': inputTensors.first.shape,
      'outputShape': outputTensors.first.shape,
      'inputType': inputTensors.first.dataType.toString(),
      'outputType': outputTensors.first.dataType.toString(),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // النماذج المدمجة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تشغيل نموذج مدمج
  Future<Map<String, dynamic>> runBundledModel(
    String modelName,
    List<double> features,
  ) async {
    // محاكاة تشغيل نموذج مدمج
    await Future.delayed(const Duration(milliseconds: 50));

    return {
      'modelName': modelName,
      'output': features.take(10).toList(),
      'confidence': 0.85,
    };
  }
}

/// =============================================================================
/// Extensiones para List<dynamic>
///
/// إضافة طريقة reshape لـ List<dynamic>
/// =============================================================================

extension ListExtension on List<dynamic> {
  List<dynamic> reshape(List<int> shape) {
    if (shape.length == 1) return this;
    // محاكاة إعادة التشكيل
    return this;
  }
}