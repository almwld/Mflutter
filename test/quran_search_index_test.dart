import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';

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
    'النفقة': ['2:270', '9:121'],
    'الطلاق': ['65:1', '65:2', '65:3', '65:4', '65:5', '65:6', '65:7', '65:8', '65:9', '65:10', '65:11', '65:12'],
    'البعوضة': ['2:26'],
  };

  for (final entry in expected.entries) {
    test('Quran index resolves ' + entry.key, () async {
      final results = await QuranService().search(entry.key, limit: 50);
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
}
