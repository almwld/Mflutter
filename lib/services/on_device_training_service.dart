import 'dart:async';

/// Explicitly reports the current training capability.
///
/// The shipped runtime has TFLite inference only; it does not contain a
/// trainable graph, optimizer, backpropagation implementation, or verified
/// training dataset/labels. Refuse training rather than producing misleading
/// "completed" events or exporting random/partially updated weights.
class OnDeviceTrainingService {
  static final OnDeviceTrainingService _instance = OnDeviceTrainingService._();
  factory OnDeviceTrainingService() => _instance;
  OnDeviceTrainingService._();

  bool get isTraining => false;
  double get progress => 0.0;
  String get status =>
      'التدريب غير متاح: يلزم مسار تدريب فعلي ونموذج قابل للتدريب.';
  List<Map<String, dynamic>> get history => const [];

  StreamController<Map<String, dynamic>>? _progressController;
  Stream<Map<String, dynamic>>? get progressStream =>
      _progressController?.stream;

  Future<void> startTraining({
    required List<Map<String, dynamic>> verses,
    int epochs = 50,
    String? qwenAdapterPath,
  }) async {
    if (verses.isEmpty) {
      throw ArgumentError('لا يمكن بدء التدريب دون عينات.');
    }
    if (epochs < 1) {
      throw ArgumentError.value(epochs, 'epochs', 'يجب أن تكون موجبة.');
    }
    throw UnsupportedError(
      'لم يبدأ التدريب: إصدار التطبيق الحالي يدعم استدلال TFLite فقط، '
      'ولا يحتوي على محرك تدريب حقيقي موصول بأوزان قابلة للتحديث. '
      'لم يتم تعديل الأوزان أو تصدير نموذج.',
    );
  }

  void stopTraining() {
    _progressController?.add({
      'done': false,
      'cancelled': true,
      'status': 'لا توجد عملية تدريب فعلية قيد التشغيل.',
    });
    _progressController?.close();
    _progressController = null;
  }
}
