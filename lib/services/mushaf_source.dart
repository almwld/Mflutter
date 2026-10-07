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

  static String hizbTextForPage(int page) =>
      getCurrentHizbTextForPage(normalizePage(page), isArabic: true);

  static String verse(int surah, int ayah) =>
      getVerse(surah, ayah, verseEndSymbol: true);

  static int pageForVerse(int surah, int ayah) =>
      getPageNumber(surah, ayah).clamp(1, totalPages).toInt();

  static int firstPageForSurah(int surah) => pageForVerse(surah, 1);

  static int firstPageForJuz(int juz) {
    final target = juz.clamp(1, totalJuz);
    for (var page = 1; page <= totalPages; page++) {
      if (juzForPage(page) == target) return page;
    }
    return 1;
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
    final index = hizb.clamp(1, totalHizb) - 1;
    return index < pages.length ? pages[index] : 1;
  }
}
