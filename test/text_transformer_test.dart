import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/text_transformer.dart';

void main() {
  group('TextTransformer', () {
    test('Kufic presentation preserves canonical Arabic text', () {
      const source = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      expect(TextTransformer.transform(source, 'kufi'), source);
    });

    test('dotless mode remains a separate explicit transformation', () {
      expect(TextTransformer.transform('بسم', 'dotless'), isNot('بسم'));
    });

    test('unknown modes preserve source text', () {
      const source = 'ٱلْحَمْدُ لِلَّٰهِ';
      expect(TextTransformer.transform(source, 'unknown'), source);
    });

    test('marked dotless mode preserves vowel and Quranic annotation marks', () {
      const source = 'بَتٌۢ';
      expect(TextTransformer.toDotlessPreservingMarks(source), 'ٮَٮٌۢ');
      expect(source, 'بَتٌۢ');
    });

    test('plain dotless mode removes presentation marks without mutating source', () {
      const source = 'بَتٌۢ';
      expect(TextTransformer.toDotless(source), 'ٮٮ');
      expect(source, 'بَتٌۢ');
    });
  });
}
