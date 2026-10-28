class QuranicSearchEngine {
  static final Map<String, List<Map<String, String>>> _index = {};
  static List<Map<String, String>> _indexedVerses =
      const <Map<String, String>>[];
  static bool _ready = false;
  static int? _indexSignature;

  /// Search-only normalization. The original Quran text is never modified.
  static String normalize(String value) => value
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[﴿﴾.,،؛:!?؟]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static void indexVerses(List<Map<String, String>> verses) {
    final signature = Object.hashAll(
      verses.map((verse) => Object.hash(
        verse['surah'],
        verse['ayah'],
        verse['text'],
      )),
    );
    if (_ready && _indexSignature == signature) return;

    _index.clear();
    final unique = <String, Map<String, String>>{};
    for (final verse in verses) {
      final id = '${verse['surah'] ?? ''}:${verse['ayah'] ?? ''}';
      unique[id] = Map<String, String>.unmodifiable(verse);
    }
    _indexedVerses = List<Map<String, String>>.unmodifiable(unique.values);

    for (final verse in _indexedVerses) {
      final words = normalize(verse['text'] ?? '')
          .split(' ')
          .where((word) => word.length >= 2);
      for (final word in words) {
        _index.putIfAbsent(word, () => <Map<String, String>>[]).add(verse);
      }
    }

    _indexSignature = signature;
    _ready = true;
  }

  static List<Map<String, String>> search(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty || !_ready) return const [];
    final words = normalized.split(' ').where((word) => word.length >= 2).toList();
    if (words.isEmpty) return const [];

    final scores = <String, int>{};
    final versesById = <String, Map<String, String>>{};
    for (final verse in _indexedVerses) {
      final id = '${verse['surah'] ?? ''}:${verse['ayah'] ?? ''}';
      final text = normalize(verse['text'] ?? '');
      final score = words.where(text.contains).length;
      if (score > 0) {
        scores[id] = score;
        versesById[id] = verse;
      }
      if (text.contains(normalized)) {
        scores[id] = (scores[id] ?? 0) + 5;
        versesById[id] = verse;
      }
    }

    final ids = scores.keys.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    return ids.map((id) => versesById[id]!).toList(growable: false);
  }

  static List<Map<String, String>> searchByRoot(String root) {
    final normalizedRoot = normalize(root);
    if (normalizedRoot.isEmpty || !_ready) return const [];
    return _indexedVerses
        .where((verse) => normalize(verse['text'] ?? '').contains(normalizedRoot))
        .toList(growable: false);
  }

  static Map<String, int> getWordFrequency() {
    final frequencies = <String, int>{
      for (final entry in _index.entries) entry.key: entry.value.length,
    };
    return Map<String, int>.fromEntries(
      frequencies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }
}
