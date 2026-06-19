import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/quran_page.dart';

class PageBuilderService {
  static Map<int, List<AyahData>>? _cachedPages;

  static Future<Map<int, List<AyahData>>> buildPages() async {
    if (_cachedPages != null) return _cachedPages!;
    final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
    final quran = jsonDecode(jsonStr) as Map<String, dynamic>;

    final pages = <int, List<AyahData>>{};
    int currentPage = 1;
    int lineCount = 0;

    final surahKeys = quran.keys.map((k) => int.parse(k)).toList()..sort();
    for (final surahNum in surahKeys) {
      final verses = quran[surahNum.toString()] as List<dynamic>;
      for (final verse in verses) {
        final text = verse['text'] ?? '';
        final ayahNum = verse['ayah'] ?? 0;
        final int lines = (text.length / 50).ceil().toInt();
        lineCount += lines.toInt();
        if (lineCount >= 15) { currentPage++; lineCount = lines; }
        final ayah = AyahData(ayahNumber: ayahNum, surahNumber: surahNum, text: text, pageNumber: currentPage);
        pages.putIfAbsent(currentPage, () => []);
        pages[currentPage]!.add(ayah);
      }
    }
    _cachedPages = pages;
    return pages;
  }

  static String getSurahName(int n) {
    const names = {1:'الفاتحة',2:'البقرة',36:'يس',55:'الرحمن',67:'الملك',112:'الإخلاص'};
    return names[n] ?? 'سورة $n';
  }

  static int getJuz(int page) {
    if (page <= 21) return 1; if (page <= 41) return 2; if (page <= 61) return 3;
    if (page <= 81) return 4; if (page <= 101) return 5; if (page <= 121) return 6;
    if (page <= 141) return 7; if (page <= 161) return 8; if (page <= 181) return 9;
    if (page <= 201) return 10; if (page <= 221) return 11; if (page <= 241) return 12;
    if (page <= 261) return 13; if (page <= 281) return 14; if (page <= 301) return 15;
    if (page <= 321) return 16; if (page <= 341) return 17; if (page <= 361) return 18;
    if (page <= 381) return 19; if (page <= 401) return 20; if (page <= 421) return 21;
    if (page <= 441) return 22; if (page <= 461) return 23; if (page <= 481) return 24;
    if (page <= 501) return 25; if (page <= 521) return 26; if (page <= 541) return 27;
    if (page <= 561) return 28; if (page <= 581) return 29;
    return 30;
  }
}
