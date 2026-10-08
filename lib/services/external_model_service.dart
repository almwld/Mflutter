import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/feature_extractor.dart';

/// Loads user-supplied TFLite models from the device filesystem.
///
/// The model directory is intentionally external to the Flutter asset bundle:
/// models discovered there must be opened with [Interpreter.fromFile].
class ExternalModelService {
  static const String _modelsPath =
      '/storage/emulated/0/Download/mudabbir_models/';
  static final ExternalModelService _instance =
      ExternalModelService._internal();

  factory ExternalModelService() => _instance;
  ExternalModelService._internal();

  final Map<String, Interpreter> _loadedModels = {};
  final FeatureExtractor _featureExtractor = FeatureExtractor();
  String? _selectedModel;
  String? get selectedModel => _selectedModel;

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
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  /// Loads a model from the same filesystem directory checked above.
  ///
  /// [Interpreter.fromAsset] is deliberately not used here because these are
  /// external files, not Flutter bundle assets.
  Future<String> importAndLoadModel(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) throw StateError('ملف النموذج غير موجود.');
    if (!source.path.toLowerCase().endsWith('.tflite')) throw StateError('هذا التطبيق يقبل حالياً نماذج TFLite (.tflite) للتحليل المحلي.');
    final dir = await getApplicationSupportDirectory();
    final models = Directory('${dir.path}/mudabbir_models');
    await models.create(recursive: true);
    final name = source.uri.pathSegments.last;
    final target = File('${models.path}/$name');
    await source.copy(target.path);
    final modelName = name.substring(0, name.length - '.tflite'.length);
    await loadModelFromPath(modelName, target.path);
    _selectedModel = modelName;
    return modelName;
  }

  Future<void> loadModel(String modelName) async {
    final file = File('$_modelsPath${modelName.trim()}.tflite');
    if (!await file.exists()) throw StateError('Model file not found: ${file.path}');
    await loadModelFromPath(modelName, file.path);
  }

  Future<void> loadModelFromPath(String modelName, String modelPath) async {
    final cleanName = modelName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Model name cannot be empty.');
    }

    final file = File(modelPath);
    if (!await file.exists()) {
      throw StateError('Model file not found: $modelPath');
    }

    final old = _loadedModels.remove(cleanName);
    old?.close();

    try {
      final interpreter = await Interpreter.fromFile(file);
      _loadedModels[cleanName] = interpreter;
    } catch (e) {
      throw StateError('Failed to load model $cleanName: $e');
    }
  }

  List<double> extractFeatures(String text) {
    return _featureExtractor.extract(text);
  }

  Map<String, dynamic> runInference(
    String modelName,
    List<double> features,
  ) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) {
      return {'error': 'Model not loaded'};
    }

    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputShape = interpreter.getOutputTensor(0).shape;
      if (inputShape.length != 2 || inputShape[0] != 1) {
        return {
          'error':
              'Unsupported model input shape: ${inputShape.join('x')}',
        };
      }
      if (inputShape[1] != features.length) {
        return {
          'error':
              'Feature count ${features.length} does not match model input ${inputShape[1]}',
        };
      }

      final input = [features];
      final output = _allocateOutput(outputShape);
      interpreter.run(input, output);

      final flat = _flattenNumbers(output);
      return {
        'prediction': flat.isNotEmpty ? flat.first : null,
        'confidence': _calculateConfidence(flat),
        'model': modelName,
        'inputShape': inputShape,
        'outputShape': outputShape,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Map<String, dynamic> getModelInfo(String modelName) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) return {'loaded': false};

    return {
      'loaded': true,
      'name': modelName,
      'inputShape': interpreter.getInputTensors(),
      'outputShape': interpreter.getOutputTensors(),
    };
  }

  double _calculateConfidence(List<double> outputs) {
    if (outputs.isEmpty) return 0.0;
    final maxVal = outputs.reduce((a, b) => a > b ? a : b);
    return maxVal.clamp(0.0, 1.0);
  }

  Future<Map<String, dynamic>> runEnergyAnalysis(String text) async {
    final model = _selectedModel;
    if (model == null) return {'error': 'لم يتم اختيار نموذج محلي TFLite.'};
    return runInference(model, extractFeatures(text));
  }

  Future<Map<String, dynamic>> runPatternDiscovery(String text) async {
    final model = _selectedModel;
    if (model == null) return {'error': 'لم يتم اختيار نموذج محلي TFLite.'};
    return runInference(model, extractFeatures(text));
  }

  Future<Map<String, dynamic>> runTopicClassification(String text) async {
    return runInference('topic_classification', extractFeatures(text));
  }

  Future<void> unloadModel(String modelName) async {
    final interpreter = _loadedModels.remove(modelName);
    interpreter?.close();
  }

  Future<void> unloadAllModels() async {
    for (final interpreter in _loadedModels.values) {
      interpreter.close();
    }
    _loadedModels.clear();
  }

  List<String> get loadedModels => _loadedModels.keys.toList();

  dynamic _allocateOutput(List<int> shape) {
    if (shape.isEmpty) return <double>[];
    dynamic build(int depth) {
      final size = shape[depth];
      if (depth == shape.length - 1) {
        return List<double>.filled(size, 0.0);
      }
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