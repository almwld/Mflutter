import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mudabbir_al_asrar/services/achievements_service.dart';
import 'package:mudabbir_al_asrar/services/bookmark_service.dart';
import 'package:mudabbir_al_asrar/services/daily_streak_service.dart';
import 'package:mudabbir_al_asrar/services/reading_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('measured achievements reflect persisted activity and do not fabricate unlocks', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ReadingProgressService.saveLastPage(1);
    await BookmarkService.addBookmark(1, 1, 'بسم الله الرحمن الرحيم');
    await BookmarkService.addBookmark(1, 2, 'الحمد لله رب العالمين');
    await DailyStreakService.recordActivity();

    await AchievementsService.refreshFromLocalActivity();
    final achievements = {
      for (final item in AchievementsService.achievements) item['id'] as String: item,
    };

    expect(achievements['first_verse']?['progress'], 1.0);
    expect(achievements['first_verse']?['unlocked'], isTrue);
    expect(achievements['ten_verses']?['progress'], closeTo(0.2, 0.000001));
    expect(achievements['ten_verses']?['unlocked'], isFalse);
    expect(achievements['daily_streak_3']?['progress'], closeTo(1 / 3, 0.000001));
    expect(achievements['first_abjad']?['unlocked'], isFalse);
    expect(achievements['first_abjad']?['tracking'], isFalse);
    expect(AchievementsService.unlockedCount, 1);
  });
}
