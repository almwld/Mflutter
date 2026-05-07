/// =============================================================================
/// ModelInfo - معلومات النموذج
/// =============================================================================

class ModelInfo {
  final String name;
  final String path;
  final String type;
  final int size;
  final bool isLoaded;
  final DateTime? lastUsed;

  const ModelInfo({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.isLoaded = false,
    this.lastUsed,
  });

  /// اسم النموذج المعروض
  String get displayName => name.replaceAll('.tflite', '').replaceAll('_', ' ');

  /// الحجم المُنسم
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// الوصف
  String get description =>
      'النوع: $type\n'
      'الحجم: $sizeFormatted\n'
      '${isLoaded ? 'مُحمَّل' : 'غير مُحمَّل'}';
}

/// =============================================================================
/// InferenceResult - نتيجة الاستدلال
/// =============================================================================

class InferenceResult {
  final String modelName;
  final Map<String, dynamic> output;
  final double confidence;
  final Duration processingTime;
  final String? error;

  const InferenceResult({
    required this.modelName,
    required this.output,
    required this.confidence,
    required this.processingTime,
    this.error,
  });

  /// هل نجح؟
  bool get isSuccess => error == null;

  /// الوصف
  String get description =>
      'النموذج: $modelName\n'
      'الثقة: ${(confidence * 100).toStringAsFixed(1)}%\n'
      'الوقت: ${processingTime.inMilliseconds} مللي ثانية';
}

/// =============================================================================
/// ModelLoadProgress - تقدم تحميل النموذج
/// =============================================================================

class ModelLoadProgress {
  final String modelName;
  final int currentProgress;
  final int totalProgress;
  final String status;

  const ModelLoadProgress({
    required this.modelName,
    required this.currentProgress,
    required this.totalProgress,
    required this.status,
  });

  /// النسبة المئوية
  double get percent =>
      totalProgress > 0 ? (currentProgress / totalProgress) * 100 : 0;

  /// الوصف
  String get description =>
      '$modelName: $currentProgress / $totalProgress ($percent%)';
}