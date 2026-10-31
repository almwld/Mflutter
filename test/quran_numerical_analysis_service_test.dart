import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_numerical_analysis_service.dart';

void main() {
  test('counts normalized tokens from the supplied dataset', () {
    final result = QuranNumericalAnalysisService.analyzeJson(jsonEncode({
      '1': [
        {'text': 'نور علم'},
        {'text': 'نور'},
      ],
    }));

    expect(result.surahCount, 1);
    expect(result.verseCount, 2);
    expect(result.wordCount, 3);
    expect(result.countWord('نور'), 2);
    expect(result.countWord('علم'), 1);
  });

  test('normalizes diacritics and common alif variants before counting', () {
    final result = QuranNumericalAnalysisService.analyzeJson(jsonEncode({
      '1': [
        {'text': 'ٱللَّهِ'},
        {'text': 'الله'},
        {'text': 'أَللَّهُ'},
      ],
    }));

    expect(result.countWord('الله'), 3);
    expect(
      QuranNumericalAnalysisService.tokenize('الرَّحْمَٰنُ'),
      equals(<String>['الرحمن']),
    );
  });

  test('rejects JSON without any verse text', () {
    expect(
      () => QuranNumericalAnalysisService.analyzeJson('{"1": []}'),
      throwsFormatException,
    );
  });
}
