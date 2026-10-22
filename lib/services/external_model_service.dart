import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/feature_extractor.dart';

/// Loads user-imported TFLite models from the app-private support directory.
///
/// Models are copied into app-private storage so they remain accessible after
/// Android process restarts and do not depend on broad external-storage access.
class ExternalModelService {
  static const String _modelsDirectoryName = 'mudabbir_models';
  static const String _selectedModelKey = 'mudabbir.selected_tflite_model';

  static final ExternalModelService _instance =
      ExternalModelService._internal();

  factory ExternalModelService() => _instance;
  ExternalModelService._internal();

  final Map<String, Interpreter> _loadedModels = {};
  final FeatureExtractor _featureExtractor = FeatureExtractor();

  String? _selectedModel;
  String? get selectedModel => _selectedModel;

  Future<Directory> _modelsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/$_modelsDirectoryName');
    await directory.create(recursive: true);
    return directory;
  }

  Future<bool> checkModelsExist() async {
    try {
      final directory = await _modelsDirectory();
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.tflite')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Loads models from private storage and restores the user's selected model.
  Future<void> loadAllModels() async {
    try {
      final directory = await _modelsDirectory();
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File ||
            !entity.path.toLowerCase().endsWith('.tflite')) {
          continue;
        }

        final fileName = entity.uri.pathSegments.last;
        final modelName =
            fileName.substring(0, fileName.length - '.tflite'.length);
        await loadModelFromPath(modelName, entity.path);
      }

      final preferences = await SharedPreferences.getInstance();
      final savedName = preferences.getString(_selectedModelKey);
      if (savedName != null && _loadedModels.containsKey(savedName)) {
        _selectedModel = savedName;
      } else if (savedName != null) {
        await preferences.remove(_selectedModelKey);
        _selectedModel = null;
      }
    } catch (error) {
      throw StateError('تعذر تحميل النماذج المحلية: $error');
    }
  }

  /// Imports a TFLite file into private app storage and loads it.
  Future<String> importAndLoadModel(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('ملف النموذج غير موجود.');
    }
    if (!source.path.toLowerCase().endsWith('.tflite')) {
      throw StateError(
        'هذا التطبيق يقبل حالياً نماذج TFLite (.tflite) للتحليل المحلي.',
      );
    }

    final directory = await _modelsDirectory();
    final name = source.uri.pathSegments.last;
    final target = File('${directory.path}/$name');
    if (source.absolute.path != target.absolute.path) {
      await source.copy(target.path);
    }

    final modelName = name.substring(0, name.length - '.tflite'.length);
    await loadModelFromPath(modelName, target.path);
    _selectedModel = modelName;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedModelKey, modelName);
    return modelName;
  }

  Future<void> loadModel(String modelName) async {
    final cleanName = modelName.trim();
    if (cleanName.isEmpty ||
        cleanName.contains('/') ||
        cleanName.contains('\\') ||
        cleanName == '.' ||
        cleanName == '..') {
      throw ArgumentError('Invalid model name.');
    }
    final directory = await _modelsDirectory();
    final file = File('${directory.path}/$cleanName.tflite');
    if (!await file.exists()) {
      throw StateError('Model file not found: ${file.path}');
    }
    await loadModelFromPath(cleanName, file.path);
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
    } catch (error) {
      throw StateError('Failed to load model $cleanName: $error');
    }
  }

  List<double> extractFeatures(String text) => _featureExtractor.extract(text);

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
          'error': 'Unsupported model input shape: ${inputShape.join('x')}',
        };
      }
      if (inputShape[1] != features.length) {
        return {
          'error':
              'Feature count ${features.length} does not match model input ${inputShape[1]}',
        };
      }

      final output = _allocateOutput(outputShape);
      interpreter.run([features], output);
      final flat = _flattenNumbers(output);
      return {
        // Preserve the raw tensor. A generic TFLite model's first output is
        // not automatically an energy score, probability, diagnosis, or label.
        'prediction': flat.isNotEmpty ? flat.first : null,
        'raw_outputs': flat,
        'model': modelName,
        'inputShape': inputShape,
        'outputShape': outputShape,
        'interpretation':
            'مخرجات رقمية خام؛ لا تُفسّر دلاليًا ما لم تتوفر بطاقة تعريف موثقة للنموذج.',
      };
    } catch (error) {
      return {'error': error.toString()};
    }
  }

  Map<String, dynamic> getModelInfo(String modelName) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) return {'loaded': false};

    return {
      'loaded': true,
      'name': modelName,
      'inputShapes':
          interpreter.getInputTensors().map((tensor) => tensor.shape).toList(),
      'outputShapes':
          interpreter.getOutputTensors().map((tensor) => tensor.shape).toList(),
    };
  }

  /// Backward-compatible entry point. Results remain raw model outputs;
  /// the app cannot infer "energy" semantics from an arbitrary TFLite tensor.
  Future<Map<String, dynamic>> runEnergyAnalysis(String text) async {
    final model = _selectedModel;
    if (model == null) return {'error': 'لم يتم اختيار نموذج محلي TFLite.'};
    return runInference(model, extractFeatures(text));
  }

  /// A generic classifier does not perform pattern discovery merely because
  /// the same inference was invoked twice.
  Future<Map<String, dynamic>> runPatternDiscovery(String text) async {
    return {
      'supported': false,
      'error':
          'اكتشاف الأنماط غير متاح دون نموذج موثق لهذه المهمة؛ لم تُختلق نتيجة.',
    };
  }

  Future<Map<String, dynamic>> runTopicClassification(String text) async {
    return runInference('topic_classification', extractFeatures(text));
  }

  Future<void> unloadModel(String modelName) async {
    final interpreter = _loadedModels.remove(modelName);
    interpreter?.close();
    if (_selectedModel == modelName) {
      _selectedModel = null;
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_selectedModelKey);
    }
  }

  Future<void> unloadAllModels() async {
    for (final interpreter in _loadedModels.values) {
      interpreter.close();
    }
    _loadedModels.clear();
    _selectedModel = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_selectedModelKey);
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
