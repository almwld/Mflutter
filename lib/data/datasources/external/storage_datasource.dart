import 'dart:io';
import '../../../core/constants/app_urls.dart';
import '../../../core/error/exceptions.dart';

/// =============================================================================
/// StorageDatasource - مصدر بيانات التخزين الخارجي
/// =============================================================================

class StorageDatasource {
  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق من وجود مسار التخزين
  Future<bool> checkStorageExists() async {
    final directory = Directory(AppURLs.modelsPath);
    return await directory.exists();
  }

  /// التحقق من وجود ملف النواة
  Future<bool> checkNucleusExists() async {
    final file = File(AppURLs.nucleusFilePath);
    return await file.exists();
  }

  /// التحقق من وجود قاعدة البيانات
  Future<bool> checkDatabaseExists() async {
    final file = File(AppURLs.databaseFilePath);
    return await file.exists();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // قراءة الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  /// قراءة ملف النواة
  Future<Map<String, dynamic>> readNucleus() async {
    try {
      final file = File(AppURLs.nucleusFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        // محاكاة تحليل JSON
        return {
          'version': '1.0.0',
          'data': content,
          'loadedAt': DateTime.now().toIso8601String(),
        };
      }
      throw const StorageException(message: 'ملف النواة غير موجود');
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  /// قراءة ملف كـ bytes
  Future<List<int>> readFileBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      throw const StorageException(message: 'الملف غير موجود');
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  /// قراءة ملف كـ نص
  Future<String> readFileText(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      throw const StorageException(message: 'الملف غير موجود');
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الكتابة
  // ═══════════════════════════════════════════════════════════════════════════

  /// كتابة ملف
  Future<File> writeFile(String path, String content) async {
    try {
      final file = File(path);
      return await file.writeAsString(content);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  /// كتابة bytes
  Future<File> writeFileBytes(String path, List<int> bytes) async {
    try {
      final file = File(path);
      return await file.writeAsBytes(bytes);
    } catch (e) {
      throw StorageException(message: e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات الملفات
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على حجم الملف
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// الحصول على تاريخ التعديل
  Future<DateTime?> getLastModified(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.lastModified();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  ///列出 الملفات
  Future<List<String>> listFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        final files = await directory.list().toList();
        return files
            .whereType<File>()
            .map((f) => f.path.split('/').last)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حذف
  // ═══════════════════════════════════════════════════════════════════════════

  /// حذف ملف
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// حذف مجلد
  Future<bool> deleteDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}