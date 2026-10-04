/// =============================================================================
/// Failures - حالات الفشل
/// =============================================================================
/// حالات الفشل في التطبيق (بديل للـ exceptions لنمط functional)
/// =============================================================================

/// =============================================================================
/// فشل قاعدة البيانات
/// =============================================================================
class DatabaseFailure extends Failure {
  final String message;

  const DatabaseFailure({required this.message});

  @override
  String get errorMessage => 'فشل في قاعدة البيانات: $message';
}

/// =============================================================================
/// فشل النموذج
/// =============================================================================
class ModelFailure extends Failure {
  final String message;

  const ModelFailure({required this.message});

  @override
  String get errorMessage => 'فشل في النموذج: $message';
}

/// =============================================================================
/// فشل التخزين
/// =============================================================================
class StorageFailure extends Failure {
  final String message;

  const StorageFailure({required this.message});

  @override
  String get errorMessage => 'فشل في التخزين: $message';
}

/// =============================================================================
/// فشل الملف
/// =============================================================================
class FileFailure extends Failure {
  final String message;

  const FileFailure({required this.message});

  @override
  String get errorMessage => 'فشل في الملف: $message';
}

/// =============================================================================
/// فشل التحميل
/// =============================================================================
class LoadingFailure extends Failure {
  final String message;

  const LoadingFailure({required this.message});

  @override
  String get errorMessage => 'فشل في التحميل: $message';
}

/// =============================================================================
/// فشل البحث
/// =============================================================================
class SearchFailure extends Failure {
  final String message;

  const SearchFailure({required this.message});

  @override
  String get errorMessage => 'فشل في البحث: $message';
}

/// =============================================================================
/// فشل الحساب
/// =============================================================================
class CalculationFailure extends Failure {
  final String message;

  const CalculationFailure({required this.message});

  @override
  String get errorMessage => 'فشل في الحساب: $message';
}

/// =============================================================================
/// فشل التصريح
/// =============================================================================
class PermissionFailure extends Failure {
  final String message;

  const PermissionFailure({required this.message});

  @override
  String get errorMessage => 'فشل في التصريح: $message';
}

/// =============================================================================
/// فشل التحقق
/// =============================================================================
class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure({required this.message});

  @override
  String get errorMessage => 'فشل في التحقق: $message';
}

/// =============================================================================
/// فشل الاتصال
/// =============================================================================
class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({required this.message});

  @override
  String get errorMessage => 'فشل في الاتصال: $message';
}

/// =============================================================================
/// فشل التحليل
/// =============================================================================
class AnalysisFailure extends Failure {
  final String message;

  const AnalysisFailure({required this.message});

  @override
  String get errorMessage => 'فشل في التحليل: $message';
}

/// =============================================================================
/// فشل المعالجة
/// =============================================================================
class ProcessingFailure extends Failure {
  final String message;

  const ProcessingFailure({required this.message});

  @override
  String get errorMessage => 'فشل في المعالجة: $message';
}

/// =============================================================================
/// فئة الفشل الأساسية
/// =============================================================================
abstract class Failure {
  String get errorMessage;

  @override
  String toString() => errorMessage;
}

/// =============================================================================
/// فشل غير متوقع
/// =============================================================================
class UnexpectedFailure extends Failure {
  final String message;

  const UnexpectedFailure({required this.message});

  @override
  String get errorMessage => 'خطأ غير متوقع: $message';
}

/// =============================================================================
/// فشل البيانات الفارغة
/// =============================================================================
class EmptyDataFailure extends Failure {
  const EmptyDataFailure();

  @override
  String get errorMessage => 'البيانات فارغة';
}

/// =============================================================================
/// فشل البيانات غير موجودة
/// =============================================================================
class NotFoundFailure extends Failure {
  final String item;

  const NotFoundFailure({required this.item});

  @override
  String get errorMessage => 'لم يتم العثور على: $item';
}