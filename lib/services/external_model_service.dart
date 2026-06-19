import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/feature_extractor.dart';

/// =============================================================================
/// ExternalModelService - خدمة النماذج الخارجية
/// =============================================================================

class ExternalModelService {
  static const String _modelsPath = '/storage/emulated/0/Download/mudabbir_models/';
  static final ExternalModelService _instance = ExternalModelService._internal();

  factory ExternalModelService() => _instance;
  ExternalModelService._internal();

  final Map<String, Interpreter> _loadedModels = {};
  final FeatureExtractor _featureExtractor = FeatureExtractor();

  /// فحص وجود النماذج
  Future<bool> checkModelsExist() async {
    try {
      final directory = Directory(_modelsPath);
      if (!await directory.exists()) return false;

      final files = await directory.list().toList();
      return files.any((f) => f.path.endsWith('.tflite'));
    } catch (e) {
      return false;
    }
  }

  /// تحميل جميع النماذج
  Future<void> loadAllModels() async {
    try {
      final directory = Directory(_modelsPath);
      if (!await directory.exists()) return;

      final files = await directory.list().toList();
      for (final file in files) {
        if (file.path.endsWith('.tflite')) {
          final modelName = file.path.split('/').last.replaceAll('.tflite', '');
          await loadModel(modelName);
        }
      }
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  /// تحميل نموذج واحد
  Future<void> loadModel(String modelName) async {
    try {
      final modelPath = '$_modelsPath$modelName.tflite';
      final interpreter = await Interpreter.fromAsset(modelPath);
      _loadedModels[modelName] = interpreter;
    } catch (e) {
      print('Error loading model $modelName: $e');
    }
  }

  /// استخراج الميزات من النص
  List<double> extractFeatures(String text) {
    return _featureExtractor.extract(text);
  }

  /// تشغيل الاستدلال
  Map<String, dynamic> runInference(String modelName, List<double> features) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) {
      return {'error': 'Model not loaded'};
    }

    try {
      final input = [features];
      final output = List.filled(1, List.filled(1, 0.0));

      interpreter.run(input, output);

      return {
        'prediction': output[0][0],
        'confidence': _calculateConfidence(output[0]),
        'model': modelName,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// الحصول على معلومات النموذج
  Map<String, dynamic> getModelInfo(String modelName) {
    final interpreter = _loadedModels[modelName];
    if (interpreter == null) {
      return {'loaded': false};
    }

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

  /// تشغيل تحليل الطاقة
  Future<Map<String, dynamic>> runEnergyAnalysis(String text) async {
    final features = extractFeatures(text);
    return runInference('energy_analysis', features);
  }

  /// تشغيل اكتشاف الأنماط
  Future<Map<String, dynamic>> runPatternDiscovery(String text) async {
    final features = extractFeatures(text);
    return runInference('pattern_discovery', features);
  }

  /// تشغيل تصنيف المواضيع
  Future<Map<String, dynamic>> runTopicClassification(String text) async {
    final features = extractFeatures(text);
    return runInference('topic_classification', features);
  }

  /// إيقاف تحميل نموذج
  Future<void> unloadModel(String modelName) async {
    _loadedModels.remove(modelName);
  }

  /// إيقاف تحميل جميع النماذج
  Future<void> unloadAllModels() async {
    _loadedModels.clear();
  }

  /// الحصول على قائمة النماذج المحملة
  List<String> get loadedModels => _loadedModels.keys.toList();
}