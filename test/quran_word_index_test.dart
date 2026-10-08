import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran word and letter index', () {
    test('indexes Al-Fatiha words with canonical page and juz coordinates',
        () async {
      final words = await QuranWordIndexService.wordsForVerse(1, 1);
      expect(words, isNotEmpty);
      expect(words.map((word) => word.wordNumber).toList(),
          List<int>.generate(words.length, (index) => index + 1));
      expect(words.every((word) => word.surahNumber == 1), isTrue);
      expect(words.every((word) => word.ayahNumber == 1), isTrue);
      expect(words.every((word) => word.pageNumber == 1), isTrue);
      expect(words.every((word) => word.juzNumber == 1), isTrue);
      expect(words.map((word) => word.normalized),
          containsAll(['بسم', 'الله', 'الرحمن', 'الرحيم']));
    });

    test('exact word lookup returns verse and word positions', () async {
      final hits = await QuranWordIndexService.searchWords('الْحَمْدُ');
      expect(hits, isNotEmpty);
      expect(hits.any((word) =>
          word.surahNumber == 1 &&
          word.ayahNumber == 2 &&
          word.normalized == 'الحمد'), isTrue);
      expect(hits.every((word) => word.wordNumber > 0), isTrue);
      expect(hits.every((word) => word.pageNumber >= 1 && word.pageNumber <= 604),
          isTrue);
    });

    test('letter coordinates include an Abjad value and valid location',
        () async {
      final letters = await QuranWordIndexService.lettersForVerse(1, 1);
      expect(letters, isNotEmpty);
      expect(letters.every((letter) => letter.wordNumber > 0), isTrue);
      expect(letters.every((letter) => letter.letterNumber > 0), isTrue);
      expect(letters.every((letter) => letter.pageNumber == 1), isTrue);
      expect(letters.every((letter) => letter.juzNumber == 1), isTrue);
      expect(letters.first.letter, isNotEmpty);
      expect(letters.first.abjadValue, greaterThanOrEqualTo(0));
    });
  });
}
