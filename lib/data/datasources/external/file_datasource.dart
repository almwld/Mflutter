import 'dart:io';

/// =============================================================================
/// FileDatasource - مصدر بيانات الملفات
/// =============================================================================

class FileDatasource {
  // ═══════════════════════════════════════════════════════════════════════════
  // قراءة
  // ═══════════════════════════════════════════════════════════════════════════

  /// قراءة ملف نصي
  Future<String> readTextFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      throw FileSystemException('الملف غير موجود: $path');
    } catch (e) {
      throw FileSystemException('خطأ في قراءة الملف: $e');
    }
  }

  /// قراءة ملف ثنائي
  Future<List<int>> readBinaryFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      throw FileSystemException('الملف غير موجود: $path');
    } catch (e) {
      throw FileSystemException('خطأ في قراءة الملف: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // كتابة
  // ═══════════════════════════════════════════════════════════════════════════

  /// كتابة ملف نصي
  Future<File> writeTextFile(String path, String content) async {
    try {
      final file = File(path);
      return await file.writeAsString(content);
    } catch (e) {
      throw FileSystemException('خطأ في كتابة الملف: $e');
    }
  }

  /// كتابة ملف ثنائي
  Future<File> writeBinaryFile(String path, List<int> bytes) async {
    try {
      final file = File(path);
      return await file.writeAsBytes(bytes);
    } catch (e) {
      throw FileSystemException('خطأ في كتابة الملف: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب معلومات الملف
  Future<Map<String, dynamic>> getFileInfo(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final stat = await file.stat();
        return {
          'path': path,
          'exists': true,
          'size': stat.size,
          'modified': stat.modified.toIso8601String(),
          'type': 'file',
        };
      }
      return {'path': path, 'exists': false};
    } catch (e) {
      return {'path': path, 'exists': false, 'error': e.toString()};
    }
  }

  /// التحقق من وجود الملف
  Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }

  /// جلب حجم الملف
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

  // ═══════════════════════════════════════════════════════════════════════════
  // نسخ
  // ═══════════════════════════════════════════════════════════════════════════

  /// نسخ ملف
  Future<File> copyFile(String sourcePath, String destPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        return await sourceFile.copy(destPath);
      }
      throw FileSystemException('الملف المصدر غير موجود');
    } catch (e) {
      throw FileSystemException('خطأ في نسخ الملف: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //列出
  // ═══════════════════════════════════════════════════════════════════════════

  ///列出 الملفات في مجلد
  Future<List<String>> listFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        final entities = await directory.list().toList();
        return entities
            .whereType<File>()
            .map((f) => f.path.split('/').last)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  ///列出 المجلدات في مجلد
  Future<List<String>> listDirectories(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        final entities = await directory.list().toList();
        return entities
            .whereType<Directory>()
            .map((d) => d.path.split('/').last)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}