import 'dart:math' as math;

/// Result from the local lexical retrieval index.
/// Scores are TF-IDF cosine similarities, not neural embeddings or semantic
/// model output; callers should describe this as local text search.
class LocalSearchResult {
  const LocalSearchResult({
    required this.id,
    required this.text,
    required this.score,
  });

  final String id;
  final String text;
  final double score;
}

class LocalEmbeddingsService {
  LocalEmbeddingsService._();

  static final Map<String, String> _texts = <String, String>{};
  static final Map<String, Map<String, double>> _vectors =
      <String, Map<String, double>>{};
  static final Map<String, int> _documentFrequency = <String, int>{};
  static int _indexedDocumentCount = 0;

  static int get documentCount => _texts.length;
  static bool get isIndexed => _texts.isNotEmpty;

  /// Adds/replaces one document and rebuilds the small local index.
  static void indexVerse(String id, String text) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty || text.trim().isEmpty) return;
    _texts[normalizedId] = text;
    _rebuild();
  }

  /// Replaces the current corpus atomically; stale documents from a previous
  /// screen/index are not retained.
  static void indexAll(Map<String, String> documents) {
    final next = <String, String>{};
    for (final entry in documents.entries) {
      final id = entry.key.trim();
      final text = entry.value.trim();
      if (id.isNotEmpty && text.isNotEmpty) next[id] = text;
    }
    _texts
      ..clear()
      ..addAll(next);
    _rebuild();
  }

  static void clear() {
    _texts.clear();
    _vectors.clear();
    _documentFrequency.clear();
    _indexedDocumentCount = 0;
  }

  /// Compatibility helper for existing callers. This is lexical retrieval,
  /// not a claim of neural semantic understanding.
  static List<String> searchSimilar(String query, {int topK = 5}) =>
      searchRanked(query, topK: topK).map((result) => result.text).toList();

  static List<LocalSearchResult> searchRanked(
    String query, {
    int topK = 5,
  }) {
    if (_texts.isEmpty || topK <= 0) return const <LocalSearchResult>[];
    final queryTokens = _tokens(query).toSet();
    if (queryTokens.isEmpty) return const <LocalSearchResult>[];

    final queryVector = _vectorize(queryTokens);
    if (queryVector.isEmpty) return const <LocalSearchResult>[];

    final scored = <LocalSearchResult>[];
    for (final entry in _vectors.entries) {
      final score = _cosineSparse(queryVector, entry.value);
      if (score <= 0) continue;
      final text = _texts[entry.key];
      if (text == null) continue;
      scored.add(LocalSearchResult(id: entry.key, text: text, score: score));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.id.compareTo(b.id);
    });
    return List<LocalSearchResult>.unmodifiable(scored.take(topK));
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    final length = math.min(a.length, b.length);
    for (var i = 0; i < length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  static void _rebuild() {
    _documentFrequency.clear();
    final tokenCountsByDocument = <String, Map<String, int>>{};

    for (final entry in _texts.entries) {
      final counts = <String, int>{};
      for (final token in _tokens(entry.value)) {
        counts.update(token, (count) => count + 1, ifAbsent: () => 1);
      }
      tokenCountsByDocument[entry.key] = counts;
      for (final token in counts.keys) {
        _documentFrequency.update(
          token,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    _indexedDocumentCount = _texts.length;
    _vectors
      ..clear()
      ..addEntries(tokenCountsByDocument.entries.map(
        (entry) => MapEntry(entry.key, _weightedVector(entry.value)),
      ));
  }

  static Map<String, double> _vectorize(Set<String> tokens) {
    final counts = <String, int>{for (final token in tokens) token: 1};
    return _weightedVector(counts);
  }

  static Map<String, double> _weightedVector(Map<String, int> counts) {
    final vector = <String, double>{};
    final documentCount = math.max(1, _indexedDocumentCount == 0
        ? _texts.length
        : _indexedDocumentCount);
    for (final entry in counts.entries) {
      final frequency = entry.value;
      final documentFrequency = _documentFrequency[entry.key] ?? 0;
      if (documentFrequency == 0) continue;
      final termFrequency = 1 + math.log(frequency);
      final inverseDocumentFrequency =
          math.log(1 + documentCount / documentFrequency);
      final weight = termFrequency * inverseDocumentFrequency;
      if (weight > 0 && weight.isFinite) vector[entry.key] = weight;
    }

    var normSquared = 0.0;
    for (final weight in vector.values) {
      normSquared += weight * weight;
    }
    if (normSquared == 0) return vector;
    final norm = math.sqrt(normSquared);
    for (final token in vector.keys.toList()) {
      vector[token] = vector[token]! / norm;
    }
    return vector;
  }

  static double _cosineSparse(
    Map<String, double> a,
    Map<String, double> b,
  ) {
    if (a.isEmpty || b.isEmpty) return 0;
    final smaller = a.length <= b.length ? a : b;
    final larger = identical(smaller, a) ? b : a;
    var dot = 0.0;
    for (final entry in smaller.entries) {
      dot += entry.value * (larger[entry.key] ?? 0);
    }
    // Vectors are normalized at construction time.
    return dot.clamp(0.0, 1.0);
  }

  static List<String> _tokens(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll(RegExp(r'[ؤئ]'), 'ء')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9 ]'), ' ');
    return normalized
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }
}
