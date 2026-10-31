import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';
import 'quran_word_index_service.dart';

/// Deterministic offline coordinator, not a trained language model or tafsir engine.
class MudabbirUnifiedEngine {
  static final RegExp _marks = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]');
  static final RegExp _arabicWord = RegExp(r'^[ء-يٱ]+$');
  static final RegExp _reference = RegExp(r'^\s*(\d{1,3})\s*[:/]\s*(\d{1,3})\s*$');
  static final RegExp _abjadCommand = RegExp(r'^\s*(?:أبجد|الجمل|حساب الحروف)\s*[:：]\s*(.+)$');

  static const Map<String, int> _abjad = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'ة': 5, 'و': 6, 'ؤ': 6,
    'ز': 7, 'ح': 8, 'ط': 9, 'ي': 10, 'ى': 10, 'ئ': 10,
    'ك': 20, 'ل': 30, 'م': 40, 'ن': 50, 'س': 60, 'ع': 70,
    'ف': 80, 'ص': 90, 'ق': 100, 'ر': 200, 'ش': 300,
    'ت': 400, 'ث': 500, 'خ': 600, 'ذ': 700, 'ض': 800,
    'ظ': 900, 'غ': 1000,
  };

  static const String limitation =
      'هذه نتيجة بحث أو حساب حرفي محلي، وليست تفسيرًا شرعيًا أو إثباتًا لعلاقة علمية.';

  /// Accepts a verse reference (2:255), Abjad command (أبجد: نص),
  /// a single Arabic word, or a phrase from the source Quran text.
  Future<MudabbirUnifiedResult> analyze(String input, {int limit = 50}) async {
    final query = input.trim();
    if (query.isEmpty || limit < 1) {
      return MudabbirUnifiedResult(
        query: query,
        mode: MudabbirEngineMode.empty,
        summary: query.isEmpty ? 'أدخل كلمة أو عبارة أو مرجع آية.' : 'عدد النتائج يجب أن يكون أكبر من صفر.',
      );
    }

    final ref = _reference.firstMatch(query);
    if (ref != null) {
      final surah = int.parse(ref.group(1)!);
      final number = int.parse(ref.group(2)!);
      if (surah < 1 || surah > 114 || number < 1) {
        return MudabbirUnifiedResult(query: query, mode: MudabbirEngineMode.verseReference, summary: 'مرجع الآية خارج النطاق الصحيح.');
      }
      final grouped = await QuranLoaderService.loadBySurah();
      final candidates = grouped[surah]?.where((a) => a.ayahNumber == number).toList() ?? <Ayah>[];
      if (candidates.isEmpty) {
        return MudabbirUnifiedResult(query: query, mode: MudabbirEngineMode.verseReference, summary: 'لم يُعثر على الآية في مصدر المصحف المحلي.');
      }
      return MudabbirUnifiedResult(
        query: query,
        mode: MudabbirEngineMode.verseReference,
        summary: 'تم العثور على الآية في مصدر المصحف المحلي.',
        verses: [MudabbirVerseEvidence.fromAyah(candidates.first)],
      );
    }

    final abjadMatch = _abjadCommand.firstMatch(query);
    if (abjadMatch != null) {
      final letters = <MudabbirLetterValue>[];
      for (final char in abjadMatch.group(1)!.trim().split('')) {
        if (_marks.hasMatch(char) || char == 'ـ') continue;
        final value = _abjad[char];
        if (value != null) letters.add(MudabbirLetterValue(letter: char, value: value));
      }
      final total = letters.fold<int>(0, (sum, item) => sum + item.value);
      return MudabbirUnifiedResult(
        query: query,
        mode: MudabbirEngineMode.abjad,
        summary: letters.isEmpty ? 'لم يتم العثور على حروف عربية قابلة للحساب.' : 'حُسبت قيمة الحروف وفق جدول أبجد المعلن في التطبيق.',
        letters: List.unmodifiable(letters),
        totalAbjad: total,
      );
    }

    if (_arabicWord.hasMatch(_normalizeWord(query))) {
      final allWords = await QuranWordIndexService.loadWords();
      final needle = _normalizeWord(query);
      final withoutArticle = needle.startsWith('ال') && needle.length > 2 ? needle.substring(2) : needle;
      final keepHamzaStem = RegExp(r'^ال[أإآ]').hasMatch(query);
      final words = allWords.where((entry) {
        // Match the source token after mark removal; never rewrite Quran spelling.
        final source = _normalizeWord(entry.text);
        if (source == needle) return true;
        if (!keepHamzaStem && source == withoutArticle) return true;
        final lexical = _stripPrefixes(source);
        if (lexical == needle) return true;
        return !keepHamzaStem && lexical.startsWith('ال') && lexical.substring(2) == withoutArticle;
      }).take(limit).map(MudabbirWordEvidence.fromEntry).toList(growable: false);
      return MudabbirUnifiedResult(
        query: query,
        mode: MudabbirEngineMode.wordOccurrences,
        summary: words.isEmpty ? 'لا توجد مطابقة حرفية للكلمة في فهرس المصحف المحلي.' : 'عُثر على ' + words.length.toString() + ' موضع مطابق في فهرس الكلمات.',
        words: words,
      );
    }

    final needle = _normalizePhrase(query);
    if (needle.isEmpty) {
      return MudabbirUnifiedResult(query: query, mode: MudabbirEngineMode.verseSearch, summary: 'لم تتضمن عبارة البحث حروفًا قابلة للبحث.');
    }
    final ayahs = await QuranLoaderService.loadAllAyahs();
    final matches = ayahs.where((a) => _normalizePhrase(a.text).contains(needle))
        .take(limit).map(MudabbirVerseEvidence.fromAyah).toList(growable: false);
    return MudabbirUnifiedResult(
      query: query,
      mode: MudabbirEngineMode.verseSearch,
      summary: matches.isEmpty ? 'لم يُعثر على العبارة في نص المصحف المحلي.' : 'عُثر على ' + matches.length.toString() + ' آية تحتوي على العبارة المطلوبة.',
      verses: matches,
    );
  }

  static String _normalizeWord(String value) => value
      .replaceAll('ٰ', 'ا').replaceAll(_marks, '').replaceAll('ـ', '').replaceAll('ٱ', 'ا').trim();

  static String _normalizePhrase(String value) => value
      .replaceAll('ٰ', 'ا').replaceAll(_marks, '').replaceAll('ـ', '')
      .replaceAll('ٱ', 'ا').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _stripPrefixes(String token) {
    if (token.startsWith('لل') && token.length > 2) return 'ال' + token.substring(2);
    if (token.length > 3 &&
        const ['و', 'ف', 'ب', 'ك', 'ل'].any((p) => token.startsWith(p) && token.substring(1).startsWith('ال'))) {
      return token.substring(1);
    }
    return token;
  }
}

enum MudabbirEngineMode { empty, verseReference, abjad, wordOccurrences, verseSearch }

class MudabbirUnifiedResult {
  final String query;
  final MudabbirEngineMode mode;
  final String summary;
  final List<MudabbirVerseEvidence> verses;
  final List<MudabbirWordEvidence> words;
  final List<MudabbirLetterValue> letters;
  final int? totalAbjad;

  const MudabbirUnifiedResult({
    required this.query,
    required this.mode,
    required this.summary,
    this.verses = const [],
    this.words = const [],
    this.letters = const [],
    this.totalAbjad,
  });

  bool get hasEvidence => verses.isNotEmpty || words.isNotEmpty || letters.isNotEmpty;
}

class MudabbirVerseEvidence {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final int pageNumber;
  final int juzNumber;
  final String text;

  const MudabbirVerseEvidence({
    required this.surahNumber, required this.surahName, required this.ayahNumber,
    required this.pageNumber, required this.juzNumber, required this.text,
  });

  factory MudabbirVerseEvidence.fromAyah(Ayah a) => MudabbirVerseEvidence(
    surahNumber: a.surahNumber, surahName: a.surahName, ayahNumber: a.ayahNumber,
    pageNumber: a.pageNumber, juzNumber: a.juzNumber, text: a.text,
  );

  String get reference => '$surahNumber:$ayahNumber';
}

class MudabbirWordEvidence {
  final int surahNumber;
  final int ayahNumber;
  final int wordNumber;
  final String sourceText;
  final int pageNumber;
  final int juzNumber;

  const MudabbirWordEvidence({
    required this.surahNumber, required this.ayahNumber, required this.wordNumber,
    required this.sourceText, required this.pageNumber, required this.juzNumber,
  });

  factory MudabbirWordEvidence.fromEntry(QuranWordEntry e) => MudabbirWordEvidence(
    surahNumber: e.surahNumber, ayahNumber: e.ayahNumber, wordNumber: e.wordNumber,
    sourceText: e.text, pageNumber: e.pageNumber, juzNumber: e.juzNumber,
  );

  String get reference => '$surahNumber:$ayahNumber';
}

class MudabbirLetterValue {
  final String letter;
  final int value;
  const MudabbirLetterValue({required this.letter, required this.value});
}
