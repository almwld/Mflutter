import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// =============================================================================
/// FileUtils - أدوات الملفات
/// =============================================================================
/// عمليات الملفات والمجلدات
/// =============================================================================

class FileUtils {
  FileUtils._();

  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق من وجود الملف
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من وجود ملف
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// التحقق من وجود مجلد
  static Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إنشاء الملفات والمجلدات
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء مجلد
  static Future<Directory> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      return await directory.create(recursive: true);
    }
    return directory;
  }

  /// إنشاء ملف
  static Future<File> createFile(String path, {String? content}) async {
    final file = File(path);
    if (content != null) {
      return await file.writeAsString(content);
    }
    return file;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // قراءة وكتابة الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  /// قراءة ملف كنص
  static Future<String> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    throw FileSystemException('الملف غير موجود: $path');
  }

  /// كتابة نص في ملف
  static Future<File> writeFile(String path, String content) async {
    final file = File(path);
    return await file.writeAsString(content);
  }

  /// قراءة ملف كـ bytes
  static Future<List<int>> readBytes(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    throw FileSystemException('الملف غير موجود: $path');
  }

  /// كتابة bytes في ملف
  static Future<File> writeBytes(String path, List<int> bytes) async {
    final file = File(path);
    return await file.writeAsBytes(bytes);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حذف الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  /// حذف ملف
  static Future<bool> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// حذف مجلد
  static Future<bool> deleteDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // نسخ الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  /// نسخ ملف
  static Future<File> copyFile(String sourcePath, String destPath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('الملف المصدر غير موجود: $sourcePath');
    }
    return await sourceFile.copy(destPath);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات الملف
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على حجم الملف
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// الحصول على تاريخ التعديل
  static Future<DateTime?> getLastModified(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.lastModified();
    }
    return null;
  }

  /// الحصول على اسم الملف
  static String getFileName(String path) {
    return path.split('/').last;
  }

  /// الحصول على امتداد الملف
  static String getFileExtension(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // مجلدات خاصة
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على مجلد المستندات
  static Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// الحصول على مجلد التحميلات
  static Future<String> getDownloadsPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    }
    return (await getTemporaryDirectory()).path;
  }

  /// الحصول على مجلد مؤقت
  static Future<String> getTempPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // سرد الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  ///列出 مجلد
  static Future<List<FileSystemEntity>> listDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      return await directory.list().toList();
    }
    return [];
  }

  ///列出 ملفات مجلد
  static Future<List<File>> listFiles(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      return await directory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
    }
    return [];
  }

  ///列出 مجلدات فرعية
  static Future<List<Directory>> listSubdirectories(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      return await directory
          .list()
          .where((entity) => entity is Directory)
          .cast<Directory>()
          .toList();
    }
    return [];
  }
}

/// =============================================================================
/// تنسيق حجم الملف
/// =============================================================================

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}