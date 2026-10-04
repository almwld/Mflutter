import 'dart:math';

/// =============================================================================
/// FeatureExtractor - مستخرج الميزات
/// =============================================================================

class FeatureExtractor {
  static const int embeddingSize = 4096;

  /// استخراج الميزات من النص
  List<double> extract(String text) {
    // تطبيع النص
    final normalized = _normalizeText(text);

    // إنشاء التضمين
    final embedding = List<double>.filled(embeddingSize, 0.0);

    // ملء التضمين بناءً على خصائص النص
    _fillEmbeddingFromText(embedding, normalized);

    // تطبيع التضمين
    _normalizeEmbedding(embedding);

    return embedding;
  }

  /// تطبيع النص
  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .toLowerCase()
        .trim();
  }

  /// ملء التضمين من النص
  void _fillEmbeddingFromText(List<double> embedding, String text) {
    if (text.isEmpty) return;

    // Feature hashing حتمي: لا يولّد بيانات عشوائية ولا يدّعي أنه نموذج لغوي.
    // نوزّع أحرف النص وثنائياتها على مساحة ثابتة ثم نطبع المتجه.
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      final index = _hash(code, i, embeddingSize);
      embedding[index] += 1.0;

      if (i + 1 < text.length) {
        final next = text.codeUnitAt(i + 1);
        final pairIndex = _hash(code * 31 + next, i, embeddingSize);
        embedding[pairIndex] += 0.5;
      }
    }

    // إضافة معلومات إضافية
    embedding[0] = text.length / 100.0; // الطول
    embedding[1] = _countUniqueChars(text) / 30.0; // التنوع
    embedding[2] = text.split(' ').length / 20.0; // عدد الكلمات
  }

  int _hash(int value, int position, int size) {
    var hash = 2166136261;
    hash = (hash ^ value) * 16777619;
    hash = (hash ^ position) * 16777619;
    return (hash & 0x7fffffff) % size;
  }

  /// حساب عدد الأحرف الفريدة
  int _countUniqueChars(String text) {
    final chars = <String>{};
    for (final char in text.split('')) {
      chars.add(char);
    }
    return chars.length;
  }

  /// تطبيع التضمين
  void _normalizeEmbedding(List<double> embedding) {
    double sum = 0;
    for (final val in embedding) {
      sum += val * val;
    }
    final magnitude = sqrt(sum);

    if (magnitude > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= magnitude;
      }
    }
  }

  /// تحويل النص إلى ميزات أبجدية
  List<double> extractAbjadFeatures(String text) {
    final features = List<double>.filled(28, 0.0); // 28 حرف عربي

    for (int i = 0; i < text.length && i < 28; i++) {
      final char = text[i];
      features[char.codeUnitAt(0) % 28]++;
    }

    // تطبيع
    final total = features.reduce((a, b) => a + b);
    if (total > 0) {
      for (int i = 0; i < features.length; i++) {
        features[i] /= total;
      }
    }

    return features;
  }

  /// تحويل النص إلى ميزات فورية
  List<double> extractTemporalFeatures(String text) {
    final features = List<double>.filled(10, 0.0);

    // معلومات عامة
    features[0] = text.length / 100.0;
    features[1] = text.split(' ').length / 20.0;
    features[2] = text.split('\n').length / 10.0;

    // معلومات الأبجدية
    features[3] = text.replaceAll(RegExp(r'\s'), '').length / 50.0;

    // معلومات الحروف
    features[4] = text.split('').where((c) => 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي'.contains(c)).length / 50.0;

    // معلومات خاصة
    features[5] = text.contains('الله') ? 1.0 : 0.0;
    features[6] = text.contains('القرآن') ? 1.0 : 0.0;
    features[7] = text.contains('الجمل') ? 1.0 : 0.0;
    features[8] = text.contains('العلم') ? 1.0 : 0.0;
    features[9] = text.contains('الروح') ? 1.0 : 0.0;

    return features;
  }
}