import 'dart:convert';
import 'dart:io';

/// =============================================================================
/// NucleusService - خدمة النواة
/// =============================================================================

class NucleusService {
  static final NucleusService _instance = NucleusService._internal();
  factory NucleusService() => _instance;
  NucleusService._internal();

  Map<String, dynamic>? _nucleusData;

  /// قراءة ملف النواة
  Future<void> loadNucleus() async {
    try {
      final file = File('/storage/emulated/0/Download/mudabbir_nucleus.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _nucleusData = jsonDecode(content);
      }
    } catch (e) {
      // استخدام البيانات الافتراضية
      _nucleusData = _defaultNucleus;
    }
  }

  /// الحصول على بيانات النواة
  Map<String, dynamic> getNucleusData() {
    return _nucleusData ?? _defaultNucleus;
  }

  /// الحصول على قيم النواة
  T? getValue<T>(String key) {
    return _nucleusData?[key] as T?;
  }

  /// الحصول على إعدادات النماذج
  Map<String, dynamic> getModelSettings() {
    return _nucleusData?['models'] ?? {};
  }

  /// الحصول على إعدادات الواجهة
  Map<String, dynamic> getUISettings() {
    return _nucleusData?['ui'] ?? {};
  }

  /// الحصول على معلومات العلوم
  List<Map<String, dynamic>> getSciences() {
    return List<Map<String, dynamic>>.from(_nucleusData?['sciences'] ?? []);
  }

  /// الحصول على الأسماء الإلهية
  List<String> getDivineNames() {
    return List<String>.from(_nucleusData?['divine_names'] ?? AbjadConstants.divineNames);
  }

  /// الحصول على الألوان
  Map<String, int> getColors() {
    return Map<String, int>.from(_nucleusData?['colors'] ?? {
      'primary': 0xFF1A237E,
      'gold': 0xFFFFD700,
    });
  }

  /// البيانات الافتراضية
  static final Map<String, dynamic> _defaultNucleus = {
    'version': '1.0.0',
    'models': {
      'energy_analysis': {'enabled': true, 'path': 'energy_analysis.tflite'},
      'pattern_discovery': {'enabled': true, 'path': 'pattern_discovery.tflite'},
      'topic_classification': {'enabled': true, 'path': 'topic_classification.tflite'},
    },
    'ui': {
      'theme': 'dark',
      'language': 'ar',
      'fontScale': 1.0,
    },
    'sciences': [
      {'id': 1, 'name': 'علم الحروف', 'icon': 'abc', 'count': 28},
      {'id': 2, 'name': 'علم الأعداد', 'icon': 'numbers', 'count': 10},
      {'id': 3, 'name': 'علم العناصر', 'icon': 'science', 'count': 5},
      {'id': 4, 'name': 'علم الكواكب', 'icon': 'public', 'count': 7},
      {'id': 5, 'name': 'علم الأبراج', 'icon': 'star', 'count': 12},
      {'id': 6, 'name': 'علم الأسماء', 'icon': 'badge', 'count': 99},
    ],
    'divine_names': [
      'الله', 'الرحمن', 'الرحيم', 'الملك', 'القدوس', 'السلام', 'المؤمن',
      'المهيمن', 'العزيز', 'الجبار', 'المتكبر', 'الخالق', 'البارئ', 'المصور',
      'الغفار', 'القهار', 'الوهاب', 'الرزاق', 'الفتاح', 'العليم', 'القابض',
      'الباسط', 'الخفض', 'الرافع', 'المعز', 'المذل', 'السميع', 'البصير',
      'الحكم', 'العدل', 'اللطيف', 'الخبير', 'الحليم', 'العظيم', 'الغفور',
      'الشكور', 'العلي', 'الغني', 'المغني', 'النور', 'الهادي', 'البديع',
      'الوالي', 'الرؤوف', 'الجليل', 'الكريم', 'الرقيب', 'المجيب', 'الوسع',
      'الحكيم', 'الودود', 'المجيد', 'الباعث', 'الشهيد', 'الحق', 'الوكيل',
      'القوي', 'المتين', 'الولي', 'الحفيظ', 'المحصي', 'الم吉祥', 'السيد',
      'المستعان', 'الصبور', 'المنتقم', 'العفو', 'الراشد', 'الغالب', 'القادر',
      'المقتدر', 'المقدم', 'المؤخر', 'الأول', 'الآخر', 'الظاهر', 'الباطن',
      'الحافظ', 'المقسط', 'المجنّب', 'المانع', 'الضار', 'النافع', 'النور',
      'الهدى', 'البشير', 'النذير', 'العزير', 'الفتح', 'القريب', 'البعيد',
      'الجواد', 'الواجد', 'الماجد', 'الواحد', 'الصمد', 'القادر', 'المعير',
      'المقيل', 'التواب', 'المنتقم', 'العفو', 'الرؤوف', 'مالك الملك', 'ذو الجلال',
    ],
    'colors': {
      'primary': 0xFF1A237E,
      'gold': 0xFFFFD700,
      'surface': 0xFF0D1B2A,
      'onSurface': 0xFFE0E1DD,
    },
  };
}