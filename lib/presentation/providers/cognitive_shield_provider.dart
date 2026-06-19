import 'package:flutter/material.dart';

class CognitiveShieldProvider extends ChangeNotifier {
  bool _shieldActive = false;
  double _shieldStrength = 0.0;

  bool get shieldActive => _shieldActive;
  double get shieldStrength => _shieldStrength;

  void activateShield() {
    _shieldActive = true;
    _shieldStrength = 1.0;
    notifyListeners();
  }

  void deactivateShield() {
    _shieldActive = false;
    _shieldStrength = 0.0;
    notifyListeners();
  }
}
