/// =============================================================================
/// StringExtensions - إضافات النصوص
/// =============================================================================
/// إضافات مفيدة للنصوص
/// =============================================================================

extension StringExtensions on String {
  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق
  // ═══════════════════════════════════════════════════════════════════════════

  /// هل النص فارغ؟
  bool get isEmptyOrNull => isEmpty;

  /// هل النص ليس فارغاً؟
  bool get isNotEmptyOrNull => isNotEmpty;

  /// هل النص عربي؟
  bool get isArabic {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return arabicRegex.hasMatch(trim());
  }

  /// هل النص إنجليزي؟
  bool get isEnglish {
    final englishRegex = RegExp(r'^[a-zA-Z\s]+$');
    return englishRegex.hasMatch(trim());
  }

  /// هل يحتوي على أرقام؟
  bool get hasNumbers => contains(RegExp(r'\d'));

  /// هل يحتوي على أحرف خاصة؟
  bool get hasSpecialChars => contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  // ═══════════════════════════════════════════════════════════════════════════
  // المعالجة
  // ═══════════════════════════════════════════════════════════════════════════

  /// إزالة المسافات الزائدة
  String get trimAll => replaceAll(RegExp(r'\s+'), ' ').trim();

  /// إزالة الترقيم
  String get removePunctuation => replaceAll(RegExp(r'[^\w\s]'), '');

  /// إزالة الأرقام
  String get removeNumbers => replaceAll(RegExp(r'\d'), '');

  /// إزالة الأحرف الخاصة
  String get removeSpecialChars => replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '');

  /// تحويل إلى Title Case
  String get toTitleCase {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التقسيم
  // ═══════════════════════════════════════════════════════════════════════════

  /// تقسيم حسب السطر
  List<String> get lines => split('\n');

  /// تقسيم حسب الكلمة
  List<String> get words => split(' ');

  /// تقسيم حسب الجملة
  List<String> get sentences => split(RegExp(r'[.!?]'));

  // ═══════════════════════════════════════════════════════════════════════════
  // الطول
  // ═══════════════════════════════════════════════════════════════════════════

  /// عدد الكلمات
  int get wordCount => trimAll.split(' ').where((w) => w.isNotEmpty).length;

  /// عدد الأحرف (بدون مسافات)
  int get charCountNoSpaces => replaceAll(' ', '').length;

  /// عدد الأسطر
  int get lineCount => lines.length;

  // ═══════════════════════════════════════════════════════════════════════════
  // القطع
  // ═══════════════════════════════════════════════════════════════════════════

  /// قطع النص
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// قطع الكلمات
  String truncateWords(int maxWords, {String suffix = '...'}) {
    final words = this.words;
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$suffix';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التكرار
  // ═══════════════════════════════════════════════════════════════════════════

  /// تكرار النص
  String repeat(int times) {
    return List.generate(times, (_) => this).join();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الحروف
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحرف الأول (capitalized)
  String get firstCharUppercase {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// الحرف الأول (small)
  String get firstCharLowercase {
    if (isEmpty) return this;
    return this[0].toLowerCase() + substring(1);
  }

  /// الحصول على الحروف فقط
  String get lettersOnly => replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF]'), '');

  // ═══════════════════════════════════════════════════════════════════════════
  // الأرقام
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على الأرقام فقط
  String get numbersOnly => replaceAll(RegExp(r'[^0-9]'), '');

  /// تحويل إلى رقم
  int? toIntOrNull => int.tryParse(this);

  /// تحويل إلى double
  double? toDoubleOrNull => double.tryParse(this);

  // ═══════════════════════════════════════════════════════════════════════════
  // الترميز
  // ═══════════════════════════════════════════════════════════════════════════

  /// ترميز Base64
  String get base64Encode {
    final bytes = codeUnits;
    final buffer = StringBuffer();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    for (var i = 0; i < bytes.length; i += 3) {
      final b1 = bytes[i];
      final b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      buffer.write(chars[(b1 >> 2) & 0x3F]);
      buffer.write(chars[((b1 << 4) | (b2 >> 4)) & 0x3F]);
      buffer.write(i + 1 < bytes.length ? chars[((b2 << 2) | (b3 >> 6)) & 0x3F] : '=');
      buffer.write(i + 2 < bytes.length ? chars[b3 & 0x3F] : '=');
    }
    return buffer.toString();
  }
}