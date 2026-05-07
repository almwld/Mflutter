import 'dart:math';
import '../../../domain/entities/verse.dart';
import '../../core/constants/app_enums.dart';
import 'database_helper.dart';

/// =============================================================================
/// QuranLocalDatasource - مصدر بيانات القرآن المحلي
/// =============================================================================

class QuranLocalDatasource {
  final DatabaseHelper _databaseHelper;

  QuranLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // البيانات المُحاكاة (للتطوير)
  // ═══════════════════════════════════════════════════════════════════════════

  static final List<Surah> _surahs = List.generate(114, (index) {
    final number = index + 1;
    return Surah(
      number: number,
      name: _surahNames[number - 1] ?? 'سورة',
      englishName: _surahEnglishNames[number - 1] ?? 'Surah',
      ayahCount: _surahAyahCounts[number - 1] ?? 0,
      juzNumber: _getJuzNumber(number),
      isMakki: number <= 86,
      meaning: _surahMeanings[number - 1],
    );
  });

  static final List<String> _surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
    'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون',
    'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص',
    'زمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف',
    'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم', 'القمر',
    'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة', 'الصف',
    'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك', 'القلم',
    'الحاقة', 'المدثر', 'القارعة', 'التكوير', 'الإنفطار', 'المطففين', 'الإنشقاق',
    'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد', 'الشمس',
    'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر', 'البينة', 'الزلزلة',
    'العاديات', 'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل', 'قريش',
    'الماعون', 'الكوثر', 'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق',
    'الناس',
  ];

  static final List<String> _surahEnglishNames = [
    'Al-Fatiha', 'Al-Baqarah', 'Aal-Imran', 'An-Nisa', 'Al-Ma\'idah',
    'Al-An\'am', 'Al-A\'raf', 'Al-Anfal', 'At-Tawbah', 'Yunus', 'Hud',
    'Yusuf', 'Ar-Ra\'d', 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra',
    'Al-Kahf', 'Maryam', 'Ta-Ha', 'Al-Anbiya', 'Al-Hajj', 'Al-Mu\'minun',
    'An-Nur', 'Al-Furqan', 'Ash-Shu\'ara', 'An-Naml', 'Al-Qasas',
    'Al-Ankabut', 'Ar-Rum', 'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba',
    'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf', 'Adh-Dhariyat',
    'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', 'Al-Waqi\'ah',
    'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah', 'As-Saf',
    'Al-Jumu\'ah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim',
    'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Muddaththir', 'Al-Qari\'ah',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-A\'la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin', 'Al-\'Alaq',
    'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-\'Adiyat', 'Al-Qari\'ah',
    'At-Takathur', 'Al-\'Asr', 'Al-Humazah', 'Al-Fil', 'Quraysh',
    'Al-Ma\'un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr', 'Al-Masad',
    'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  static final List<int> _surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 55,
    78, 96, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34,
    30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29,
    18, 45, 60, 49, 62, 55, 78, 87, 64, 77, 227, 93, 88, 69, 60, 34, 30,
    73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18,
    45, 60, 49, 62, 55, 78, 87, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
    54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 87, 64, 77,
  ];

  static final List<String> _surahMeanings = [
    'الافتتاحية', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام',
    'الأعراف', 'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد',
    'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان', 'الشعراء', 'النمل',
    'القصص', 'العنكبوت', 'الروم', 'لقمان', 'السجدة', 'الأحزاب', 'سبأ',
    'فاطر', 'يس', 'الصافات', 'ص', 'زمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف',
    'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن', 'الواقعة', 'الحديد',
    'المجادلة', 'الحشر', 'الممتحنة', 'الصف', 'الجمعة', 'المنافقون',
    'التغابن', 'الطلاق', 'التحريم', 'الملك', 'القلم', 'الحاقة', 'المدثر',
    'القارعة', 'التكوير', 'الإنفطار', 'المطففين', 'الإنشقاق', 'البروج',
    'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد', 'الشمس', 'الليل',
    'الضحى', 'الشرح', 'التين', 'العلق', 'القدر', 'البينة', 'الزلزلة',
    'العاديات', 'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل', 'قريش',
    'الماعون', 'الكوثر', 'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق',
    'الناس',
  ];

  static int _getJuzNumber(int surah) {
    if (surah <= 2) return 1;
    if (surah <= 3) return 2;
    if (surah <= 5) return 3;
    if (surah <= 7) return 4;
    if (surah <= 9) return 5;
    if (surah <= 11) return 6;
    if (surah <= 12) return 7;
    if (surah <= 14) return 8;
    if (surah <= 16) return 9;
    if (surah <= 18) return 10;
    if (surah <= 20) return 11;
    if (surah <= 22) return 12;
    if (surah <= 24) return 13;
    if (surah <= 26) return 14;
    if (surah <= 28) return 15;
    if (surah <= 29) return 16;
    if (surah <= 33) return 17;
    if (surah <= 36) return 18;
    if (surah <= 38) return 19;
    if (surah <= 40) return 20;
    if (surah <= 41) return 21;
    if (surah <= 45) return 22;
    if (surah <= 46) return 23;
    if (surah <= 49) return 24;
    if (surah <= 51) return 25;
    if (surah <= 57) return 26;
    if (surah <= 66) return 27;
    if (surah <= 77) return 28;
    if (surah <= 82) return 29;
    return 30;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الآيات المُحاكاة
  // ═══════════════════════════════════════════════════════════════════════════

  static final Map<String, List<Verse>> _versesCache = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // العمليات
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب جميع السور
  Future<List<Surah>> getAllSurahs() async {
    return _surahs;
  }

  /// جلب آيات سورة
  Future<List<Verse>> getSurahVerses(int surahNumber) async {
    if (_versesCache.containsKey(surahNumber)) {
      return _versesCache[surahNumber]!;
    }

    final surah = _surahs.firstWhere((s) => s.number == surahNumber);
    final verses = <Verse>[];
    final random = Random(surahNumber * 1000);

    for (int i = 1; i <= min(surah.ayahCount, 10); i++) {
      verses.add(Verse(
        id: surahNumber * 1000 + i,
        surahNumber: surahNumber,
        ayahNumber: i,
        text: _getMockVerseText(surahNumber, i, random),
        textWithDiacritics: _getMockVerseText(surahNumber, i, random),
        type: surah.isMakki ? 0 : 1,
        juzNumber: surah.juzNumber,
        pageNumber: (surahNumber * 2) + (i ~/ 10),
        transliteration: 'Verse $i of Surah $surahNumber',
      ));
    }

    _versesCache[surahNumber.toString()] = verses;
    return verses;
  }

  /// جلب آية محددة
  Future<Verse?> getVerse(int surahNumber, int ayahNumber) async {
    final verses = await getSurahVerses(surahNumber);
    try {
      return verses.firstWhere((v) => v.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// بحث في القرآن
  Future<List<Verse>> search(String query) async {
    final results = <Verse>[];
    final lowerQuery = query.toLowerCase();

    for (final surah in _surahs.take(30)) {
      final verses = await getSurahVerses(surah.number);
      for (final verse in verses) {
        if (verse.text.toLowerCase().contains(lowerQuery) ||
            verse.textWithDiacritics.toLowerCase().contains(lowerQuery)) {
          results.add(verse);
          if (results.length >= 50) return results;
        }
      }
    }

    return results;
  }

  /// جلب آية عشوائية
  Future<Verse> getRandomVerse() async {
    final random = Random();
    final surahNumber = random.nextInt(114) + 1;
    final surah = _surahs.firstWhere((s) => s.number == surahNumber);
    final ayahNumber = random.nextInt(surah.ayahCount) + 1;
    return (await getVerse(surahNumber, ayahNumber))!;
  }

  /// جلب آية يومية
  Future<Verse> getDailyVerse() async {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final surahIndex = dayOfYear % 114;
    final surah = _surahs[surahIndex];
    final ayahNumber = (dayOfYear % surah.ayahCount) + 1;
    return (await getVerse(surah.number, ayahNumber))!;
  }

  /// جلب الأجزاء
  Future<List<Juz>> getAllJuz() async {
    return List.generate(30, (index) {
      final number = index + 1;
      return Juz(
        number: number,
        name: 'الجزء $number',
        startSurah: _getJuzStartSurah(number),
        startAyah: 1,
        endSurah: _getJuzEndSurah(number),
        endAyah: 1,
        description: 'الجزء $number من القرآن الكريم',
      );
    });
  }

  int _getJuzStartSurah(int juz) {
    final mapping = {
      1: 1, 2: 2, 3: 3, 4: 5, 5: 6, 6: 7, 7: 8, 8: 11, 9: 12, 10: 15,
      11: 17, 12: 18, 13: 21, 14: 23, 15: 25, 16: 28, 17: 33, 18: 37,
      19: 40, 20: 46, 21: 51, 22: 58, 23: 66, 24: 73, 25: 77, 26: 83,
      27: 87, 28: 97, 29: 106, 30: 114,
    };
    return mapping[juz] ?? 1;
  }

  int _getJuzEndSurah(int juz) {
    final mapping = {
      1: 1, 2: 2, 3: 4, 4: 5, 5: 6, 6: 7, 7: 10, 8: 11, 9: 14, 10: 16,
      11: 17, 12: 20, 13: 22, 14: 24, 15: 27, 16: 29, 17: 36, 18: 39,
      19: 45, 20: 50, 21: 57, 22: 65, 23: 72, 24: 76, 25: 82, 26: 86,
      27: 96, 28: 105, 29: 113, 30: 114,
    };
    return mapping[juz] ?? 114;
  }

  String _getMockVerseText(int surah, int ayah, Random random) {
    final templates = [
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
      'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
      'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ',
    ];
    return templates[random.nextInt(templates.length)];
  }
}