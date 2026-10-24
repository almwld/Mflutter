import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/smart_lens_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Arabic lens normalization removes harakat and standardizes alif', () {
    expect(
      SmartLensService.normalizeArabic('إِنَّ الْقُرْآنَ'),
      SmartLensService.normalizeArabic('ان القران'),
    );
  });

  test('Quran lens compares OCR against the bundled canonical mushaf', () async {
    final matches = await SmartLensService.instance
        .matchQuranText('بسم الله الرحمن الرحيم');
    expect(matches, isNotEmpty);
    expect(matches.first.surahNumber, 1);
    expect(matches.first.ayahNumber, 1);
    expect(matches.first.score, greaterThanOrEqualTo(0.9));
  });

  test('Quran lens returns no matches for a non-positive limit', () async {
    expect(
      await SmartLensService.instance.matchQuranText(
        'بسم الله الرحمن الرحيم',
        limit: 0,
      ),
      isEmpty,
    );
    expect(
      await SmartLensService.instance.matchQuranText(
        'بسم الله الرحمن الرحيم',
        limit: -1,
      ),
      isEmpty,
    );
  });
}
