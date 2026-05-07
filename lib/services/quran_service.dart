import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/verse.dart';

/// =============================================================================
/// QuranService - خدمة القرآن الكريم
/// =============================================================================

class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  Database? _database;
  List<SurahInfo> _surahs = [];

  /// تحميل قاعدة البيانات
  Future<void> loadFromDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'mudabbir.db');

      _database = await openDatabase(path);
      await _loadSurahs();
    } catch (e) {
      // استخدام البيانات الافتراضية
      await _loadDefaultSurahs();
    }
  }

  /// قراءة جميع السور
  Future<List<SurahInfo>> getAllSurahs() async {
    if (_surahs.isEmpty) {
      await _loadSurahs();
    }
    return _surahs;
  }

  /// البحث في القرآن
  Future<List<Verse>> search(String query) async {
    final results = <Verse>[];

    // البحث في البيانات المحلية
    for (final surah in _surahs) {
      final verses = await getSurahVerses(surah.number);
      for (final verse in verses) {
        if (verse.text.contains(query) ||
            verse.translation.toLowerCase().contains(query.toLowerCase())) {
          results.add(verse);
        }
      }
    }

    return results.take(50).toList();
  }

  /// الحصول على آية محددة
  Future<Verse> getVerse(int surah, int ayah) async {
    final verses = await getSurahVerses(surah);
    if (ayah <= verses.length) {
      return verses[ayah - 1];
    }
    return Verse(
      surah: surah,
      ayah: ayah,
      text: '',
      translation: '',
    );
  }

  /// الحصول على آيات السورة
  Future<List<Verse>> getSurahVerses(int surahNumber) async {
    // بيانات افتراضية للاختبار
    return _generateMockVerses(surahNumber);
  }

  /// تحميل السور من قاعدة البيانات
  Future<void> _loadSurahs() async {
    _surahs = _defaultSurahs;
  }

  Future<void> _loadDefaultSurahs() async {
    _surahs = _defaultSurahs;
  }

  /// توليد آيات وهمية للاختبار
  List<Verse> _generateMockVerses(int surahNumber) {
    final surah = _surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => SurahInfo(number: surahNumber, name: 'سورة', ayahCount: 5),
    );

    return List.generate(
      surah.ayahCount.clamp(1, 10),
      (index) => Verse(
        surah: surahNumber,
        ayah: index + 1,
        text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translation: 'بسم الله الرحمن الرحيم',
        juz: (surahNumber / 30).ceil(),
        page: (surahNumber * 0.6).ceil(),
      ),
    );
  }

  /// الحصول على معلومات السورة
  SurahInfo getSurahInfo(int surahNumber) {
    return _surahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => SurahInfo(number: surahNumber, name: '', ayahCount: 0),
    );
  }

  /// الحصول على الآية اليومية
  Future<Verse> getDailyVerse() async {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final surahIndex = (dayOfYear % _surahs.length);
    final verseIndex = (dayOfYear % 10);

    final verses = await getSurahVerses(_surahs[surahIndex].number);
    return verses[verseIndex.clamp(0, verses.length - 1)];
  }

  /// الحصول على آية عشوائية
  Future<Verse> getRandomVerse() async {
    final randomSurah = DateTime.now().millisecond % _surahs.length;
    final randomAyah = DateTime.now().second % 10;

    final verses = await getSurahVerses(_surahs[randomSurah].number);
    return verses[randomAyah.clamp(0, verses.length - 1)];
  }

  /// إغلاق قاعدة البيانات
  Future<void> close() async {
    await _database?.close();
  }

  /// قائمة السور الافتراضية
  static final List<SurahInfo> _defaultSurahs = [
    SurahInfo(number: 1, name: 'الفاتحة', ayahCount: 7),
    SurahInfo(number: 2, name: 'البقرة', ayahCount: 286),
    SurahInfo(number: 3, name: 'آل عمران', ayahCount: 200),
    SurahInfo(number: 4, name: 'النساء', ayahCount: 176),
    SurahInfo(number: 5, name: 'المائدة', ayahCount: 120),
    SurahInfo(number: 6, name: 'الأنعام', ayahCount: 165),
    SurahInfo(number: 7, name: 'الأعراف', ayahCount: 206),
    SurahInfo(number: 8, name: 'الأنفال', ayahCount: 75),
    SurahInfo(number: 9, name: 'التوبة', ayahCount: 129),
    SurahInfo(number: 10, name: 'يونس', ayahCount: 109),
    SurahInfo(number: 11, name: 'هود', ayahCount: 123),
    SurahInfo(number: 12, name: 'يوسف', ayahCount: 111),
    SurahInfo(number: 13, name: 'الرعد', ayahCount: 43),
    SurahInfo(number: 14, name: 'إبراهيم', ayahCount: 52),
    SurahInfo(number: 15, name: 'الحجر', ayahCount: 99),
    SurahInfo(number: 16, name: 'النحل', ayahCount: 128),
    SurahInfo(number: 17, name: 'الإسراء', ayahCount: 111),
    SurahInfo(number: 18, name: 'الكهف', ayahCount: 110),
    SurahInfo(number: 19, name: 'مريم', ayahCount: 98),
    SurahInfo(number: 20, name: 'طه', ayahCount: 135),
    SurahInfo(number: 21, name: 'الأنبياء', ayahCount: 112),
    SurahInfo(number: 22, name: 'الحج', ayahCount: 78),
    SurahInfo(number: 23, name: 'المؤمنون', ayahCount: 118),
    SurahInfo(number: 24, name: 'النور', ayahCount: 64),
    SurahInfo(number: 25, name: 'الفرقان', ayahCount: 77),
    SurahInfo(number: 26, name: 'الشعراء', ayahCount: 227),
    SurahInfo(number: 27, name: 'النمل', ayahCount: 93),
    SurahInfo(number: 28, name: 'القصص', ayahCount: 88),
    SurahInfo(number: 29, name: 'العنكبوت', ayahCount: 69),
    SurahInfo(number: 30, name: 'الروم', ayahCount: 60),
    SurahInfo(number: 31, name: 'لقمان', ayahCount: 34),
    SurahInfo(number: 32, name: 'السجدة', ayahCount: 30),
    SurahInfo(number: 33, name: 'الأحزاب', ayahCount: 73),
    SurahInfo(number: 34, name: 'سبأ', ayahCount: 54),
    SurahInfo(number: 35, name: 'فاطر', ayahCount: 45),
    SurahInfo(number: 36, name: 'يس', ayahCount: 83),
    SurahInfo(number: 37, name: 'الصافات', ayahCount: 182),
    SurahInfo(number: 38, name: 'ص', ayahCount: 88),
    SurahInfo(number: 39, name: 'الزمر', ayahCount: 75),
    SurahInfo(number: 40, name: 'غافر', ayahCount: 85),
    SurahInfo(number: 41, name: 'فصلت', ayahCount: 54),
    SurahInfo(number: 42, name: 'الشورى', ayahCount: 53),
    SurahInfo(number: 43, name: 'الزخرف', ayahCount: 89),
    SurahInfo(number: 44, name: 'الدخان', ayahCount: 59),
    SurahInfo(number: 45, name: 'الجاثية', ayahCount: 37),
    SurahInfo(number: 46, name: 'الأحقاف', ayahCount: 35),
    SurahInfo(number: 47, name: 'محمد', ayahCount: 38),
    SurahInfo(number: 48, name: 'الفتح', ayahCount: 29),
    SurahInfo(number: 49, name: 'الحجرات', ayahCount: 18),
    SurahInfo(number: 50, name: 'ق', ayahCount: 45),
    SurahInfo(number: 51, name: 'الذاريات', ayahCount: 60),
    SurahInfo(number: 52, name: 'الطور', ayahCount: 49),
    SurahInfo(number: 53, name: 'النجم', ayahCount: 62),
    SurahInfo(number: 54, name: 'القمر', ayahCount: 55),
    SurahInfo(number: 55, name: 'الرحمن', ayahCount: 78),
    SurahInfo(number: 56, name: 'الواقعة', ayahCount: 96),
    SurahInfo(number: 57, name: 'الحديد', ayahCount: 29),
    SurahInfo(number: 58, name: 'المجادلة', ayahCount: 22),
    SurahInfo(number: 59, name: 'الحشر', ayahCount: 24),
    SurahInfo(number: 60, name: 'الممتحنة', ayahCount: 13),
    SurahInfo(number: 61, name: 'الصف', ayahCount: 14),
    SurahInfo(number: 62, name: 'الجمعة', ayahCount: 11),
    SurahInfo(number: 63, name: 'المنافقون', ayahCount: 11),
    SurahInfo(number: 64, name: 'التغابن', ayahCount: 18),
    SurahInfo(number: 65, name: 'الطلاق', ayahCount: 12),
    SurahInfo(number: 66, name: 'التحريم', ayahCount: 12),
    SurahInfo(number: 67, name: 'الملك', ayahCount: 30),
    SurahInfo(number: 68, name: 'القلم', ayahCount: 52),
    SurahInfo(number: 69, name: 'الحاقة', ayahCount: 52),
    SurahInfo(number: 70, name: 'المعارج', ayahCount: 44),
    SurahInfo(number: 71, name: 'نوح', ayahCount: 28),
    SurahInfo(number: 72, name: 'الجن', ayahCount: 28),
    SurahInfo(number: 73, name: 'المزمل', ayahCount: 20),
    SurahInfo(number: 74, name: 'المدثر', ayahCount: 56),
    SurahInfo(number: 75, name: 'القيامة', ayahCount: 40),
    SurahInfo(number: 76, name: 'الإنسان', ayahCount: 31),
    SurahInfo(number: 77, name: 'المرسلات', ayahCount: 50),
    SurahInfo(number: 78, name: 'النبأ', ayahCount: 40),
    SurahInfo(number: 79, name: 'النازعات', ayahCount: 46),
    SurahInfo(number: 80, name: 'عبس', ayahCount: 42),
    SurahInfo(number: 81, name: 'التكوير', ayahCount: 29),
    SurahInfo(number: 82, name: 'الانفطار', ayahCount: 19),
    SurahInfo(number: 83, name: 'المطففين', ayahCount: 36),
    SurahInfo(number: 84, name: 'الانشقاق', ayahCount: 25),
    SurahInfo(number: 85, name: 'البروج', ayahCount: 22),
    SurahInfo(number: 86, name: 'الطارق', ayahCount: 17),
    SurahInfo(number: 87, name: 'الأعلى', ayahCount: 19),
    SurahInfo(number: 88, name: 'الغاشية', ayahCount: 26),
    SurahInfo(number: 89, name: 'الفجر', ayahCount: 30),
    SurahInfo(number: 90, name: 'البلد', ayahCount: 20),
    SurahInfo(number: 91, name: 'الشمس', ayahCount: 15),
    SurahInfo(number: 92, name: 'الليل', ayahCount: 21),
    SurahInfo(number: 93, name: 'الضحى', ayahCount: 11),
    SurahInfo(number: 94, name: 'الشرح', ayahCount: 8),
    SurahInfo(number: 95, name: 'التين', ayahCount: 8),
    SurahInfo(number: 96, name: 'العلق', ayahCount: 19),
    SurahInfo(number: 97, name: 'القدر', ayahCount: 5),
    SurahInfo(number: 98, name: 'البينة', ayahCount: 8),
    SurahInfo(number: 99, name: 'الزلزلة', ayahCount: 8),
    SurahInfo(number: 100, name: 'العاديات', ayahCount: 11),
    SurahInfo(number: 101, name: 'القارعة', ayahCount: 11),
    SurahInfo(number: 102, name: 'التكاثر', ayahCount: 8),
    SurahInfo(number: 103, name: 'العصر', ayahCount: 3),
    SurahInfo(number: 104, name: 'الهمزة', ayahCount: 9),
    SurahInfo(number: 105, name: 'الفيل', ayahCount: 5),
    SurahInfo(number: 106, name: 'قريش', ayahCount: 4),
    SurahInfo(number: 107, name: 'الماعون', ayahCount: 7),
    SurahInfo(number: 108, name: 'الكوثر', ayahCount: 3),
    SurahInfo(number: 109, name: 'الكافرون', ayahCount: 6),
    SurahInfo(number: 110, name: 'النصر', ayahCount: 3),
    SurahInfo(number: 111, name: 'المسد', ayahCount: 5),
    SurahInfo(number: 112, name: 'الإخلاص', ayahCount: 4),
    SurahInfo(number: 113, name: 'الفلق', ayahCount: 5),
    SurahInfo(number: 114, name: 'الناس', ayahCount: 6),
  ];
}

/// =============================================================================
/// SurahInfo - معلومات السورة
/// =============================================================================

class SurahInfo {
  final int number;
  final String name;
  final int ayahCount;

  SurahInfo({
    required this.number,
    required this.name,
    required this.ayahCount,
  });
}