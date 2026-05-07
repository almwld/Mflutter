import 'exceptions.dart';
import 'failures.dart';

/// =============================================================================
/// ErrorHandler - معالج الأخطاء
/// =============================================================================
/// يتعامل مع الأخطاء ويحولها إلى رسائل مناسبة
/// =============================================================================

class ErrorHandler {
  ErrorHandler._();

  // ═══════════════════════════════════════════════════════════════════════════
  // معالجة الاستثناءات
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل استثناء إلى رسالة
  static String handleException(dynamic exception) {
    if (exception is DatabaseException) {
      return 'خطأ في قاعدة البيانات: ${exception.message}';
    } else if (exception is ModelException) {
      return 'خطأ في النموذج: ${exception.message}';
    } else if (exception is StorageException) {
      return 'خطأ في التخزين: ${exception.message}';
    } else if (exception is FileException) {
      return 'خطأ في الملف: ${exception.message}';
    } else if (exception is LoadingException) {
      return 'خطأ في التحميل: ${exception.message}';
    } else if (exception is SearchException) {
      return 'خطأ في البحث: ${exception.message}';
    } else if (exception is CalculationException) {
      return 'خطأ في الحساب: ${exception.message}';
    } else if (exception is PermissionException) {
      return 'خطأ في التصريح: ${exception.message}';
    } else if (exception is ValidationException) {
      return 'خطأ في التحقق: ${exception.message}';
    } else if (exception is NetworkException) {
      return 'خطأ في الاتصال: ${exception.message}';
    } else if (exception is AnalysisException) {
      return 'خطأ في التحليل: ${exception.message}';
    } else if (exception is ProcessingException) {
      return 'خطأ في المعالجة: ${exception.message}';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحويل الاستثناء إلى فشل
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل استثناء إلى فشل
  static Failure exceptionToFailure(dynamic exception) {
    if (exception is DatabaseException) {
      return DatabaseFailure(message: exception.message);
    } else if (exception is ModelException) {
      return ModelFailure(message: exception.message);
    } else if (exception is StorageException) {
      return StorageFailure(message: exception.message);
    } else if (exception is FileException) {
      return FileFailure(message: exception.message);
    } else if (exception is LoadingException) {
      return LoadingFailure(message: exception.message);
    } else if (exception is SearchException) {
      return SearchFailure(message: exception.message);
    } else if (exception is CalculationException) {
      return CalculationFailure(message: exception.message);
    } else if (exception is PermissionException) {
      return PermissionFailure(message: exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is AnalysisException) {
      return AnalysisFailure(message: exception.message);
    } else if (exception is ProcessingException) {
      return ProcessingFailure(message: exception.message);
    } else {
      return UnexpectedFailure(message: exception.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معالجة حالات الفشل
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل فشل إلى رسالة
  static String handleFailure(Failure failure) {
    return failure.errorMessage;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // رسائل الأخطاء المُخصصة
  // ═══════════════════════════════════════════════════════════════════════════

  /// رسالة قاعدة البيانات غير متاحة
  static const String databaseUnavailable =
      'قاعدة البيانات غير متاحة حالياً. يرجى المحاولة لاحقاً.';

  /// رسالة النموذج غير موجود
  static const String modelNotFound =
      'النموذج غير موجود. يرجى التأكد من وجود الملفات.';

  /// رسالة الملف غير موجود
  static const String fileNotFound =
      'الملف غير موجود. يرجى التأكد من المسار.';

  /// رسالة فشل التحميل
  static const String loadingFailed =
      'فشل تحميل البيانات. يرجى المحاولة مرة أخرى.';

  /// رسالة فشل البحث
  static const String searchFailed =
      'فشل البحث. يرجى تعديل كلمات البحث.';

  /// رسالة الحساب غير صالح
  static const String invalidCalculation =
      'حساب غير صالح. يرجى إدخال بيانات صحيحة.';

  /// رسالة التصريح مرفوض
  static const String permissionDenied =
      'التصريح مرفوض. يرجى منح الصلاحيات المطلوبة.';

  /// رسالة التحقق فشل
  static const String validationFailed =
      'فشل التحقق. يرجى إدخال بيانات صحيحة.';

  /// رسالة الاتصال فاشل
  static const String connectionFailed =
      'فشل الاتصال. يرجى التحقق من الاتصال بالإنترنت.';

  /// رسالة المعالجة فاشلة
  static const String processingFailed =
      'فشل المعالجة. يرجى المحاولة مرة أخرى.';

  // ═══════════════════════════════════════════════════════════════════════════
  // معالجة آمنة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنفيذ آمن مع معالجة الأخطاء
  static T executeSafely<T>(
    T Function() action, {
    required T fallback,
    Function(dynamic)? onError,
  }) {
    try {
      return action();
    } catch (e) {
      onError?.call(e);
      return fallback;
    }
  }

  /// تنفيذ async آمن مع معالجة الأخطاء
  static Future<T> executeSafelyAsync<T>(
    Future<T> Function() action, {
    required T fallback,
    Function(dynamic)? onError,
  }) async {
    try {
      return await action();
    } catch (e) {
      onError?.call(e);
      return fallback;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من الأخطاء
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من أن القيمة ليست null
  static T? throwIfNull<T>(T? value, String message) {
    if (value == null) {
      throw LoadingException(message: message);
    }
    return value;
  }

  /// التحقق من أن القائمة ليست فارغة
  static List<T> throwIfEmpty<T>(List<T> list, String message) {
    if (list.isEmpty) {
      throw LoadingException(message: message);
    }
    return list;
  }

  /// التحقق من أن النص ليس فارغاً
  static String throwIfEmptyString(String? value, String message) {
    if (value == null || value.isEmpty) {
      throw ValidationException(message: message);
    }
    return value;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تسجيل الأخطاء
  // ═══════════════════════════════════════════════════════════════════════════

  /// تسجيل خطأ
  static void logError(dynamic error, {String? context}) {
    final timestamp = DateTime.now().toIso8601String();
    final contextInfo = context != null ? ' [$context]' : '';
    print('[$timestamp]$contextInfo Error: $error');
  }

  /// تسجيل تحذير
  static void logWarning(String message, {String? context}) {
    final timestamp = DateTime.now().toIso8601String();
    final contextInfo = context != null ? ' [$context]' : '';
    print('[$timestamp]$contextInfo Warning: $message');
  }
}