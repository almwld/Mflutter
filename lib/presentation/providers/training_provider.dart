import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/on_device_training_service.dart';
import '../../python/mudabbir_python_engine.dart';

class TrainingProvider extends ChangeNotifier {
  final _trainingService = OnDeviceTrainingService();
  final _engine = MudabbirPythonEngine();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _initialized = false;

  bool get isTraining => _trainingService.isTraining;
  double get progress => _trainingService.progress;
  String get status => _trainingService.status;
  List<Map<String, dynamic>> get history => _trainingService.history;
  bool get modelLoaded => _engine.isInitialized;

  Future<void> initialize() async {
    if (_initialized) return;
    await _engine.initialize();
    _initialized = true;
    notifyListeners();
  }

  Future<void> trainOnVerses(List<Map<String, dynamic>> verses, {int epochs = 50}) async {
    await initialize();
    await _subscription?.cancel();
    _subscription = _trainingService.progressStream?.listen((_) => notifyListeners());
    try {
      await _trainingService.startTraining(verses: verses, epochs: epochs);
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
