import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../domain/entities/models.dart';

/// =============================================================================
/// TFLiteDatasource - مصدر بيانات TFLite
/// =============================================================================

class TFLiteDatasource {
  final Map<String, Interpreter> _interpreters = {};
  final Map<String, bool> _isLoaded = {};
  final Map<String, ModelInfo> _modelInfos = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // تحميل النموذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل نموذج
  Future<ModelInfo> loadModel(String modelPath, {String? key}) async {
    try {
      final interpreter = await Interpreter.fromAsset(
        modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      _interpreters[modelPath] = interpreter;
      _isLoaded[modelPath] = true;
      final info = ModelInfo(name: modelPath.split('/').last, path: modelPath, type: 'tflite', size: 0, isLoaded: true, lastUsed: DateTime.now());
      _modelInfos[modelPath] = info;
      return info;
    } catch (e) {
      _isLoaded[modelPath] = false;
    _modelInfos.remove(modelPath);
      throw StateError('فشل تحميل نموذج TFLite: $modelPath');
    }
  }

  /// إلغاء تحميل نموذج
  Future<void> unloadModel(String modelPath) async {
    _interpreters.remove(modelPath)?.close();
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
      try { await loadModel(modelPath); } catch (e) { return {'error': e.toString()}; }
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
      final outputArray = _reshape(List<double>.filled(outputShapeList.reduce((a, b) => a * b), 0.0), outputShapeList);

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
      'inputType': inputTensors.first.type.toString(),
      'outputType': outputTensors.first.type.toString(),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // النماذج المدمجة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تشغيل نموذج مدمج فعليًا من أصول التطبيق.
  /// لا توجد نتائج اصطناعية: يجب أن يكون النموذج موجودًا وقابلًا للتحميل.
  Future<Map<String, dynamic>> runBundledModel(
    String modelName,
    List<double> features,
  ) async {
    final result = await runInference(modelName, features);
    if (result.containsKey('error')) {
      return {
        'modelName': modelName,
        'loaded': false,
        'error': result['error'],
      };
    }
    return {
      'modelName': modelName,
      'loaded': true,
      ...result,
    };
  }

}

