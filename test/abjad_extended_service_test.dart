import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/data/abjad_extended_service.dart';

void main() {
  group('AbjadExtendedService', () {
    test('calculates the traditional values for أبجد', () {
      expect(AbjadExtendedService.calculate('أَبْجَد'), 10);
    });

    test('normalizes Arabic alef variants and removes harakat', () {
      expect(AbjadExtendedService.normalize('إِلَى'), 'الي');
      expect(AbjadExtendedService.calculate('إِلَى'), 41);
    });

    test('ignores whitespace and punctuation', () {
      expect(
        AbjadExtendedService.calculate('ابج، د!'),
        AbjadExtendedService.calculate('ابجد'),
      );
    });

    test('returns only recognized Arabic letters from letter analysis', () {
      final letters = AbjadExtendedService.analyzeLetters('ب 12 ج');
      expect(letters.map((entry) => entry.key).toList(), ['ب', 'ج']);
      expect(letters.map((entry) => entry.value).toList(), [2, 3]);
    });
  });
}