import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_source_corrections.dart';

void main() {
  test('only the two confirmed Al-Baqarah references are corrected', () {
    const incorrect = 'ٱلطلق';
    const canonical = 'ٱلطلاق';

    expect(QuranSourceCorrections.correctVerseText(2, 227, incorrect), canonical);
    expect(QuranSourceCorrections.correctVerseText(2, 229, incorrect), canonical);
    expect(QuranSourceCorrections.correctVerseText(2, 228, incorrect), incorrect);
    expect(QuranSourceCorrections.correctVerseText(3, 227, incorrect), incorrect);
  });

  test('surah and Quran map corrections preserve every other verse field', () {
    final sourceVerses = List<dynamic>.generate(
      229,
      (index) => <String, dynamic>{
        'text': 'ٱلطلق',
        'marker': index + 1,
      },
    );
    final corrected = QuranSourceCorrections.correctSurahVerses(2, sourceVerses);

    expect(corrected, hasLength(229));
    expect(corrected[226]['text'], 'ٱلطلاق');
    expect(corrected[226]['marker'], 227);
    expect(corrected[227]['text'], 'ٱلطلق');
    expect(corrected[228]['text'], 'ٱلطلاق');
    expect(sourceVerses[226]['text'], 'ٱلطلق');

    final quran = <String, dynamic>{'2': sourceVerses};
    final correctedQuran = QuranSourceCorrections.correctQuranMap(quran);
    expect(correctedQuran['2'][226]['text'], 'ٱلطلاق');
    expect(quran['2'][226]['text'], 'ٱلطلق');
  });
}
