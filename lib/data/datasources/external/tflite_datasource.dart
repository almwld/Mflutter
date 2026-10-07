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
      'shape': _inferShape(output),
    };
  }

  /// استنتاج أبعاد بنية خرج TFLite الفعلية دون الاعتماد على واجهة غير موجودة.
  /// TFLite يعيد مصفوفات Dart متداخلة بعد تشغيل interpreter.run.
  List<int> _inferShape(dynamic value) {
    if (value is! List) return const <int>[];
    if (value.isEmpty) return <int>[0];
    return <int>[value.length, ..._inferShape(value.first)];
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

  Future<InferenceResult> predict(String input, Map<String, dynamic> params) async {
    final modelPath = (params['modelPath'] ?? params['model'] ?? '').toString();
    if (modelPath.isEmpty) throw ArgumentError('modelPath مطلوب.');
    final started = DateTime.now();
    final values = params['input'] is List
        ? List<double>.from((params['input'] as List).map((e) => (e as num).toDouble()))
        : input.codeUnits.map((e) => e.toDouble()).toList();
    final result = await runInference(modelPath, values);
    return InferenceResult(
      modelName: modelPath,
      output: result,
      confidence: 0.0,
      processingTime: DateTime.now().difference(started),
      error: result['error']?.toString(),
    );
  }

  Future<List<ModelInfo>> getAvailableModels() async => List.unmodifiable(_modelInfos.values);

  List<dynamic> _reshape(List<double> values, List<int> shape) {
    if (shape.isEmpty) return values;
    final total = shape.fold<int>(1, (a, b) => a * b);
    if (values.length != total) throw ArgumentError('عدد عناصر المصفوفة لا يطابق shape.');
    List<dynamic> build(int dimension, int offset) {
      if (dimension == shape.length - 1) {
        return List<double>.from(values.sublist(offset, offset + shape[dimension]));
      }
      final stride = shape.sublist(dimension + 1).fold<int>(1, (a, b) => a * b);
      return List.generate(shape[dimension], (i) => build(dimension + 1, offset + i * stride));
    }
    return build(0, 0);
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

