import 'package:flutter/material.dart';
import '../services/sovereign_security_service.dart';

class SovereignBackupProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String? _backupPath;
  String _message = "";

  bool get isProcessing => _isProcessing;
  String? get backupPath => _backupPath;
  String get message => _message;

  Future<void> createBackup({
    required Map<String, dynamic> data,
    required String bioKey,
  }) async {
    _isProcessing = true;
    _message = "جاري تشفير كتل الوعي...";
    notifyListeners();
    try {
      final file = await SovereignSecurityService.exportEncryptedBackup(
        data: data,
        bioKey: bioKey,
        fileName: "Mudabbir_Ledger_${DateTime.now().millisecondsSinceEpoch}",
      );
      _backupPath = file.path;
      _message = "✅ تم تشفير المخطوطة بنجاح";
    } catch (e) {
      _message = "❌ فشل: $e";
    }
    _isProcessing = false;
    notifyListeners();
  }
}
