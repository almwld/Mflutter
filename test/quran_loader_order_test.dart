import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('canonical Hafs corpus contains 6,236 ordered verses across 114 surahs', () async {
    final ayahs = await QuranLoaderService.loadAllAyahs();
    expect(ayahs, hasLength(QuranLoaderService.expectedAyahCount));
    expect(ayahs.first.surahNumber, 1);
    expect(ayahs.first.ayahNumber, 1);
    expect(ayahs.last.surahNumber, 114);

    for (var i = 1; i < ayahs.length; i++) {
      final previous = ayahs[i - 1];
      final current = ayahs[i];
      if (current.surahNumber == previous.surahNumber) {
        expect(
          current.ayahNumber,
          previous.ayahNumber + 1,
          reason: 'Non-consecutive ayah at index $i',
        );
      } else {
        expect(current.surahNumber, previous.surahNumber + 1);
        expect(current.ayahNumber, 1);
      }
    }
  });
}
