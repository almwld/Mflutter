import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<String> createBackup(Map<String, dynamic> data) async {
    final json = jsonEncode({
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    });
    
    final directory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory('${directory.path}/backups');
    await backupDirectory.create(recursive: true);
    final file = File('${backupDirectory.path}/mudabbir_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json, flush: true);
    return file.path;
  }

  static Future<Map<String, dynamic>?> restoreBackup(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return jsonDecode(await file.readAsString());
    }
    return null;
  }
}
