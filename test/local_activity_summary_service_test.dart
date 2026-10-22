import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mudabbir_al_asrar/services/bookmark_service.dart';
import 'package:mudabbir_al_asrar/services/local_activity_summary_service.dart';
import 'package:mudabbir_al_asrar/services/reading_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('summary reports persisted reading pages, reading days and bookmarks', () async {
    await ReadingProgressService.saveLastPage(1);
    await ReadingProgressService.saveLastPage(12);
    await BookmarkService.addBookmark(1, 1, 'بسم الله الرحمن الرحيم');
    await BookmarkService.addBookmark(2, 255, 'الله لا إله إلا هو الحي القيوم');

    const service = LocalActivitySummaryService();
    final summary = await service.load();

    expect(summary.pagesRead, 2);
    expect(summary.readingDays, 1);
    expect(summary.currentStreak, 1);
    expect(summary.bookmarkCount, 2);
    expect(summary.khatmahProgress, closeTo(2 / 604, 0.000001));
  });

  test('empty local storage does not fabricate activity', () async {
    const service = LocalActivitySummaryService();
    final summary = await service.load();

    expect(summary.pagesRead, 0);
    expect(summary.readingDays, 0);
    expect(summary.currentStreak, 0);
    expect(summary.bookmarkCount, 0);
    expect(summary.khatmahProgress, 0);
  });
}
