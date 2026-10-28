import 'package:flutter/foundation.dart';

import 'bookmark_service.dart';
import 'reading_progress_service.dart';

/// A truthful, on-device activity summary. It intentionally makes no claims
/// about other users or community-wide activity.
class LocalActivitySummaryService {
  const LocalActivitySummaryService();

  Future<LocalActivitySummary> load() async {
    final warnings = <String>[];
    final results = await Future.wait<Object>(<Future<Object>>[
      _safe(ReadingProgressService.getPagesRead(), 0, 'الصفحات المقروءة', warnings),
      _safe(ReadingProgressService.getReadingDays(), 0, 'أيام القراءة', warnings),
      _safe(ReadingProgressService.getCurrentStreak(), 0, 'سلسلة القراءة', warnings),
      _safe(
        BookmarkService.getBookmarks(),
        const <Map<String, dynamic>>[],
        'العلامات المحفوظة',
        warnings,
      ),
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
      warnings: List<String>.unmodifiable(warnings),
    );
  }

  Future<T> _safe<T>(
    Future<T> source,
    T fallback,
    String label,
    List<String> warnings,
  ) async {
    try {
      return await source;
    } catch (error) {
      debugPrint('LocalActivitySummaryService: $label unavailable: $error');
      warnings.add('تعذر تحميل $label؛ قد تكون قيمة هذا المؤشر غير مكتملة.');
      return fallback;
    }
  }
}

class LocalActivitySummary {
  const LocalActivitySummary({
    required this.pagesRead,
    required this.readingDays,
    required this.currentStreak,
    required this.bookmarkCount,
    this.warnings = const <String>[],
  });

  final int pagesRead;
  final int readingDays;
  final int currentStreak;
  final int bookmarkCount;
  final List<String> warnings;

  double get khatmahProgress => (pagesRead / 604).clamp(0.0, 1.0).toDouble();
}
