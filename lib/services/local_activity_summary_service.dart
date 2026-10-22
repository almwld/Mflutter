import '../services/bookmark_service.dart';
import '../services/reading_progress_service.dart';

/// A truthful, on-device activity summary. It intentionally makes no claims
/// about other users or community-wide activity.
class LocalActivitySummaryService {
  const LocalActivitySummaryService();

  Future<LocalActivitySummary> load() async {
    final results = await Future.wait<Object>(<Future<Object>>[
      ReadingProgressService.getPagesRead(),
      ReadingProgressService.getReadingDays(),
      ReadingProgressService.getCurrentStreak(),
      BookmarkService.getBookmarks(),
    ]);
    final pagesRead = results[0] as int;
    final readingDays = results[1] as int;
    final currentStreak = results[2] as int;
    final bookmarks = results[3] as List<Map<String, dynamic>>;
    return LocalActivitySummary(
      pagesRead: pagesRead,
      readingDays: readingDays,
      currentStreak: currentStreak,
      bookmarkCount: bookmarks.length,
    );
  }
}

class LocalActivitySummary {
  const LocalActivitySummary({
    required this.pagesRead,
    required this.readingDays,
    required this.currentStreak,
    required this.bookmarkCount,
  });

  final int pagesRead;
  final int readingDays;
  final int currentStreak;
  final int bookmarkCount;

  double get khatmahProgress => (pagesRead / 604).clamp(0.0, 1.0);
}
