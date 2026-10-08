import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, List<String>>{
    'القردة': ['2:65', '5:60', '7:166'],
    'الذباب': ['22:73'],
    'اليقطين': ['37:146'],
    'الزقوم': ['37:62', '44:43', '56:52'],
    'الضريع': ['88:6'],
    'السعير': ['22:4', '31:21', '34:12', '35:6', '42:7', '67:5', '67:10', '67:11'],
    'الأذن': ['5:45'],
    'الحلم': ['24:58', '24:59'],
    'نفقة': ['2:270', '9:121'],
    'الطلاق': ['2:227', '2:229'],
    'البعوضة': ['2:26'],
  };

  for (final entry in expected.entries) {
    test('Quran index resolves ' + entry.key, () async {
      final results = await QuranWordIndexService.searchWords(entry.key);
      final refs = results.map((v) => v.surahNumber.toString() + ':' + v.ayahNumber.toString()).toList();
      expect(refs, entry.value);
      for (final verse in results) {
        expect(verse.surahNumber, inInclusiveRange(1, 114));
        expect(verse.ayahNumber, greaterThanOrEqualTo(1));
        expect(verse.surahName, isNotEmpty);
        expect(verse.text, isNotEmpty);
      }
    });
  }

  test('phrase search recognizes whitespace-separated Arabic words', () async {
    final results = await QuranService().search('الحمد لله رب العالمين', limit: 20);
    expect(
      results.any((verse) => verse.surahNumber == 1 && verse.ayahNumber == 2),
      isTrue,
    );
  });

}
