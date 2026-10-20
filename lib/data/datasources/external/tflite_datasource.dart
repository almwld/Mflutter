import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../domain/entities/models.dart';

/// مصدر بيانات TFLite مع تشكيل مدخلات ومخرجات مطابق لأبعاد الـ tensor.
class TFLiteDatasource {
  final Map<String, Interpreter> _interpreters = {};
  final Map<String, bool> _isLoaded = {};
  final Map<String, ModelInfo> _modelInfos = {};

  Future<ModelInfo> loadModel(String modelPath, {String? key}) async {
    try {
      // لا نحمّل النموذج نفسه مرتين ونترك نسخة Interpreter قديمة مفتوحة.
      final existing = _interpreters[modelPath];
      if (existing != null && (_isLoaded[modelPath] ?? false)) {
        return _modelInfos[modelPath]!;
      }
      existing?.close();
      final interpreter = await Interpreter.fromAsset(
        modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      _interpreters[modelPath] = interpreter;
      _isLoaded[modelPath] = true;
      final info = ModelInfo(
        name: modelPath.split('/').last,
        path: modelPath,
        type: 'tflite',
        size: 0,
        isLoaded: true,
        lastUsed: DateTime.now(),
      );
      _modelInfos[modelPath] = info;
      return info;
    } catch (e) {
      _isLoaded[modelPath] = false;
      _modelInfos.remove(modelPath);
      throw StateError('فشل تحميل نموذج TFLite ($modelPath): $e');
    }
  }

  Future<void> unloadModel(String modelPath) async {
    _interpreters.remove(modelPath)?.close();
    _isLoaded[modelPath] = false;
    _modelInfos.remove(modelPath);
  }

  bool isModelLoaded(String modelPath) => _isLoaded[modelPath] ?? false;

  Future<Map<String, dynamic>> runInference(
    String modelPath,
    List<double> input, {
    List<int>? inputShape,
    List<int>? outputShape,
  }) async {
    if (!isModelLoaded(modelPath)) {
      try {
        await loadModel(modelPath);
      } catch (e) {
        return {'error': e.toString()};
      }
    }

    final interpreter = _interpreters[modelPath];
    if (interpreter == null) return {'error': 'النموذج غير موجود'};

    try {
      final inputTensors = interpreter.getInputTensors();
      final outputTensors = interpreter.getOutputTensors();
      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        return {'error': 'النموذج لا يحتوي على مدخلات أو مخرجات صالحة'};
      }

      final actualInputShape = inputTensors.first.shape;
      final actualOutputShape = outputTensors.first.shape;
      final requestedInputShape = inputShape ?? actualInputShape;
      final requestedOutputShape = outputShape ?? actualOutputShape;

      // لا تسمح لأبعاد يمررها المستدعي بمخالفة بنية النموذج الفعلية.
      if (!_sameShape(requestedInputShape, actualInputShape)) {
        return {
          'error': 'أبعاد الإدخال لا تطابق النموذج: المتوقع $actualInputShape، والممرر $requestedInputShape',
        };
      }
      if (!_sameShape(requestedOutputShape, actualOutputShape)) {
        return {
          'error': 'أبعاد الإخراج لا تطابق النموذج: المتوقع $actualOutputShape، والممرر $requestedOutputShape',
        };
      }

      final expectedInputCount = _elementCount(actualInputShape);
      if (input.length != expectedInputCount) {
        return {
          'error': 'عدد عناصر الإدخال غير صحيح: المتوقع $expectedInputCount، والموجود ${input.length}',
          'expectedInputShape': actualInputShape,
        };
      }

      final inputArray = _reshape(input, actualInputShape);
      final outputArray = _reshape(
        List<double>.filled(_elementCount(actualOutputShape), 0.0),
        actualOutputShape,
      );

      interpreter.run(inputArray, outputArray);
      return {
        'output': outputArray,
        'shape': _inferShape(outputArray),
      };
    } catch (e) {
      return {'error': 'فشل استدلال TFLite: $e'};
    }
  }

  bool _sameShape(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var i = 0; i < first.length; i++) {
      if (first[i] != second[i]) return false;
    }
    return true;
  }

  int _elementCount(List<int> shape) {
    if (shape.isEmpty || shape.any((dimension) => dimension <= 0)) {
      throw ArgumentError('أبعاد tensor غير صالحة: $shape');
    }
    return shape.fold<int>(1, (count, dimension) => count * dimension);
  }

  List<int> _inferShape(dynamic value) {
    if (value is! List) return const <int>[];
    if (value.isEmpty) return <int>[0];
    return <int>[value.length, ..._inferShape(value.first)];
  }

  Future<Map<String, dynamic>> getModelInfo(String modelPath) async {
    if (!isModelLoaded(modelPath)) return {'error': 'النموذج غير مُحمَّل'};
    final interpreter = _interpreters[modelPath];
    if (interpreter == null) return {'error': 'النموذج غير موجود'};

    final inputTensors = interpreter.getInputTensors();
    final outputTensors = interpreter.getOutputTensors();
    if (inputTensors.isEmpty || outputTensors.isEmpty) {
      return {'error': 'النموذج لا يحتوي على مدخلات أو مخرجات صالحة'};
    }
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
    final rawInput = params['input'];
    final values = rawInput is List
        ? rawInput.map((value) {
            if (value is! num) {
              throw ArgumentError('كل عناصر input يجب أن تكون أرقامًا.');
            }
            return value.toDouble();
          }).toList()
        : input.codeUnits.map((value) => value.toDouble()).toList();
    final result = await runInference(modelPath, values);
    return InferenceResult(
      modelName: modelPath,
      output: result,
      confidence: 0.0,
      processingTime: DateTime.now().difference(started),
      error: result['error']?.toString(),
    );
  }

  Future<List<ModelInfo>> getAvailableModels() async =>
      List.unmodifiable(_modelInfos.values);

  /// يبني قائمة متداخلة لأي رتبة tensor (مثل [1,N] أو [1,H,W,C]).
  List<dynamic> _reshape(List<double> values, List<int> shape) {
    final total = _elementCount(shape);
    if (values.length != total) {
      throw ArgumentError(
        'عدد عناصر المصفوفة (${values.length}) لا يطابق shape $shape (المتوقع $total).',
      );
    }

    List<dynamic> build(int dimension, int offset) {
      if (dimension == shape.length - 1) {
        return List<double>.from(
          values.sublist(offset, offset + shape[dimension]),
        );
      }
      final stride = shape
          .sublist(dimension + 1)
          .fold<int>(1, (a, b) => a * b);
      return List.generate(
        shape[dimension],
        (index) => build(dimension + 1, offset + index * stride),
      );
    }

    return build(0, 0);
  }

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
    return {'modelName': modelName, 'loaded': true, ...result};
  }
}
