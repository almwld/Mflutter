import 'dart:io';
import '../../../core/constants/app_urls.dart';

/// =============================================================================
/// ModelsLocalDatasource - مصدر بيانات النماذج المحلي
/// =============================================================================

class ModelsLocalDatasource {
  final Map<String, bool> _loadedModels = {};
  final Map<String, List<double>> _modelOutputs = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // التهيئة
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من وجود النماذج
  Future<bool> checkModelsExist() async {
    final modelsDir = Directory(AppURLs.modelsPath);
    return await modelsDir.exists();
  }

  /// جلب معلومات النماذج
  Future<List<Map<String, dynamic>>> getModelsInfo() async {
    final models = <Map<String, dynamic>>[];

    final modelFiles = [
      AppURLs.juzModelFile,
      AppURLs.patternModelFile,
      AppURLs.makkiMadaniModelFile,
      AppURLs.topicModelFile,
      AppURLs.energyModelFile,
      AppURLs.versePredictModelFile,
    ];

    for (final file in modelFiles) {
      final path = '${AppURLs.modelsPath}$file';
      final fileObj = File(path);
      final exists = await fileObj.exists();
      final size = exists ? await fileObj.length() : 0;

      models.add({
        'name': file,
        'path': path,
        'size': size,
        'loaded': _loadedModels[file] ?? false,
      });
    }

    return models;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحميل النماذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل نموذج
  Future<bool> loadModel(String modelName) async {
    try {
      final path = _modelPath(modelName);
      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        _loadedModels[modelName] = false;
        return false;
      }
      _loadedModels[modelName] = true;
      return true;
    } catch (_) {
      _loadedModels[modelName] = false;
      return false;
    }
  }

  Future<void> loadAllModels() async {
    final modelFiles = [
      AppURLs.juzModelFile,
      AppURLs.patternModelFile,
      AppURLs.makkiMadaniModelFile,
      AppURLs.topicModelFile,
      AppURLs.energyModelFile,
      AppURLs.versePredictModelFile,
    ];
    for (final file in modelFiles) {
      await loadModel(file);
    }
  }

  Future<void> unloadModel(String modelName) async {
    _loadedModels[modelName] = false;
    _modelOutputs.remove(modelName);
  }

  Future<Map<String, dynamic>> runInference(
    String modelName,
    List<double> features,
  ) async {
    if (features.isEmpty) return {'error': 'لا توجد ميزات للاستدلال'};
    if (!(_loadedModels[modelName] ?? false) && !await loadModel(modelName)) {
      return {
        'error': 'النموذج المحلي غير متوفر',
        'model': modelName,
        'path': _modelPath(modelName),
      };
    }

    return {
      'error': 'يجب تشغيل الاستدلال عبر TFLiteDatasource',
      'model': modelName,
    };
  }

  String _modelPath(String modelName) {
    if (modelName.startsWith(AppURLs.modelsPath)) return modelName;
    return AppURLs.modelsPath + modelName;
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // الميزات
  // ═══════════════════════════════════════════════════════════════════════════

  /// استخراج الميزات
  List<double> extractFeatures(String text) {
    final features = List<double>.filled(4096, 0.0);

    // تحويل النص إلى أرقام
    final charCodes = text.runes.toList();

    for (int i = 0; i < charCodes.length && i < features.length; i++) {
      features[i] = charCodes[i] / 4096.0;
    }

    // إضافة معلومات إضافية
    features[4000] = text.length / 1000;
    features[4001] = text.split(' ').length / 100;

    return features;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // المعلومات
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب معلومات نموذج
  Map<String, dynamic> getModelInfo(String modelName) {
    return {
      'name': modelName,
      'loaded': _loadedModels[modelName] ?? false,
      'type': _getModelType(modelName),
    };
  }

  String _getModelType(String modelName) {
    if (modelName.contains('juz')) return 'classification';
    if (modelName.contains('pattern')) return 'detection';
    if (modelName.contains('makki')) return 'classification';
    if (modelName.contains('topic')) return 'classification';
    if (modelName.contains('energy')) return 'analysis';
    if (modelName.contains('verse')) return 'prediction';
    return 'unknown';
  }

  /// جلب حالة النموذج
  bool isModelLoaded(String modelName) => _loadedModels[modelName] ?? false;
}