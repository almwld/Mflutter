/// =============================================================================
/// Exceptions - الاستثناءات
/// =============================================================================
/// استثناءات مخصصة للتطبيق
/// =============================================================================

/// =============================================================================
/// استثناء قاعدة البيانات
/// =============================================================================
class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const DatabaseException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'DatabaseException: $message';
}

/// =============================================================================
/// استثناء النموذج
/// =============================================================================
class ModelException implements Exception {
  final String message;
  final dynamic originalError;

  const ModelException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ModelException: $message';
}

/// =============================================================================
/// استثناء التخزين
/// =============================================================================
class StorageException implements Exception {
  final String message;
  final dynamic originalError;

  const StorageException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'StorageException: $message';
}

/// =============================================================================
/// استثناء الملف
/// =============================================================================
class FileException implements Exception {
  final String message;
  final dynamic originalError;

  const FileException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'FileException: $message';
}

/// =============================================================================
/// استثناء التحميل
/// =============================================================================
class LoadingException implements Exception {
  final String message;
  final dynamic originalError;

  const LoadingException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'LoadingException: $message';
}

/// =============================================================================
/// استثناء البحث
/// =============================================================================
class SearchException implements Exception {
  final String message;
  final dynamic originalError;

  const SearchException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'SearchException: $message';
}

/// =============================================================================
/// استثناء الحساب
/// =============================================================================
class CalculationException implements Exception {
  final String message;
  final dynamic originalError;

  const CalculationException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'CalculationException: $message';
}

/// =============================================================================
/// استثناء التصريح
/// =============================================================================
class PermissionException implements Exception {
  final String message;
  final dynamic originalError;

  const PermissionException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'PermissionException: $message';
}

/// =============================================================================
/// استثناء التحقق من الإدخال
/// =============================================================================
class ValidationException implements Exception {
  final String message;
  final dynamic originalError;

  const ValidationException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// =============================================================================
/// استثناء الاتصال
/// =============================================================================
class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  const NetworkException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// =============================================================================
/// استثناء التحليل
/// =============================================================================
class AnalysisException implements Exception {
  final String message;
  final dynamic originalError;

  const AnalysisException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AnalysisException: $message';
}

/// =============================================================================
/// استثناء المعالجة
/// =============================================================================
class ProcessingException implements Exception {
  final String message;
  final dynamic originalError;

  const ProcessingException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ProcessingException: $message';
}