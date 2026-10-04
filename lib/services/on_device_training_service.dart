import 'dart:async';
import '../python/mudabbir_python_engine.dart';
import 'qwen_merge_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
    _status = 'اكتمل تدريب الطبقة المحلية؛ جارٍ فحص أوزان Qwen...';
    final docs = await getApplicationDocumentsDirectory();
    final adapter = qwenAdapterPath ?? (docs.path + '/qwen_adapter');
    final adapterDir = Directory(adapter);
    QwenMergeResult? mergeResult;
    if (await adapterDir.exists()) {
      mergeResult = await QwenMergeService().mergeAdapter(adapterPath: adapter);
      _status = mergeResult.merged
          ? 'تم دمج أوزان Qwen وتحديث النموذج المحلي.'
          : 'اكتمل التدريب لكن تعذر دمج Qwen: ${mergeResult.error ?? mergeResult.status}';
    } else {
      _status = 'اكتمل التدريب؛ لا يوجد LoRA adapter لـQwen بعد. تم الاحتفاظ بالأوزان المحلية دون ادعاء دمج.';
    }
    _isTraining = false;
    _progressController?.add({'done': true, 'result': result, 'qwenMerge': mergeResult?.status});
  }

  /// إيقاف التدريب
  void stopTraining() {
    _isTraining = false;
    _status = 'متوقف';
    _progressController?.close();
  }
}
