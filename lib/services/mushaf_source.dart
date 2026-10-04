import 'package:qcf_quran_lite/qcf_quran_lite.dart';

/// مصدر الحقيقة للمصحف داخل التطبيق.
///
/// العرض يعتمد على بيانات QCF Hafs المدمجة مع الحزمة، والتي تمثل
/// مصحف المدينة المنورة ذي 604 صفحات. لا يعاد توزيع النص حسب طول
/// السطر أو حجم الشاشة.
class MushafSource {
  const MushafSource._();

  static const int totalPages = 604;
  static const int totalJuz = 30;
  static const int totalSurahs = 114;

  static int normalizePage(int page) => page.clamp(1, totalPages);

  static int juzForPage(int page) {
    return getCurrentJuzNumberForPage(normalizePage(page));
  }

  static String verse(int surah, int ayah) {
    return getVerse(surah, ayah, verseEndSymbol: true);
  }

  static int pageForVerse(int surah, int ayah) {
    return getPageNumber(surah, ayah).clamp(1, totalPages);
  }
}
