import 'package:qcf_quran_lite/qcf_quran_lite.dart';

/// مصدر الحقيقة للمصحف داخل التطبيق.
///
/// العرض يعتمد على بيانات QCF Hafs المدمجة مع الحزمة، والتي تمثل
/// مصحف المدينة المنورة ذي 604 صفحات.
class MushafSource {
  const MushafSource._();

  static const int totalPages = 604;
  static const int totalJuz = 30;
  static const int totalHizb = 60;
  static const int totalSurahs = 114;

  static int normalizePage(int page) => page.clamp(1, totalPages).toInt();

  static int juzForPage(int page) =>
      getCurrentJuzNumberForPage(normalizePage(page));

  // Canonical start references for the 30 juz. A page can contain a juz
  // boundary, so verse metadata must be derived from the ayah reference rather
  // than assigning every verse the juz that starts on its page.
  static const List<(int, int)> _juzStarts = <(int, int)>[
    (1, 1), (2, 142), (2, 253), (3, 93), (4, 24),
    (4, 148), (5, 82), (6, 111), (7, 88), (8, 41),
    (9, 93), (11, 6), (12, 53), (15, 1), (17, 1),
    (18, 75), (21, 1), (23, 1), (25, 21), (27, 56),
    (29, 46), (33, 31), (36, 28), (39, 32), (41, 47),
    (46, 1), (51, 31), (58, 1), (67, 1), (78, 1),
  ];

  static int juzForVerse(int surah, int ayah) {
    if (surah < 1 || surah > totalSurahs || ayah < 1) {
      throw ArgumentError('مرجع الآية غير صالح: $surah:$ayah');
    }
    var juz = 1;
    for (var index = 1; index < _juzStarts.length; index++) {
      final start = _juzStarts[index];
      if (surah > start.$1 ||
          (surah == start.$1 && ayah >= start.$2)) {
        juz = index + 1;
      } else {
        break;
      }
    }
    return juz;
  }

  static String hizbTextForPage(int page) =>
      getCurrentHizbTextForPage(normalizePage(page), isArabic: true);

  static String verse(int surah, int ayah) =>
      getVerse(surah, ayah, verseEndSymbol: true);

  static int pageForVerse(int surah, int ayah) =>
      getPageNumber(surah, ayah).clamp(1, totalPages).toInt();

  static int firstPageForSurah(int surah) => pageForVerse(surah, 1);

  static int firstPageForJuz(int juz) {
    final target = juz.clamp(1, totalJuz).toInt();
    final start = _juzStarts[target - 1];
    return pageForVerse(start.$1, start.$2);
  }

  /// يعيد الصفحة الأولى لكل حزب وفق انتقال نص الحزب الذي توفره QCF.
  /// لا يعتمد على بيانات يدوية أو صفحات تقريبية.
  static List<int> firstPagesForHizb() {
    final pages = <int>[1];
    var previous = hizbTextForPage(1);
    for (var page = 2; page <= totalPages; page++) {
      final current = hizbTextForPage(page);
      if (current != previous && current.isNotEmpty) {
        pages.add(page);
        previous = current;
      }
    }
    return pages.take(totalHizb).toList(growable: false);
  }

  static int firstPageForHizb(int hizb) {
    final pages = firstPagesForHizb();
    final index = hizb.clamp(1, totalHizb).toInt() - 1;
    return index < pages.length ? pages[index] : 1;
  }
}
