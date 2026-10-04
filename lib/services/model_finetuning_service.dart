class ModelFineTuningService {
  static bool _isTraining = false;
  static int _epochs = 0;
  static double _loss = 0.0;
  static List<String> _trainingLog = [];

  static bool get isTraining => _isTraining;
  static int get epochs => _epochs;
  static double get loss => _loss;
  static List<String> get trainingLog => List.unmodifiable(_trainingLog);

  /// التدريب الحقيقي يحتاج dataset موسومًا ومتوافقًا مع بنية النموذج.
  /// لا ننفذ تدريبًا وهميًا أو نعرض loss اصطناعيًا.
  static Future<void> startFineTuning(List<String> trainingData) async {
    if (trainingData.isEmpty) {
      throw ArgumentError('لا توجد بيانات تدريب.');
    }
    throw StateError(
      'التدريب الدقيق غير متاح حتى يتم توفير dataset حقيقي موسوم وبنية نموذج قابلة للتدريب.',
    );
  }

  static void reset() {
    _isTraining = false;
    _epochs = 0;
    _loss = 0.0;
    _trainingLog = [];
  }
}
