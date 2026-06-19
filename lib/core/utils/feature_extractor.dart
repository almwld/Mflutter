import 'dart:math';

/// =============================================================================
/// FeatureExtractor - مستخرج الميزات
/// =============================================================================
/// استخراج ميزات النص للنماذج
/// =============================================================================

class FeatureExtractor {
  FeatureExtractor._();

  // ═══════════════════════════════════════════════════════════════════════════
  // أبعاد الميزات
  // ═══════════════════════════════════════════════════════════════════════════

  /// أبعاد المتجه (4096)
  static const int featureDimension = 4096;

  // ═══════════════════════════════════════════════════════════════════════════
  // استخراج الميزات
  // ═══════════════════════════════════════════════════════════════════════════

  /// استخراج ميزات من النص
  static List<double> extractFeatures(String text) {
    // تنظيف النص
    final cleanedText = _cleanText(text);

    // تحويل إلى أرقام
    final charCodes = _textToCharCodes(cleanedText);

    // إنشاء المتجه
    final features = List<double>.filled(featureDimension, 0.0);

    // ملء المتجه
    _populateFeatures(features, charCodes);

    // تطبيع المتجه
    _normalizeFeatures(features);

    return features;
  }

  /// استخراج ميزات مُحسّنة
  static List<double> extractEnhancedFeatures(String text) {
    final cleanedText = _cleanText(text);
    final charCodes = _textToCharCodes(cleanedText);

    final features = List<double>.filled(featureDimension, 0.0);

    // ميزات الحروف
    _addCharacterFeatures(features, charCodes);

    // ميزات الكلمات
    _addWordFeatures(features, cleanedText);

    // ميزات الأنماط
    _addPatternFeatures(features, cleanedText);

    // ميزات التردد
    _addFrequencyFeatures(features, charCodes);

    // تطبيع
    _normalizeFeatures(features);

    return features;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنظيف النص
  static String _cleanText(String text) {
    // إزالة علامات الترقيم
    var cleaned = text.replaceAll(RegExp(r'[^\u0600-\u06FFa-zA-Z\s]'), '');

    // تحويل إلى صغيرة
    cleaned = cleaned.toLowerCase();

    // إزالة المسافات المتعددة
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  /// تحويل النص إلى أكواد
  static List<int> _textToCharCodes(String text) {
    return text.runes.map((r) => r % 256).toList();
  }

  /// ملء المتجه
  static void _populateFeatures(
    List<double> features,
    List<int> charCodes,
  ) {
    for (int i = 0; i < charCodes.length && i < featureDimension; i++) {
      features[i] = charCodes[i] / 255.0;
    }

    // إضافة ميزات إضافية
    for (int i = charCodes.length; i < min(charCodes.length * 2, featureDimension); i++) {
      if (i < charCodes.length && i > 0) {
        features[i] = (charCodes[i] + charCodes[i - 1]) / 510.0;
      }
    }
  }

  /// إضافة ميزات الحروف
  static void _addCharacterFeatures(
    List<double> features,
    List<int> charCodes,
  ) {
    // تردد الحروف العربية
    final arabicFreq = <int, int>{};
    for (final code in charCodes) {
      arabicFreq[code] = (arabicFreq[code] ?? 0) + 1;
    }

    var index = 0;
    for (final entry in arabicFreq.entries) {
      if (index < 200) {
        features[3000 + index] = entry.value / charCodes.length;
        index++;
      }
    }
  }

  /// إضافة ميزات الكلمات
  static void _addWordFeatures(List<double> features, String text) {
    final words = text.split(' ');
    features[3200] = words.length / 100;

    // أطول كلمة
    var maxLength = 0;
    for (final word in words) {
      if (word.length > maxLength) maxLength = word.length;
    }
    features[3201] = maxLength / 20;

    // متوسط طول الكلمة
    var totalLength = 0;
    for (final word in words) {
      totalLength += word.length;
    }
    features[3202] = words.isEmpty ? 0 : (totalLength / words.length) / 20;
  }

  /// إضافة ميزات الأنماط
  static void _addPatternFeatures(List<double> features, String text) {
    // نمط البداية
    if (text.isNotEmpty) {
      features[3400] = text.runes.first / 4096.0;
    }

    // نمط النهاية
    if (text.isNotEmpty) {
      features[3401] = text.runes.last / 4096.0;
    }

    // نسبة الحروف العربية
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final arabicCount = arabicRegex.allMatches(text).length;
    features[3402] = text.isEmpty ? 0 : arabicCount / text.length;

    // نسبة الحروف الإنجليزية
    final englishRegex = RegExp(r'[a-zA-Z]');
    final englishCount = englishRegex.allMatches(text).length;
    features[3403] = text.isEmpty ? 0 : englishCount / text.length;
  }

  /// إضافة ميزات التردد
  static void _addFrequencyFeatures(
    List<double> features,
    List<int> charCodes,
  ) {
    // التكرار الكلي
    features[3600] = charCodes.length / 1000;

    // القمة
    final freq = <int, int>{};
    for (final code in charCodes) {
      freq[code] = (freq[code] ?? 0) + 1;
    }
    var maxFreq = 0;
    for (final count in freq.values) {
      if (count > maxFreq) maxFreq = count;
    }
    features[3601] = maxFreq / charCodes.length;

    // الانتروبيا
    var entropy = 0.0;
    for (final count in freq.values) {
      final p = count / charCodes.length;
      entropy -= p * log(p) / log(2);
    }
    features[3602] = entropy / 8;
  }

  /// تطبيع المتجه
  static void _normalizeFeatures(List<double> features) {
    // تطبيع L2
    var sum = 0.0;
    for (final f in features) {
      sum += f * f;
    }

    if (sum > 0) {
      final norm = sqrt(sum);
      for (int i = 0; i < features.length; i++) {
        features[i] /= norm;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ميزات إضافية
  // ═══════════════════════════════════════════════════════════════════════════

  /// استخراج ميزات للبحث
  static List<double> extractSearchFeatures(String query) {
    final features = List<double>.filled(512, 0.0);
    final chars = query.runes.toList();

    for (int i = 0; i < chars.length && i < 512; i++) {
      features[i] = chars[i] / 4096.0;
    }

    _normalizeFeatures(features);
    return features;
  }

  /// استخراج ميزات للتصنيف
  static List<double> extractClassificationFeatures(String text) {
    final features = extractFeatures(text);

    // إضافة ميزات التصنيف
    features[4000] = text.length / 1000;
    features[4001] = text.split(' ').length / 100;

    return features;
  }
}