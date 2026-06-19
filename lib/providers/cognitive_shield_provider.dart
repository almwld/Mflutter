import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CognitiveShieldProvider extends ChangeNotifier {
  DateTime? _lastInteraction;
  double _clarity = 1.0;
  bool _shieldActive = false;

  double get clarity => _clarity;
  bool get shieldActive => _shieldActive;

  void registerPulse() {
    final now = DateTime.now();
    if (_lastInteraction != null) {
      final ms = now.difference(_lastInteraction!).inMilliseconds;
      if (ms < 350) {
        _clarity = 0.618;
        _shieldActive = true;
        HapticFeedback.lightImpact();
      } else if (ms > 1500) {
        _clarity = 1.0;
        _shieldActive = false;
      }
      notifyListeners();
    }
    _lastInteraction = now;
  }
}
