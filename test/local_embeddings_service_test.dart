import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/local_embeddings_service.dart';

void main() {
  setUp(LocalEmbeddingsService.clear);

  test('normalized TF-IDF search ranks matching Quran text first', () {
    LocalEmbeddingsService.indexAll(const {
      '2:255': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      '112:1': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      '1:1': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    });

    final results = LocalEmbeddingsService.searchRanked('الله أحد', topK: 3);

    expect(results, isNotEmpty);
    expect(results.first.id, '112:1');
    expect(results.first.score, greaterThan(0));
  });

  test('indexAll replaces old corpus instead of keeping stale documents', () {
    LocalEmbeddingsService.indexAll(const {'old:1': 'كلمة قديمة'});
    LocalEmbeddingsService.indexAll(const {'new:1': 'كلمة جديدة'});

    expect(LocalEmbeddingsService.documentCount, 1);
    expect(LocalEmbeddingsService.searchRanked('قديمة'), isEmpty);
    expect(LocalEmbeddingsService.searchRanked('جديدة').single.id, 'new:1');
  });

  test('empty queries and invalid topK return no results', () {
    LocalEmbeddingsService.indexAll(const {'1:1': 'بسم الله الرحمن الرحيم'});

    expect(LocalEmbeddingsService.searchRanked('   '), isEmpty);
    expect(LocalEmbeddingsService.searchRanked('الله', topK: 0), isEmpty);
  });
}
