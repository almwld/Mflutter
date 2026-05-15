class QuranicSearchEngine {
  static final Map<String, List<Map<String, String>>> _index = {};

  static void indexVerses(List<Map<String, String>> verses) {
    for (final verse in verses) {
      final words = (verse['text'] ?? '').split(' ');
      for (final word in words) {
        if (word.length > 2) {
          _index.putIfAbsent(word, () => []);
          _index[word]!.add(verse);
        }
      }
    }
  }

  static List<Map<String, String>> search(String query) {
    final words = query.split(' ').where((w) => w.length > 2).toList();
    final results = <Map<String, String>>[];
    for (final word in words) {
      if (_index.containsKey(word)) {
        results.addAll(_index[word]!);
      }
    }
    return results.toSet().toList();
  }

  static List<Map<String, String>> searchByRoot(String root) {
    final results = <Map<String, String>>[];
    for (final entry in _index.entries) {
      if (entry.key.contains(root)) {
        results.addAll(entry.value);
      }
    }
    return results.toSet().toList();
  }

  static Map<String, int> getWordFrequency() {
    final freq = <String, int>{};
    for (final entry in _index.entries) {
      freq[entry.key] = entry.value.length;
    }
    return freq;
  }
}
