import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mudabbir_al_asrar/services/daily_streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('streak persists and repeated visits in one day count only once', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await DailyStreakService.initialize();
    expect(DailyStreakService.streak, 0);

    await DailyStreakService.recordActivity();
    expect(DailyStreakService.streak, 1);

    await DailyStreakService.recordActivity();
    expect(DailyStreakService.streak, 1);
    expect(DailyStreakService.weekHistory, hasLength(7));
    expect(DailyStreakService.weekHistory.last, isTrue);

    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList('reading_streak.active_dates.v1');
    expect(dates, hasLength(1));
  });
}
