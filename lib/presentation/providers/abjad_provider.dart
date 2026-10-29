import 'package:flutter/material.dart';

import '../../core/utils/abjad_calculator.dart' as core;
import '../../domain/entities/abjad_result.dart';
import '../../services/achievements_service.dart';
import '../../utils/abjad_constants.dart';

class AbjadProvider extends ChangeNotifier {
  AbjadResult? _lastResult;
  String _inputText = '';

  AbjadResult? get lastResult => _lastResult;
  String get inputText => _inputText;

  void clear() {
    _inputText = '';
    _lastResult = null;
    notifyListeners();
  }

  void calculateAbjad(String text, {bool alphabetical = false}) {
    _inputText = text;
    final normalized = core.AbjadCalculator.normalizeArabic(text);
    final letterResults = <LetterResult>[];
    var total = 0;

    // The canonical large-Abjad calculator is the default path. The
    // alphabetical mapping remains an explicitly selected, separate convention.
    for (final rune in normalized.runes) {
      final letter = String.fromCharCode(rune);
      final value = alphabetical
          ? AbjadConstants.getAlphabeticalValue(letter)
          : core.AbjadCalculator.kabirValues[letter] ?? 0;
      if (value <= 0) continue;
      total += value;
      letterResults.add(LetterResult(letter: letter, value: value));
    }

    final canonical = alphabetical
        ? null
        : core.AbjadCalculator.calculateAll(normalized);
    final hasLetters = letterResults.isNotEmpty;
    final average = hasLetters ? (total / letterResults.length).round() : 0;

    _lastResult = AbjadResult(
      major: total,
      // In the canonical mode, minor and middle use the shared definitions.
      // The legacy alphabetical mode retains its previous derived values.
      minor: canonical?.saghir ?? average,
      middle: canonical?.wasat ?? (total / 2).round(),
      element: hasLetters
          ? AbjadConstants.getElementByNumber(total)
          : 'غير محدد',
      planet: hasLetters
          ? AbjadConstants.getPlanetByNumber(total)
          : 'غير محدد',
      zodiac: hasLetters
          ? AbjadConstants.getZodiacByNumber(total)
          : 'غير محدد',
      divineName: hasLetters
          ? AbjadConstants.getDivineNameByNumber(total)
          : 'غير محدد',
      // Abjad does not provide a scientifically defined energy or frequency.
      energy: 0,
      frequency: 0,
      color: 0xFF1A237E,
      letterResults: letterResults,
    );

    // Record only a completed, non-empty calculation. Persistence failure
    // must never block the calculator UI.
    if (hasLetters) {
      AchievementsService.recordAbjadCalculation();
    }
    notifyListeners();
  }
}
