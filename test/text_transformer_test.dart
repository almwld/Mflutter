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
  });
}
