import 'dart:math';

class LocalEmbeddingsService {
  static final Map<String, List<double>> _verseEmbeddings = {};
  static final Map<String, String> _verseTexts = {};

  static void indexVerse(String id, String text) {
    _verseTexts[id] = text;
    // توليد تضمين بسيط من النص (محاكاة)
    final embedding = List.generate(128, (i) => sin(text.length * (i + 1) * 0.01) * cos(text.codeUnits.fold(0, (a, b) => a + b) * 0.001));
    _verseEmbeddings[id] = embedding;
  }

  static double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i]; normA += a[i] * a[i]; normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  static List<String> searchSimilar(String query, {int topK = 5}) {
    final queryEmbedding = List.generate(128, (i) => sin(query.length * (i + 1) * 0.01));
    final scores = <String, double>{};
    for (final entry in _verseEmbeddings.entries) {
      scores[entry.key] = cosineSimilarity(queryEmbedding, entry.value);
    }
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(topK).map((e) => _verseTexts[e.key] ?? '').toList();
  }
}
