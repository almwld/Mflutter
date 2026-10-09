import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/feature_extractor.dart';

/// Runs real TFLite inference on a user-supplied model.
///
/// Contract for the Mudabbir text classifier:
/// - input tensor: float tensor [1, 4096]
/// - output tensor: float tensor [1, N], N >= 2
/// - input features must be produced by this app's FeatureExtractor.
///
/// A model that merely opens but fails a zero-input smoke test is not accepted.
/// This service does not train weights and does not infer semantic labels from
/// arbitrary output tensors.
class ExternalModelService {
  static const String _modelsPath =
      '/storage/emulated/0/Download/mudabbir_models/';
  static const String _selectedPathKey = 'mudabbir_verified_model_path';
  static final ExternalModelService _instance =
      ExternalModelService._internal();

  factory ExternalModelService() => _instance;
  ExternalModelService._internal();

  final Map<String, Interpreter> _loadedModels = {};
  final FeatureExtractor _featureExtractor = FeatureExtractor();
  String? _selectedModel;
  String? _selectedModelPath;

  String? get selectedModel => _selectedModel;
  String? get selectedModelPath => _selectedModelPath;
  bool get hasSelectedModel =>
      _selectedModel != null && _loadedModels.containsKey(_selectedModel);

  Future<bool> checkModelsExist() async {
    try {
      final directory = Directory(_modelsPath);
      if (!await directory.exists()) return false;
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.tflite')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadAllModels() async {
    try {
      final directory = Directory(_modelsPath);
      if (!await directory.exists()) return;
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.tflite')) {
          final fileName = entity.uri.pathSegments.last;
          final modelName =
              fileName.substring(0, fileName.length - '.tflite'.length);
          await loadModel(modelName);
        }
      }
    } catch (_) {
      // Discovery is best-effort; the UI reports that no compatible model loaded.
    }
  }

  /// Restore the last imported model, verifying the file and tensor contract
  /// again on every app launch rather than trusting stale preferences.
  Future<bool> restoreSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_selectedPathKey);
    if (path == null || path.isEmpty) return false;
    final file = File(path);
    if (!await file.exists()) {
      await prefs.remove(_selectedPathKey);
      return false;
    }
    final name = file.uri.pathSegments.last.replaceFirst(RegExp(r'\.tflite$', caseSensitive: false), '');
    try {
      await loadModelFromPath(name, path);
      _validateMudabbirContract(_loadedModels[name]!);
      _runSmokeTest(_loadedModels[name]!);
      _selectedModel = name;
      _selectedModelPath = path;
      return true;
    } catch (_) {
      await unloadModel(name);
      await prefs.remove(_selectedPathKey);
      _selectedModel = null;
      _selectedModelPath = null;
      return false;
    }
  }

  /// Copy, load and verify an imported model. Returns only after a real native
  /// interpreter successfully executes inference with the required input shape.
  Future<String> importAndLoadModel(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) throw StateError('ملف النموذج غير موجود.');
    if (!source.path.toLowerCase().endsWith('.tflite')) {
      throw StateError('الصيغة المدعومة حالياً هي TFLite فقط (.tflite).');
    }
    if (await source.length() < 8) {
      throw StateError('ملف النموذج فارغ أو أصغر من أن يكون نموذج TFLite صالحاً.');
    }

    final dir = await getApplicationSupportDirectory();
    final models = Directory('${dir.path}/mudabbir_models');
    await models.create(recursive: true);
    final name = source.uri.pathSegments.last;
    final target = File('${models.path}/$name');
    if (source.absolute.path != target.absolute.path) {
      await source.copy(target.path);
    }
    final modelName = name.replaceFirst(RegExp(r'\.tflite$', caseSensitive: false), '');

    try {
      await loadModelFromPath(modelName, target.path);
      final interpreter = _loadedModels[modelName]!;
      _validateMudabbirContract(interpreter);
      _runSmokeTest(interpreter);
      _selectedModel = modelName;
      _selectedModelPath = target.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedPathKey, target.path);
      return modelName;
    } catch (e) {
      await unloadModel(modelName);
      rethrow;
    }
  }

  void _validateMudabbirContract(Interpreter interpreter) {
    final input = interpreter.getInputTensor(0);
    final output = interpreter.getOutputTensor(0);
    final inputShape = input.shape;
    final outputShape = output.shape;

    if (inputShape.length != 2 ||
        inputShape[0] != 1 ||
        inputShape[1] != FeatureExtractor.embeddingSize) {
      throw StateError(
        'النموذج غير متوافق: المدخل المطلوب [1, ${FeatureExtractor.embeddingSize}] '
        'لكن الموجود [${inputShape.join(', ')}].',
      );
    }
    if (outputShape.length != 2 || outputShape[0] != 1 || outputShape[1] < 2) {
      throw StateError(
        'النموذج غير متوافق: المخرج المطلوب [1, N] حيث N >= 2، '
        'لكن الموجود [${outputShape.join(', ')}].',
      );
    }
    if (input.type != TfLiteType.float32 || output.type != TfLiteType.float32) {
      throw StateError(
        'النموذج غير متوافق: يجب أن يكون مدخل ومخرج التصنيف من نوع float32.',
      );
    }
  }

  void _runSmokeTest(Interpreter interpreter) {
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    final input = List<double>.filled(inputShape[1], 0.0);
    final output = _allocateOutput(outputShape);
    interpreter.run([input], output);
    final values = _flattenNumbers(output);
    if (values.length != outputShape[1] ||
        values.any((value) => !value.isFinite)) {
      throw StateError('فشل اختبار الاستدلال الأولي للنموذج؛ المخرجات غير صالحة.');
    }
  }

  Future<void> loadModel(String modelName) async {
    final file = File('$_modelsPath${modelName.trim()}.tflite');
    if (!await file.exists()) {
      throw StateError('ملف النموذج غير موجود: ${file.path}');
    }
    await loadModelFromPath(modelName, file.path);
  }

  Future<void> loadModelFromPath(String modelName, String modelPath) async {
    final cleanName = modelName.trim();
    if (cleanName.isEmpty) throw ArgumentError('اسم النموذج لا يمكن أن يكون فارغاً.');
    final file = File(modelPath);
    if (!await file.exists()) throw StateError('ملف النموذج غير موجود: $modelPath');

    final old = _loadedModels.remove(cleanName);
    old?.close();
    try {
      _loadedModels[cleanName] = await Interpreter.fromFile(file);
    } catch (e) {
      throw StateError('تعذر تحميل نموذج $cleanName: $e');
    }
  }

  List<double> extractFeatures(String text) => _featureExtractor.extract(text);

  Map<String, dynamic> runInference(String modelName, List<double> features) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) return {'error': 'النموذج غير محمّل فعلياً.'};

    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;
      if (inputShape.length != 2 ||
          inputShape[0] != 1 ||
          inputShape[1] != features.length) {
        return {'error': 'أبعاد المدخل لا تتوافق مع خصائص النص المستخرجة.'};
      }
      if (outputShape.length != 2 || outputShape[0] != 1 || outputShape[1] < 2) {
        return {'error': 'أبعاد مخرج النموذج غير مدعومة.'};
      }

      final output = _allocateOutput(outputShape);
      interpreter.run([features], output);
      final values = _flattenNumbers(output);
      if (values.length != outputShape[1] ||
          values.any((value) => !value.isFinite)) {
        return {'error': 'أنتج النموذج مخرجات غير صالحة.'};
      }

      final maxValue = values.reduce((a, b) => a > b ? a : b);
      final sum = values.fold<double>(0, (a, b) => a + b);
      final isProbabilityVector = values.every((v) => v >= 0 && v <= 1) &&
          (sum - 1).abs() < 0.02;
      return {
        'model': modelName,
        'loaded': true,
        'inferenceExecuted': true,
        'predictionIndex': values.indexOf(maxValue),
        'outputs': values,
        'confidence': isProbabilityVector ? maxValue : null,
        'outputIsProbabilityDistribution': isProbabilityVector,
        'inputShape': inputShape,
        'outputShape': outputShape,
      };
    } catch (e) {
      return {'error': 'فشل الاستدلال الفعلي: $e'};
    }
  }

  Map<String, dynamic> getModelInfo(String modelName) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) return {'loaded': false};
    return {
      'loaded': true,
      'name': modelName,
      'path': modelName == _selectedModel ? _selectedModelPath : null,
      'inputShape': interpreter.getInputTensor(0).shape,
      'outputShape': interpreter.getOutputTensor(0).shape,
      'inputType': interpreter.getInputTensor(0).type.toString(),
      'outputType': interpreter.getOutputTensor(0).type.toString(),
    };
  }

  Future<Map<String, dynamic>> runEnergyAnalysis(String text) async {
    final model = _selectedModel;
    if (model == null) return {'error': 'لم يتم تحميل نموذج محلي متوافق.'};
    return runInference(model, extractFeatures(text));
  }

  Future<Map<String, dynamic>> runPatternDiscovery(String text) async =>
      runEnergyAnalysis(text);

  Future<Map<String, dynamic>> runTopicClassification(String text) async =>
      runEnergyAnalysis(text);

  Future<void> unloadModel(String modelName) async {
    _loadedModels.remove(modelName)?.close();
    if (_selectedModel == modelName) {
      _selectedModel = null;
      _selectedModelPath = null;
    }
  }

  Future<void> unloadAllModels() async {
    for (final interpreter in _loadedModels.values) {
      interpreter.close();
    }
    _loadedModels.clear();
    _selectedModel = null;
    _selectedModelPath = null;
  }

  List<String> get loadedModels => _loadedModels.keys.toList();

  dynamic _allocateOutput(List<int> shape) {
    if (shape.isEmpty) return <double>[];
    dynamic build(int depth) {
      final size = shape[depth];
      if (depth == shape.length - 1) return List<double>.filled(size, 0.0);
      return List<dynamic>.generate(size, (_) => build(depth + 1));
    }
    return build(0);
  }

  List<double> _flattenNumbers(dynamic value) {
    if (value is num) return [value.toDouble()];
    if (value is Iterable) {
      return value.expand<double>(_flattenNumbers).toList();
    }
    return const [];
  }
}
