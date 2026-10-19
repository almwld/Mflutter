/// Narrow, reference-specific corrections for known transcription defects in
/// the bundled display dataset. The search/index dataset (quran_full.json)
/// carries the verified spelling at these references.
class QuranSourceCorrections {
  static String correctVerseText(int surahNumber, int ayahNumber, String text) {
    if (surahNumber == 2 && (ayahNumber == 227 || ayahNumber == 229)) {
      return text.replaceAll('ٱلطلق', 'ٱلطلاق');
    }
    return text;
  }

  static List<dynamic> correctSurahVerses(int surahNumber, List<dynamic> verses) {
    return List<dynamic>.generate(verses.length, (index) {
      final verse = verses[index];
      if (verse is! Map) return verse;
      final copy = Map<String, dynamic>.from(verse);
      final text = copy['text'];
      if (text is String) {
        copy['text'] = correctVerseText(surahNumber, index + 1, text);
      }
      return copy;
    }, growable: false);
  }

  static Map<String, dynamic> correctQuranMap(Map<String, dynamic> source) {
    final corrected = Map<String, dynamic>.from(source);
    for (var surah = 1; surah <= 114; surah++) {
      final verses = corrected['$surah'];
      if (verses is List) {
        corrected['$surah'] = correctSurahVerses(surah, verses);
      }
    }
    return corrected;
  }
}
