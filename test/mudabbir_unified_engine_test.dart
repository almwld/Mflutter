import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/mudabbir_unified_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MudabbirUnifiedEngine engine;

  setUp(() {
    engine = MudabbirUnifiedEngine();
  });

  group('Mudabbir unified offline engine', () {
    test('rejects empty input without fabricating evidence', () async {
      final result = await engine.analyze('   ');
      expect(result.mode, MudabbirEngineMode.empty);
      expect(result.hasEvidence, isFalse);
    });

    test('resolves a canonical verse reference with source text and coordinates', () async {
      final result = await engine.analyze('1:1');
      expect(result.mode, MudabbirEngineMode.verseReference);
      expect(result.verses, hasLength(1));
      expect(result.verses.single.reference, '1:1');
      expect(result.verses.single.text, isNotEmpty);
      expect(result.verses.single.pageNumber, inInclusiveRange(1, 604));
      expect(result.verses.single.juzNumber, inInclusiveRange(1, 30));
    });

    test('calculates Abjad as explicit letter arithmetic', () async {
      final result = await engine.analyze('أبجد: أب');
      expect(result.mode, MudabbirEngineMode.abjad);
      expect(result.letters.map((entry) => entry.value).toList(), [1, 2]);
      expect(result.totalAbjad, 3);
    });

    test('returns source word occurrences with verse references', () async {
      final result = await engine.analyze('الذباب');
      expect(result.mode, MudabbirEngineMode.wordOccurrences);
      expect(result.words, isNotEmpty);
      expect(result.words.any((entry) => entry.reference == '22:73'), isTrue);
      expect(result.words.every((entry) => entry.sourceText.isNotEmpty), isTrue);
    });

    test('does not rewrite source spelling through broad الطلق/الطلاق aliasing', () async {
      final result = await engine.analyze('الطلاق');
      expect(result.mode, MudabbirEngineMode.wordOccurrences);
      expect(
        result.words.any((entry) => entry.reference == '2:227' && entry.sourceText.contains('الطلق')),
        isFalse,
      );
    });
  });
}
