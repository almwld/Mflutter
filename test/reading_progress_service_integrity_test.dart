import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/services/reading_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('saved page and progress use the same clamped Quran page', () async {
    await ReadingProgressService.saveLastPage(999);

    expect(await ReadingProgressService.getLastPage(), 604);
    expect(await ReadingProgressService.getPagesRead(), 1);
    expect(
      await ReadingProgressService.getKhatmahProgress(),
      closeTo(1 / 604, 0.000001),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('quran.pages_read'), <String>['604']);
  });

  test('invalid legacy page IDs and duplicates do not inflate khatmah progress', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'quran.pages_read',
      <String>['0', '1', '1', '605', 'not-a-page', '604'],
    );

    expect(await ReadingProgressService.getPagesRead(), 2);
    expect(
      await ReadingProgressService.getKhatmahProgress(),
      closeTo(2 / 604, 0.000001),
    );

    // Saving an already-read valid page also canonicalizes legacy data.
    await ReadingProgressService.saveLastPage(604);
    expect(
      prefs.getStringList('quran.pages_read'),
      <String>['1', '604'],
    );
  });

  test('yesterday streak remains current until a full day is missed', () async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    String key(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBefore = today.subtract(const Duration(days: 2));

    await prefs.setStringList(
      'quran.reading_days',
      <String>[key(yesterday), key(dayBefore)],
    );
    expect(await ReadingProgressService.getCurrentStreak(), 2);

    await prefs.setStringList(
      'quran.reading_days',
      <String>[key(today), key(yesterday), key(dayBefore)],
    );
    expect(await ReadingProgressService.getCurrentStreak(), 3);
  });

  test('out-of-range last-page values and fallbacks are clamped', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran.last_page', -5);
    expect(await ReadingProgressService.getLastPage(), 1);
    await prefs.remove('quran.last_page');
    expect(await ReadingProgressService.getLastPage(fallback: 999), 604);

    await ReadingProgressService.saveLastPage(0);
    expect(await ReadingProgressService.getLastPage(), 1);
    expect(prefs.getStringList('quran.pages_read'), <String>['1']);
  });
}
