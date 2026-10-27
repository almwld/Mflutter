import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concurrent callers share one validated Quran corpus result', () async {
    final results = await Future.wait([
      QuranLoaderService.loadAllAyahs(),
      QuranLoaderService.loadAllAyahs(),
      QuranLoaderService.loadAllAyahs(),
    ]);

    expect(results.every((result) => identical(result, results.first)), isTrue);
    expect(results.first, hasLength(QuranLoaderService.expectedAyahCount));
    expect(results.first.first.surahNumber, 1);
    expect(results.first.first.ayahNumber, 1);
    expect(results.first.last.surahNumber, 114);
    expect(results.first.last.ayahNumber, 6);
  });

  test('concurrent callers share one grouped surah map', () async {
    final results = await Future.wait([
      QuranLoaderService.loadBySurah(),
      QuranLoaderService.loadBySurah(),
      QuranLoaderService.loadBySurah(),
    ]);

    expect(results.every((result) => identical(result, results.first)), isTrue);
    expect(results.first, hasLength(114));
    expect(
      results.first.values.fold<int>(0, (total, ayahs) => total + ayahs.length),
      QuranLoaderService.expectedAyahCount,
    );
    expect(results.first[1], hasLength(7));
    expect(results.first[114], hasLength(6));
  });
}
