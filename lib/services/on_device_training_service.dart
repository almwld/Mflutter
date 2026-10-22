import 'dart:async';

import '../python/mudabbir_python_engine.dart';

/// Coordinates the local classifier trainer. This is not an LLM trainer and
/// never claims to modify or merge Qwen/GGUF weights.
class OnDeviceTrainingService {
  static final OnDeviceTrainingService _instance = OnDeviceTrainingService._();
  factory OnDeviceTrainingService() => _instance;
  OnDeviceTrainingService._();

  final _engine = MudabbirPythonEngine();
  bool _isTraining = false;
  bool _cancelRequested = false;
  double _progress = 0.0;
  String _status = 'جاهز';
  List<Map<String, dynamic>> _history = [];

  bool get isTraining => _isTraining;
  double get progress => _progress;
  String get status => _status;
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  StreamController<Map<String, dynamic>>? _progressController;
  Stream<Map<String, dynamic>>? get progressStream => _progressController?.stream;

  Future<void> startTraining({
    required List<Map<String, dynamic>> verses,
    int epochs = 50,
    String? qwenAdapterPath,
  }) async {
    if (_isTraining) return;
    if (verses.isEmpty) {
      _status = 'تعذر التدريب: لا توجد عينات.';
      return;
    }
    if (epochs < 1 || epochs > 500) {
      _status = 'تعذر التدريب: عدد العصور يجب أن يكون بين 1 و500.';
      return;
    }

    _isTraining = true;
    _cancelRequested = false;
    _progress = 0;
    _status = 'جاري التحقق من بيانات التدريب...';
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _progressController = controller;

    try {
      final xTrain = <List<double>>[];
      final yTrain = <int>[];
      for (var index = 0; index < verses.length; index++) {
        if (_cancelRequested) throw StateError('أُلغي التدريب.');
        final verse = verses[index];
        final rawText = verse['text'];
        if (rawText is! String || rawText.trim().isEmpty) {
          throw FormatException('نص العينة رقم ${index + 1} فارغ أو غير صالح.');
        }
        final rawAxis = verse['axis_type'];
        final int label;
        switch (rawAxis) {
          case 'cosmic':
            label = 0;
            break;
          case 'tranquil':
            label = 1;
            break;
          case 'calculation':
            label = 2;
            break;
          default:
            throw FormatException(
              'تصنيف العينة رقم ${index + 1} غير معروف: $rawAxis',
            );
        }
        xTrain.add(_engine.extractFeatures(rawText));
        yTrain.add(label);
      }

      _status = 'تدريب مصنف محلي فعلي على ${xTrain.length} عينة...';
      controller.add({'stage': 'training', 'samples': xTrain.length});
      final result = await _engine.trainModel(
        xTrain: xTrain,
        yTrain: yTrain,
        epochs: epochs,
        learningRate: 0.002,
        shouldCancel: () => _cancelRequested,
        onProgress: (loss, epoch) {
          _progress = epoch / epochs;
          _status = 'تدريب المصنف: Epoch $epoch/$epochs — Loss: ${loss.toStringAsFixed(5)}';
          controller.add({
            'epoch': epoch,
            'loss': loss,
            'progress': _progress,
          });
        },
      );

      _history = List<Map<String, dynamic>>.from(_engine.trainingHistory);
      _status = 'اكتمل تدريب المصنف المحلي وحُفظت أوزانه. لم تُعدّل أوزان Qwen أو GGUF.';
      controller.add({
        'done': true,
        'result': result,
        'model': 'linear_sparse_v2',
        'qwenMerge': 'not_attempted',
        'message': _status,
      });
    } catch (error) {
      final cancelled = _cancelRequested;
      _status = cancelled ? 'أُلغي التدريب ولم يُعلن اكتماله.' : 'فشل التدريب: $error';
      controller.add({
        'done': true,
        'cancelled': cancelled,
        'error': error.toString(),
        'message': _status,
      });
    } finally {
      _isTraining = false;
      _cancelRequested = false;
      try {
        await controller.close();
      } catch (_) {}
      if (identical(_progressController, controller)) {
        _progressController = null;
      }
    }
  }

  /// Requests cooperative cancellation; the trainer checks between samples.
  void stopTraining() {
    if (!_isTraining) {
      _status = 'لا يوجد تدريب جارٍ.';
      return;
    }
    _cancelRequested = true;
    _status = 'جارٍ إيقاف التدريب بأمان...';
  }
}
