import 'package:flutter/material.dart';
import '../../services/external_model_service.dart';

/// UI state for verified on-device inference.
///
/// TFLite's Interpreter is an inference runtime, not a training framework. This
/// provider therefore never labels a heuristic weight update as model training.
class TrainingProvider extends ChangeNotifier {
  final ExternalModelService _modelService = ExternalModelService();
  bool _initialized = false;
  bool _initializing = false;
  bool _isTraining = false;
  String _status = 'لم يتم التحقق من نموذج محلي بعد.';
  String? _error;

  bool get isTraining => _isTraining;
  double get progress => 0;
  String get status => _status;
  String? get error => _error;
  List<Map<String, dynamic>> get history => const [];
  bool get modelLoaded => _modelService.hasSelectedModel;
  bool get initialized => _initialized;
  String? get selectedModel => _modelService.selectedModel;
  Map<String, dynamic> get modelInfo {
    final name = _modelService.selectedModel;
    return name == null
        ? const {'loaded': false}
        : _modelService.getModelInfo(name);
  }

  Future<void> initialize() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    _status = 'جارٍ التحقق من النموذج المحلي المحفوظ...';
    notifyListeners();
    try {
      final restored = await _modelService.restoreSelectedModel();
      _status = restored
          ? 'تم تحميل النموذج المحلي وتشغيل اختبار الاستدلال بنجاح.'
          : 'لا يوجد نموذج نصي محلي متوافق. استورد ملف TFLite متوافقاً لتفعيل الاستدلال.';
      _error = null;
    } catch (e) {
      _error = e.toString();
      _status = 'تعذر التحقق من النموذج المحلي: $_error';
    } finally {
      _initialized = true;
      _initializing = false;
      notifyListeners();
    }
  }

  Future<String> importLocalModel(String path) async {
    _status = 'جارٍ نسخ النموذج وفحص بنيته وتشغيل اختبار استدلال حقيقي...';
    _error = null;
    notifyListeners();
    try {
      final name = await _modelService.importAndLoadModel(path);
      _status = 'تم تحميل النموذج "$name" واجتاز اختبار الاستدلال الأولي.';
      _initialized = true;
      notifyListeners();
      return name;
    } catch (e) {
      _error = e.toString();
      _status = 'رُفض النموذج ولم يُعتمد: $_error';
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predict(String text) async {
    if (!_modelService.hasSelectedModel) {
      throw StateError('لا يوجد نموذج محلي متوافق محمّل. استورد ملف TFLite أولاً.');
    }
    final result = await _modelService.runEnergyAnalysis(text);
    if (result.containsKey('error')) {
      throw StateError(result['error'].toString());
    }
    if (result['inferenceExecuted'] != true) {
      throw StateError('لم يؤكد محرك TFLite تنفيذ الاستدلال؛ لن تُعرض نتيجة.');
    }
    return result;
  }

  /// TFLite Interpreter performs inference only. Do not simulate training by
  /// updating a small output layer and claiming that the Quran model learned.
  Future<void> trainOnVerses(
    List<Map<String, dynamic>> verses, {
    int epochs = 50,
  }) async {
    _status =
        'التدريب غير متاح في هذا الإصدار: يتطلب نموذجاً قابلاً للتدريب وخط تدريب حقيقياً. لم تُغيّر أي أوزان.';
    _error = _status;
    notifyListeners();
    throw UnsupportedError(_status);
  }

  void stopTraining() {
    _isTraining = false;
    _status = 'لا توجد عملية تدريب فعلية قيد التشغيل.';
    notifyListeners();
  }
}
