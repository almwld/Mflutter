import 'dart:convert';
import 'dart:io';

class BackupService {
  static Future<String> createBackup(Map<String, dynamic> data) async {
    final json = jsonEncode({
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
    
    final path = '/storage/emulated/0/Download/mudabbir_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    await File(path).writeAsString(json);
    return path;
  }

  static Future<Map<String, dynamic>?> restoreBackup(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return jsonDecode(await file.readAsString());
    }
    return null;
  }
}
