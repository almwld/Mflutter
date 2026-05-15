import 'package:flutter/material.dart';

class SovereignBackupProvider extends ChangeNotifier {
  bool _isBackingUp = false;
  String? _lastBackupPath;

  bool get isBackingUp => _isBackingUp;
  String? get lastBackupPath => _lastBackupPath;

  Future<void> createBackup() async {
    _isBackingUp = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 2));
    _lastBackupPath = '/backup/mudabbir_${DateTime.now().millisecondsSinceEpoch}.enc';
    _isBackingUp = false;
    notifyListeners();
  }
}
