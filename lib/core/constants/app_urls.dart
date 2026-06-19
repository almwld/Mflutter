/// =============================================================================
/// AppURLs - روابط التطبيق
/// =============================================================================
/// روابط البيانات والنماذج والمصادر الخارجية
/// =============================================================================

class AppURLs {
  AppURLs._();

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات التخزين
  // ═══════════════════════════════════════════════════════════════════════════

  /// المسار الأساسي للتخزين الخارجي
  static const String externalStoragePath = '/storage/emulated/0/';

  /// مجلد التحميلات
  static const String downloadsPath = '${externalStoragePath}Download/';

  /// مجلد النماذج
  static const String modelsDirectory = 'mudabbir_models/';

  /// المسار الكامل لمجلد النماذج
  static String get modelsPath => '$downloadsPath$modelsDirectory';

  /// مسار قاعدة البيانات
  static const String databasePath = '$modelsDirectory/mudabbir.db';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات النواة
  // ═══════════════════════════════════════════════════════════════════════════

  /// مجلد النواة
  static const String nucleusDirectory = 'nucleus/';

  /// اسم ملف النواة
  static const String nucleusFileName = 'mudabbir_nucleus.json';

  /// المسار الكامل للنواة
  static String get nucleusPath => '$modelsPath$nucleusDirectory';

  /// المسار الكامل لملف النواة
  static String get nucleusFilePath => '$nucleusPath$nucleusFileName';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات النماذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// نموذج تصنيف الجُزء
  static const String juzModelFile = 'juz_classifier.tflite';

  /// نموذج اكتشاف الأنماط
  static const String patternModelFile = 'pattern_discovery.tflite';

  /// نموذج مكي/مدني
  static const String makkiMadaniModelFile = 'makki_madani_classifier.tflite';

  /// نموذج تصنيف المواضيع
  static const String topicModelFile = 'topic_classifier.tflite';

  /// نموذج تحليل الطاقة
  static const String energyModelFile = 'energy_analyzer.tflite';

  /// نموذج توقع الآيات
  static const String versePredictModelFile = 'verse_predictor.tflite';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات النماذج الكاملة
  // ═══════════════════════════════════════════════════════════════════════════

  /// المسار الكامل لنموذج الجُزء
  static String get juzModelPath => '$modelsPath$juzModelFile';

  /// المسار الكامل لنموذج النمط
  static String get patternModelPath => '$modelsPath$patternModelFile';

  /// المسار الكامل لنموذج مكي/مدني
  static String get makkiMadaniModelPath => '$modelsPath$makkiMadaniModelFile';

  /// المسار الكامل لنموذج المواضيع
  static String get topicModelPath => '$modelsPath$topicModelFile';

  /// المسار الكامل لنموذج الطاقة
  static String get energyModelPath => '$modelsPath$energyModelFile';

  /// المسار الكامل لنموذج توقع الآيات
  static String get versePredictModelPath => '$modelsPath$versePredictModelFile';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات قواعد البيانات
  // ═══════════════════════════════════════════════════════════════════════════

  /// اسم قاعدة البيانات
  static const String databaseName = 'mudabbir.db';

  /// المسار الكامل لقاعدة البيانات
  static String get databaseFilePath => '$modelsPath$databaseName';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات الأصول
  // ═══════════════════════════════════════════════════════════════════════════

  /// مجلد البيانات
  static const String assetsDataPath = 'assets/data/';

  /// مجلد النماذج في الأصول
  static const String assetsModelsPath = 'assets/models/';

  /// مجلد الصور
  static const String assetsImagesPath = 'assets/images/';

  // ═══════════════════════════════════════════════════════════════════════════
  // ملفات البيانات
  // ═══════════════════════════════════════════════════════════════════════════

  /// ملف الأسماء الإلهية
  static const String divineNamesFile = 'divine_names.json';

  /// ملف العلوم
  static const String sciencesFile = 'sciences.json';

  /// ملف الأسئلة
  static const String insightsFile = 'insights.json';

  /// ملف الصفات
  static const String attributesFile = 'attributes.json';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات الملفات الكاملة
  // ═══════════════════════════════════════════════════════════════════════════

  /// المسار الكامل لملف الأسماء
  static String get divineNamesPath => '$assetsDataPath$divineNamesFile';

  /// المسار الكامل لملف العلوم
  static String get sciencesPath => '$assetsDataPath$sciencesFile';

  /// المسار الكامل لملف الأسئلة
  static String get insightsPath => '$assetsDataPath$insightsFile';

  /// المسار الكامل لملف الصفات
  static String get attributesPath => '$assetsDataPath$attributesFile';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات ذاكرة التطبيق
  // ═══════════════════════════════════════════════════════════════════════════

  /// مسار ذاكرة التطبيق
  static const String appDocumentsPath = 'documents/';

  /// مسار ذاكرة التطبيق المؤقتة
  static const String appTempPath = 'temp/';

  /// مسار ذاكرة التخزين المؤقت
  static const String appCachePath = 'cache/';

  // ═══════════════════════════════════════════════════════════════════════════
  // معرفات الموارد
  // ═══════════════════════════════════════════════════════════════════════════

  /// معرف القرآن
  static const String quranResourceId = 'quran_db';

  /// معرف النواة
  static const String nucleusResourceId = 'nucleus_json';

  /// معرف الأسماء
  static const String namesResourceId = 'names_json';

  /// معرف العلوم
  static const String sciencesResourceId = 'sciences_json';
}