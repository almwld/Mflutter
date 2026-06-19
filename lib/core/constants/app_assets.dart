/// =============================================================================
/// AppAssets - مسارات الأصول
/// =============================================================================
/// مسارات الأصول والصور والأصوات والملفات
/// =============================================================================

class AppAssets {
  AppAssets._();

  // ═══════════════════════════════════════════════════════════════════════════
  // مجلدات الأصول
  // ═══════════════════════════════════════════════════════════════════════════

  /// مجلد الأصول الرئيسي
  static const String assetsPath = 'assets/';

  /// مجلد البيانات
  static const String dataPath = 'assets/data/';

  /// مجلد النماذج
  static const String modelsPath = 'assets/models/';

  /// مجلد الصور
  static const String imagesPath = 'assets/images/';

  // ═══════════════════════════════════════════════════════════════════════════
  // ملفات قاعدة البيانات
  // ═══════════════════════════════════════════════════════════════════════════

  /// اسم قاعدة بيانات القرآن
  static const String quranDbName = 'mudabbir.db';

  /// مسار قاعدة البيانات
  static const String quranDbPath = '${dataPath}quran.db';

  // ═══════════════════════════════════════════════════════════════════════════
  // ملفات النماذج
  // ═══════════════════════════════════════════════════════════════════════════

  /// مجلد النماذج الخارجي
  static const String externalModelsPath = '/storage/emulated/0/Download/mudabbir_models/';

  /// نموذج الجُزء
  static const String juzModel = 'juz_classifier.tflite';

  /// نموذج النمط
  static const String patternModel = 'pattern_discovery.tflite';

  /// نموذج مكي/مدني
  static const String makkiMadaniModel = 'makki_madani_classifier.tflite';

  /// نموذج التصنيف
  static const String topicModel = 'topic_classifier.tflite';

  /// نموذج الطاقة
  static const String energyModel = 'energy_analyzer.tflite';

  /// نموذج توقع الآيات
  static const String versePredictModel = 'verse_predictor.tflite';

  // ═══════════════════════════════════════════════════════════════════════════
  // ملفات النواة
  // ═══════════════════════════════════════════════════════════════════════════

  /// ملف النواة
  static const String nucleusFile = 'mudabbir_nucleus.json';

  /// مسار النواة الكامل
  static const String nucleusPath = '${externalModelsPath}nucleus/';

  /// مسار ملف النواة
  static String get nucleusFilePath => '${externalModelsPath}nucleus/$nucleusFile';

  // ═══════════════════════════════════════════════════════════════════════════
  // صور الخلفية
  // ═══════════════════════════════════════════════════════════════════════════

  /// صورة الخلفية الرئيسية
  static const String backgroundMain = '${imagesPath}background_main.png';

  /// صورة الخلفية العميقة
  static const String backgroundDeep = '${imagesPath}background_deep.png';

  /// صورة الخلفية الذهبية
  static const String backgroundGold = '${imagesPath}background_gold.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // أيقونات التنقل
  // ═══════════════════════════════════════════════════════════════════════════

  /// أيقونة القرآن
  static const String iconQuran = '${imagesPath}icon_quran.png';

  /// أيقونة المحادثة
  static const String iconChat = '${imagesPath}icon_chat.png';

  /// أيقونة الجُمَّل
  static const String iconAbjad = '${imagesPath}icon_abjad.png';

  /// أيقونة العلوم
  static const String iconSciences = '${imagesPath}icon_sciences.png';

  /// أيقونة الأسماء
  static const String iconNames = '${imagesPath}icon_names.png';

  /// أيقونة البصيرة
  static const String iconInsight = '${imagesPath}icon_insight.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // أيقونات SVG
  // ═══════════════════════════════════════════════════════════════════════════

  /// أيقونة القرآن SVG
  static const String iconQuranSvg = '${imagesPath}quran.svg';

  /// أيقونة المحادثة SVG
  static const String iconChatSvg = '${imagesPath}chat.svg';

  /// أيقونة الجُمَّل SVG
  static const String iconAbjadSvg = '${imagesPath}abjad.svg';

  /// أيقونة العلوم SVG
  static const String iconSciencesSvg = '${imagesPath}sciences.svg';

  /// أيقونة الأسماء SVG
  static const String iconNamesSvg = '${imagesPath}names.svg';

  /// أيقونة البصيرة SVG
  static const String iconInsightSvg = '${imagesPath}insight.svg';

  // ═══════════════════════════════════════════════════════════════════════════
  // صور العناصر
  // ═══════════════════════════════════════════════════════════════════════════

  /// صورة النار
  static const String elementFire = '${imagesPath}element_fire.png';

  /// صورة الماء
  static const String elementWater = '${imagesPath}element_water.png';

  /// صورة التراب
  static const String elementEarth = '${imagesPath}element_earth.png';

  /// صورة الهواء
  static const String elementAir = '${imagesPath}element_air.png';

  /// صورة الروح
  static const String elementSpirit = '${imagesPath}element_spirit.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // صور الكواكب
  // ═══════════════════════════════════════════════════════════════════════════

  /// صورة الشمس
  static const String planetSun = '${imagesPath}planet_sun.png';

  /// صورة القمر
  static const String planetMoon = '${imagesPath}planet_moon.png';

  /// صورة المريخ
  static const String planetMars = '${imagesPath}planet_mars.png';

  /// صورة عطارد
  static const String planetMercury = '${imagesPath}planet_mercury.png';

  /// صورة الزهرة
  static const String planetVenus = '${imagesPath}planet_venus.png';

  /// صورة المشتري
  static const String planetJupiter = '${imagesPath}planet_jupiter.png';

  /// صورة زُحل
  static const String planetSaturn = '${imagesPath}planet_saturn.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // صور الزخارف
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة إسلامية 1
  static const String ornament1 = '${imagesPath}ornament_1.png';

  /// زخرفة إسلامية 2
  static const String ornament2 = '${imagesPath}ornament_2.png';

  /// زخرفة هندسية
  static const String geometricPattern = '${imagesPath}geometric_pattern.png';

  /// إطار ذهبي
  static const String goldenFrame = '${imagesPath}golden_frame.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // ملفات البيانات
  // ═══════════════════════════════════════════════════════════════════════════

  /// بيانات الأسماء الحسنى
  static const String divineNamesData = '${dataPath}divine_names.json';

  /// بيانات العلوم
  static const String sciencesData = '${dataPath}sciences.json';

  /// بيانات الصفات
  static const String attributesData = '${dataPath}attributes.json';

  /// بيانات الأسئلة
  static const String insightsData = '${dataPath}insights.json';

  // ═══════════════════════════════════════════════════════════════════════════
  // مسارات النماذج الكاملة
  // ═══════════════════════════════════════════════════════════════════════════

  /// مسار نموذج الجُزء الكامل
  static String get juzModelPath => '$externalModelsPath$juzModel';

  /// مسار نموذج النمط الكامل
  static String get patternModelPath => '$externalModelsPath$patternModel';

  /// مسار نموذج مكي/مدني الكامل
  static String get makkiMadaniModelPath => '$externalModelsPath$makkiMadaniModel';

  /// مسار نموذج التصنيف الكامل
  static String get topicModelPath => '$externalModelsPath$topicModel';

  /// مسار نموذج الطاقة الكامل
  static String get energyModelPath => '$externalModelsPath$energyModel';

  /// مسار نموذج توقع الآيات الكامل
  static String get versePredictModelPath => '$externalModelsPath$versePredictModel';
}