import 'package:flutter/material.dart';
import '../../domain/entities/abjad_result.dart';

class AbjadProvider extends ChangeNotifier {
  AbjadResult? _lastResult;
  String _inputText = '';

  AbjadResult? get lastResult => _lastResult;
  String get inputText => _inputText;

  void calculateAbjad(String text) {
    _inputText = text;
    
    // حساب الجمل (نسخة مبسطة)
    int major = 0;
    int minor = 0;
    int middle = 0;
    
    for (final char in text.runes) {
      major += char % 1000;
      minor += char % 100;
      middle += char % 500;
    }
    
    _lastResult = AbjadResult(
      major: major,
      minor: minor,
      middle: middle,
      element: 'نار',
      planet: 'الشمس',
      zodiac: 'الحمل',
      energy: minor / 1000.0,
    );
    
    notifyListeners();
  }
}
