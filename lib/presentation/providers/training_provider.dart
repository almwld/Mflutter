import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/on_device_training_service.dart';
import '../../python/mudabbir_python_engine.dart';

class TrainingProvider extends ChangeNotifier {
  final _trainingService = OnDeviceTrainingService();
  final _engine = MudabbirPythonEngine();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _initialized = false;
  Future<void>? _initializing;
  String? _modelInitializationError;

  bool get isTraining => _trainingService.isTraining;
  double get progress => _trainingService.progress;
  String get status {
    if (_modelInitializationError != null &&
        !_engine.isInitialized &&
        _trainingService.status == 'جاهز') {
      return 'لا يوجد نموذج مدرّب محمّل؛ يمكن بدء تدريب المصنف المحلي.';
    }
    return _trainingService.status;
  }
  List<Map<String, dynamic>> get history => _trainingService.history;
  bool get modelLoaded => _engine.isInitialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }
    final attempt = _initializeOnce();
    _initializing = attempt;
    try {
      await attempt;
    } finally {
      if (identical(_initializing, attempt)) _initializing = null;
    }
  }

  Future<void> _initializeOnce() async {
    try {
      await _engine.initialize();
      _modelInitializationError = null;
    } catch (error) {
      // A missing starter checkpoint must not block training from scratch.
      // Keep the failure visible and allow a later explicit retry.
      _modelInitializationError = error.toString();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> retryInitialize() async {
    if (_trainingService.isTraining) return;
    _initialized = false;
    _modelInitializationError = null;
    await initialize();
  }

  Future<void> trainOnVerses(List<Map<String, dynamic>> verses, {int epochs = 50}) async {
    await initialize();
    await _subscription?.cancel();
    // startTraining creates its run-scoped stream synchronously before its
    // first await, so subscribe after invoking it rather than to a null stream.
    final training = _trainingService.startTraining(verses: verses, epochs: epochs);
    _subscription = _trainingService.progressStream?.listen((_) => notifyListeners());
    try {
      await training;
      if (_engine.isInitialized) _modelInitializationError = null;
    } finally {
      await _subscription?.cancel();
      _subscription = null;
      notifyListeners();
    }
  }

  void stopTraining() {
    _trainingService.stopTraining();
    notifyListeners();
  }

  Map<String, dynamic> predict(String text) {
    if (!_engine.isInitialized) {
      throw StateError('النموذج غير مهيأ بعد.');
    }
    return _engine.predict(text);
  }

  List<double> extractFeatures(String text) => _engine.extractFeatures(text);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
