class QuranicSearchEngine {
  static final Map<String, List<Map<String, String>>> _index = {};
  static bool _ready = false;
  static String normalize(String value) => value.replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '').replaceAll(RegExp(r'[إأآٱ]'), 'ا').replaceAll('ى', 'ي').replaceAll('ة', 'ه').replaceAll(RegExp(r'[ۖۗۚۛۙۜ۞﴿﴾.,،؛:!?]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  static void indexVerses(List<Map<String, String>> verses) {
    if (_ready) return;
    _index.clear();
    for (final verse in verses) {
      for (final word in normalize(verse['text'] ?? '').split(' ').where((w) => w.length >= 2)) {
        _index.putIfAbsent(word, () => <Map<String, String>>[]).add(verse);
      }
    }
    _ready = true;
  }
  static List<Map<String, String>> search(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return const [];
    final words = normalized.split(' ').where((w) => w.length >= 2).toList();
    final scores = <String, int>{};
    final verses = <String, Map<String, String>>{};
    for (final verse in _allIndexedVerses()) {
      final id = (verse['surah'] ?? '') + ':' + (verse['ayah'] ?? '');
      final text = normalize(verse['text'] ?? '');
      final score = words.where(text.contains).length;
      if (score > 0) { scores[id] = score; verses[id] = verse; }
      if (text.contains(normalized)) scores[id] = (scores[id] ?? 0) + 5;
    }
    final ids = scores.keys.toList()..sort((a,b) => scores[b]!.compareTo(scores[a]!));
    return ids.map((id) => verses[id]!).toList();
  }
  static List<Map<String, String>> _allIndexedVerses() {
    final unique = <String, Map<String, String>>{};
    for (final values in _index.values) for (final verse in values) {
      unique[(verse['surah'] ?? '') + ':' + (verse['ayah'] ?? '')] = verse;
    }
    return unique.values.toList();
  }
  static List<Map<String, String>> searchByRoot(String root) {
    final r = normalize(root);
    return _allIndexedVerses().where((v) => normalize(v['text'] ?? '').contains(r)).toList();
  }
  static Map<String, int> getWordFrequency() {
    final freq = <String, int>{};
    for (final entry in _index.entries) freq[entry.key] = entry.value.length;
    return Map.fromEntries(freq.entries.toList()..sort((a,b) => b.value.compareTo(a.value)));
  }
}