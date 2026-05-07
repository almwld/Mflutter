import 'package:flutter/material.dart';
import '../../data/datasources/local/models_local_datasource.dart';

/// =============================================================================
/// ModelsProvider - مزود النماذج
/// =============================================================================

class ModelsProvider extends ChangeNotifier {
  final ModelsLocalDatasource _datasource = ModelsLocalDatasource();

  List<Map<String, dynamic>> _models = [];
  Map<String, bool> _loadedModels = {};
  bool _isLoading = false;
  String? _error;
  double _loadingProgress = 0.0;

  // getters
  List<Map<String, dynamic>> get models => _models;
  Map<String, bool> get loadedModels => _loadedModels;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get loadingProgress => _loadingProgress;
  int get loadedModelsCount => _loadedModels.values.where((v) => v).length;
  int get totalModelsCount => _models.length;

  /// تهيئة النماذج
  Future<void> initialize() async {
    _isLoading = true;
    _loadingProgress = 0.0;
    notifyListeners();

    try {
      // جلب معلومات النماذج
      _models = await _datasource.getModelsInfo();

      // تحديث حالة النماذج
      for (final model in _models) {
        _loadedModels[model['name'] as String] = model['loaded'] as bool? ?? false;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل نموذج
  Future<bool> loadModel(String modelName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _datasource.loadModel(modelName);
      _loadedModels[modelName] = success;

      if (success) {
        _loadingProgress = (_loadedModels.values.where((v) => v).length / _models.length);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحميل جميع النماذج
  Future<void> loadAllModels() async {
    _isLoading = true;
    _loadingProgress = 0.0;
    notifyListeners();

    try {
      await _datasource.loadAllModels();

      for (final model in _models) {
        _loadedModels[model['name'] as String] = true;
      }

      _loadingProgress = 1.0;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تشغيل استدلال
  Future<Map<String, dynamic>> runInference(
    String modelName,
    List<double> features,
  ) async {
    try {
      return await _datasource.runInference(modelName, features);
    } catch (e) {
      _error = e.toString();
      return {'error': e.toString()};
    }
  }

  /// استخراج الميزات
  List<double> extractFeatures(String text) {
    return _datasource.extractFeatures(text);
  }

  /// إلغاء تحميل نموذج
  Future<void> unloadModel(String modelName) async {
    await _datasource.unloadModel(modelName);
    _loadedModels[modelName] = false;
    _loadingProgress = (_loadedModels.values.where((v) => v).length / _models.length);
    notifyListeners();
  }

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}