/// =============================================================================
/// InputValidator - مُحقق المدخلات
/// =============================================================================
/// يتحقق من صحة المدخلات
/// =============================================================================

class InputValidator {
  InputValidator._();

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من النص
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من أن النص ليس فارغاً
  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  /// التحقق من الحد الأدنى للطول
  static bool hasMinLength(String text, int minLength) {
    return text.trim().length >= minLength;
  }

  /// التحقق من الحد الأقصى للطول
  static bool hasMaxLength(String text, int maxLength) {
    return text.trim().length <= maxLength;
  }

  /// التحقق من الطول
  static bool hasLength(String text, int length) {
    return text.trim().length == length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من النص العربي
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من أن النص عربي فقط
  static bool isArabicOnly(String text) {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return arabicRegex.hasMatch(text.trim());
  }

  /// التحقق من أن النص يحتوي على حروف عربية
  static bool containsArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  /// التحقق من أن النص إنجليزي فقط
  static bool isEnglishOnly(String text) {
    final englishRegex = RegExp(r'^[a-zA-Z\s]+$');
    return englishRegex.hasMatch(text.trim());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من الأرقام
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من أن النص رقم
  static bool isNumeric(String text) {
    return double.tryParse(text) != null;
  }

  /// التحقق من أن النص عدد صحيح
  static bool isInteger(String text) {
    return int.tryParse(text) != null;
  }

  /// التحقق من الرقم الموجب
  static bool isPositive(num value) {
    return value > 0;
  }

  /// التحقق من الرقم السالب
  static bool isNegative(num value) {
    return value < 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من البريد الإلكتروني
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من البريد الإلكتروني
  static bool isEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من عنوان URL
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من عنوان URL
  static bool isUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من رقم الهاتف
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من رقم الهاتف (عربي)
  static bool isPhoneArabic(String phone) {
    final phoneRegex = RegExp(r'^[\d+\-\s()]{8,20}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  /// التحقق من رقم الهاتف السعودي
  static bool isSaudiPhone(String phone) {
    final saudiRegex = RegExp(r'^(?:\\+?966|0)5\d{8}$');
    return saudiRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-()]'), ''));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من تاريخ
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من التاريخ
  static bool isDate(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// التحقق من التاريخ الهجري
  static bool isHijriDate(String date) {
    // تنسيق: YYYY-MM-DD
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) return false;
    final parts = date.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    return year != null && month != null && day != null &&
           year >= 1 && month >= 1 && month <= 12 && day >= 1 && day <= 30;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من الجمل
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من أن النص صالح لحساب الجمل
  static bool isValidForAbjad(String text) {
    return isNotEmpty(text) && containsArabic(text);
  }

  /// التحقق من أن الطول مناسب للجمل
  static bool isAbjadLengthValid(String text, {int maxLength = 100}) {
    return text.trim().length <= maxLength;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // رسائل الخطأ
  // ═══════════════════════════════════════════════════════════════════════════

  /// رسالة الخطأ للحقل الفارغ
  static String emptyFieldError(String fieldName) {
    return 'حقل $fieldName مطلوب';
  }

  /// رسالة الخطأ للحد الأدنى للطول
  static String minLengthError(String fieldName, int minLength) {
    return 'حقل $fieldName يجب أن يكون $minLength أحرف على الأقل';
  }

  /// رسالة الخطأ للحد الأقصى للطول
  static String maxLengthError(String fieldName, int maxLength) {
    return 'حقل $fieldName يجب أن يكون $maxLength أحرف على الأكثر';
  }

  /// رسالة الخطأ للبريد الإلكتروني
  static const String emailError = 'البريد الإلكتروني غير صالح';

  /// رسالة الخطأ لرقم الهاتف
  static const String phoneError = 'رقم الهاتف غير صالح';

  /// رسالة الخطأ لـ URL
  static const String urlError = 'رابط الموقع غير صالح';
}