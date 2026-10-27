import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/text_transformer.dart';

void main() {
  group('TextTransformer dotless display modes', () {
    test('preserves Quranic marks in the marked dotless mode', () {
      expect(TextTransformer.toDotlessPreservingMarks('بَتٌ'), 'ٮَٮٌ');
    });

    test('removes Arabic vowel marks in the plain dotless mode', () {
      expect(TextTransformer.toDotless('بَتٌ'), 'ٮٮ');
    });

    test('does not mutate the source text', () {
      const source = 'بِسْمِ اللَّهِ';
      TextTransformer.toDotlessPreservingMarks(source);
      TextTransformer.toDotless(source);
      expect(source, 'بِسْمِ اللَّهِ');
    });
  });
}
