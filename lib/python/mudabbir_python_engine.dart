import '../services/external_model_service.dart';

/// Compatibility facade for older callers.
///
/// This class no longer pretends that a hand-written feature vector plus
/// randomly initialized matrices is a trained neural network. All inference is
/// delegated to a verified TFLite model imported by ExternalModelService.
class MudabbirPythonEngine {
  static final MudabbirPythonEngine _instance = MudabbirPythonEngine._();
  factory MudabbirPythonEngine() => _instance;
  MudabbirPythonEngine._();

  final ExternalModelService _models = ExternalModelService();
  bool _initialized = false;

  bool get isInitialized => _initialized && _models.hasSelectedModel;

  /// Legacy getters remain empty because no JSON weights or training history
  /// are bundled with this application.
  Map<String, dynamic> get modelWeights => const {};
  List<Map<String, dynamic>> get trainingHistory => const [];

  Future<void> initialize() async {
    if (_models.hasSelectedModel) {
      _initialized = true;
      return;
    }
    final restored = await _models.restoreSelectedModel();
    _initialized = restored;
    if (!restored) {
      throw StateError(
        'لا يوجد نموذج TFLite نصي متوافق محمّل. استورد نموذجاً صالحاً أولاً.',
      );
    }
  }

  List<double> extractFeatures(String text) => _models.extractFeatures(text);

  List<double> forward(List<double> input) {
    final model = _models.selectedModel;
    if (!_models.hasSelectedModel || model == null) {
      throw StateError('لا يوجد نموذج محلي متوافق للاستدلال.');
    }
    final result = _models.runInference(model, input);
    if (result.containsKey('error')) {
      throw StateError(result['error'].toString());
    }
    return List<double>.from(result['outputs'] as List);
  }

  Map<String, dynamic> predict(String text) {
    final features = extractFeatures(text);
    final output = forward(features);
    var best = 0;
    for (var i = 1; i < output.length; i++) {
      if (output[i] > output[best]) best = i;
    }
    final sum = output.fold<double>(0, (a, b) => a + b);
    final isProbabilityDistribution =
        output.every((value) => value >= 0 && value <= 1) &&
        (sum - 1).abs() < 0.02;
    return {
      'model': _models.selectedModel,
      'inferenceExecuted': true,
      'predictionIndex': best,
      'outputs': output,
      'confidence': isProbabilityDistribution ? output[best] : null,
      'outputIsProbabilityDistribution': isProbabilityDistribution,
    };
  }

  /// The Flutter TFLite interpreter is inference-only. A genuine training
  /// implementation must be connected before this method can report success.
  Future<Map<String, dynamic>> trainModel({
    required List<List<double>> xTrain,
    required List<int> yTrain,
    int epochs = 100,
    double learningRate = 0.001,
    Function(double loss, int epoch)? onProgress,
  }) async {
    if (xTrain.isEmpty || yTrain.isEmpty || xTrain.length != yTrain.length) {
      throw ArgumentError('بيانات التدريب فارغة أو غير متطابقة.');
    }
    throw UnsupportedError(
      'لم يبدأ التدريب: لا يحتوي التطبيق على مسار تدريب فعلي قابل لتحديث '
      'أوزان TFLite. لم يتم تغيير الأوزان أو تصدير نموذج.',
    );
  }

  Future<bool> loadModelFromDisk() => _models.restoreSelectedModel();
}
