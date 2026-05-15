class AdvancedSearchService {
  static List<Map<String, dynamic>> searchByJummal(List<Map<String, dynamic>> verses, int target) {
    return verses.where((v) => (v['jummal'] ?? 0) == target).toList();
  }

  static List<Map<String, dynamic>> searchByMod19(List<Map<String, dynamic>> verses, int mod) {
    return verses.where((v) => (v['mod19'] ?? 0) == mod).toList();
  }

  static List<Map<String, dynamic>> searchByScience(List<Map<String, dynamic>> verses, String science) {
    return verses.where((v) => (v['sciences'] ?? []).toString().contains(science)).toList();
  }

  static List<Map<String, dynamic>> searchByAttribute(List<Map<String, dynamic>> verses, String attr) {
    return verses.where((v) => (v['attributes'] ?? []).toString().contains(attr)).toList();
  }

  static Map<String, int> getSurahStats(List<Map<String, dynamic>> verses) {
    final stats = <String, int>{};
    for (final v in verses) {
      final surah = 'سورة ${v['surah'] ?? '?'}';
      stats[surah] = (stats[surah] ?? 0) + 1;
    }
    return stats;
  }
}
