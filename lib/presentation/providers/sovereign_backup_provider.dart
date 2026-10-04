import 'package:flutter/material.dart';
import '../../services/backup_service.dart';

class SovereignBackupProvider extends ChangeNotifier {
  bool _isBackingUp = false;
  String? _lastBackupPath;

  bool get isBackingUp => _isBackingUp;
  String? get lastBackupPath => _lastBackupPath;

  Future<void> createBackup() async {
    _isBackingUp = true;
    notifyListeners();
    
    try {
      _lastBackupPath = await BackupService.createBackup({
        'provider': 'sovereign_backup',
      });
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }
}
