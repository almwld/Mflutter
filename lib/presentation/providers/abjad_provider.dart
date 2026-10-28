import 'package:flutter/material.dart';

import '../../domain/entities/abjad_result.dart';
import '../../utils/abjad_constants.dart';

class AbjadProvider extends ChangeNotifier {
  AbjadResult? _lastResult;
  String _inputText = '';

  AbjadResult? get lastResult => _lastResult;
  String get inputText => _inputText;

  void calculateAbjad(String text) {
    _inputText = text;
    var major = 0;
    final letterResults = <LetterResult>[];

    // Use the traditional Abjad table; Unicode code points are not Abjad values.
    for (final letter in text.split('')) {
      final value = AbjadConstants.getValue(letter);
      if (value <= 0) continue;
      major += value;
      letterResults.add(LetterResult(letter: letter, value: value));
    }

    final average = letterResults.isEmpty
        ? 0
        : (major / letterResults.length).round();
    final halfTotal = (major / 2).round();
    final hasLetters = letterResults.isNotEmpty;

    _lastResult = AbjadResult(
      major: major,
      minor: average,
      middle: halfTotal,
      element: hasLetters ? AbjadConstants.getElementByNumber(major) : 'غير محدد',
      planet: hasLetters ? AbjadConstants.getPlanetByNumber(major) : 'غير محدد',
      zodiac: hasLetters ? AbjadConstants.getZodiacByNumber(major) : 'غير محدد',
      divineName: hasLetters
          ? AbjadConstants.getDivineNameByNumber(major)
          : 'غير محدد',
      // No scientifically defined "energy" value is calculated here.
      energy: 0,
      frequency: 0,
      color: 0xFF1A237E,
      letterResults: letterResults,
    );

    notifyListeners();
  }
}
