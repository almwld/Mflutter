import 'dart:async';
import '../python/mudabbir_python_engine.dart';

class OnDeviceTrainingService {
  static final OnDeviceTrainingService _instance = OnDeviceTrainingService._();
  factory OnDeviceTrainingService() => _instance;
  OnDeviceTrainingService._();

  final _engine = MudabbirPythonEngine();
  bool _isTraining = false;
  double _progress = 0.0;
  String _status = 'جاهز';
  List<Map<String, dynamic>> _history = [];

  bool get isTraining => _isTraining;
  double get progress => _progress;
  String get status => _status;
  List<Map<String, dynamic>> get history => _history;

  StreamController<Map<String, dynamic>>? _progressController;
  Stream<Map<String, dynamic>>? get progressStream => _progressController?.stream;

  /// بدء التدريب على الجهاز
  Future<void> startTraining({
    required List<Map<String, dynamic>> verses,
    int epochs = 50,
  }) async {
    if (_isTraining) return;

    _isTraining = true;
    _progress = 0.0;
    _status = 'جاري تهيئة البيانات...';
    _progressController = StreamController<Map<String, dynamic>>.broadcast();

    await _engine.initialize();

    // تجهيز بيانات التدريب
    final xTrain = <List<double>>[];
    final yTrain = <int>[];

    for (final verse in verses) {
      final text = verse['text'] ?? '';
      final features = _engine.extractFeatures(text);
      xTrain.add(features);

      // تصنيف حسب المحور
      final axisType = verse['axis_type'] ?? 'cosmic';
      switch (axisType) {
        case 'cosmic': yTrain.add(0); break;
        case 'tranquil': yTrain.add(1); break;
        case 'calculation': yTrain.add(2); break;
        default: yTrain.add(0);
      }
    }

    _status = 'جاري التدريب... (${xTrain.length} عينة)';

    // تشغيل التدريب
    final result = await _engine.trainModel(
      xTrain: xTrain,
      yTrain: yTrain,
      epochs: epochs,
      learningRate: 0.002,
      onProgress: (loss, epoch) {
        _progress = epoch / epochs;
        _status = 'Epoch $epoch/$epochs - Loss: ${loss.toStringAsFixed(4)}';
        _progressController?.add({
          'epoch': epoch,
          'loss': loss,
          'progress': _progress,
        });
      },
    );

    _history = _engine.trainingHistory;
    _status = '✅ اكتمل التدريب - Loss: ${result['final_loss']?.toStringAsFixed(4)}';
    _isTraining = false;
    _progressController?.add({'done': true, 'result': result});
  }

  /// إيقاف التدريب
  void stopTraining() {
    _isTraining = false;
    _status = 'متوقف';
    _progressController?.close();
  }
}
