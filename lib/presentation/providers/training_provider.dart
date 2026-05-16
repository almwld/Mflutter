import 'package:flutter/material.dart';
import '../../services/on_device_training_service.dart';
import '../../python/mudabbir_python_engine.dart';

class TrainingProvider extends ChangeNotifier {
  final _trainingService = OnDeviceTrainingService();
  final _engine = MudabbirPythonEngine();

  bool get isTraining => _trainingService.isTraining;
  double get progress => _trainingService.progress;
  String get status => _trainingService.status;
  List<Map<String, dynamic>> get history => _trainingService.history;
  bool get modelLoaded => _engine.isInitialized;

  Future<void> initialize() async {
    await _engine.initialize();
    notifyListeners();
  }

  Future<void> trainOnVerses(List<Map<String, dynamic>> verses, {int epochs = 50}) async {
    await _trainingService.startTraining(verses: verses, epochs: epochs);
    notifyListeners();
  }

  Map<String, dynamic> predict(String text) {
    final result = _engine.predict(text);
    notifyListeners();
    return result;
  }

  List<double> extractFeatures(String text) {
    return _engine.extractFeatures(text);
  }
}
