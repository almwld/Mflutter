import 'package:flutter/material.dart';

class SovereignChatProvider extends ChangeNotifier {
  bool _isEncrypted = false;
  String _sessionKey = '';

  bool get isEncrypted => _isEncrypted;
  String get sessionKey => _sessionKey;

  void enableEncryption() {
    _isEncrypted = true;
    _sessionKey = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    notifyListeners();
  }

  void disableEncryption() {
    _isEncrypted = false;
    _sessionKey = '';
    notifyListeners();
  }
}
