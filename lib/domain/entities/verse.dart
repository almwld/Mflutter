import '../../core/constants/app_enums.dart';

/// =============================================================================
/// Verse - كيان الآية
/// =============================================================================

class Verse {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String textWithDiacritics;
  final VerseType type;
  final int juzNumber;
  final int pageNumber;
  final String? transliteration;

  const Verse({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.textWithDiacritics,
    required this.type,
    required this.juzNumber,
    required this.pageNumber,
    this.transliteration,
  });

  /// رقم الآية
  String get displayNumber => '$surahNumber:$ayahNumber';

  /// الآية بالشكل الكامل
  String get fullVerse => '$displayNumber - $textWithDiacritics';

  /// هل مكية؟
  bool get isMakki => type == VerseType.makki;

  /// هل مدنية؟
  bool get isMadani => type == VerseType.madani;

  ///نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'text': text,
    'text_with_diacritics': textWithDiacritics,
    'type': type.index,
    'juz_number': juzNumber,
    'page_number': pageNumber,
    'transliteration': transliteration,
  };

  /// إنشاء من Map
  factory Verse.fromMap(Map<String, dynamic> map) => Verse(
    id: map['id'] ?? 0,
    surahNumber: map['surah_number'] ?? 0,
    ayahNumber: map['ayah_number'] ?? 0,
    text: map['text'] ?? '',
    textWithDiacritics: map['text_with_diacritics'] ?? map['text'] ?? '',
    type: VerseType.values[map['type'] ?? 0],
    juzNumber: map['juz_number'] ?? 1,
    pageNumber: map['page_number'] ?? 1,
    transliteration: map['transliteration'],
  );
}

/// =============================================================================
/// Surah - كيان السورة
/// =============================================================================

class Surah {
  final int number;
  final String name;
  final String englishName;
  final int ayahCount;
  final int juzNumber;
  final bool isMakki;
  final String? meaning;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahCount,
    required this.juzNumber,
    required this.isMakki,
    this.meaning,
  });

  /// النوع
  VerseType get type => isMakki ? VerseType.makki : VerseType.madani;

  /// اسم السورة مع الرقم
  String get displayName => 'سورة $name';

  ///المعلومات
  String get info => '$ayahCount آية • ${isMakki ? 'مكية' : 'مدنية'}';

  ///نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'number': number,
    'name': name,
    'english_name': englishName,
    'ayah_count': ayahCount,
    'juz_number': juzNumber,
    'is_makki': isMakki,
    'meaning': meaning,
  };

  /// إنشاء من Map
  factory Surah.fromMap(Map<String, dynamic> map) => Surah(
    number: map['number'] ?? 0,
    name: map['name'] ?? '',
    englishName: map['english_name'] ?? '',
    ayahCount: map['ayah_count'] ?? 0,
    juzNumber: map['juz_number'] ?? 1,
    isMakki: map['is_makki'] ?? true,
    meaning: map['meaning'],
  );
}

/// =============================================================================
/// Juz - كيان الجزء
/// =============================================================================

class Juz {
  final int number;
  final String name;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final String? description;

  const Juz({
    required this.number,
    required this.name,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    this.description,
  });

  /// رقم الجزء المعروض
  String get displayNumber => 'الجزء $number';

  /// معلومات البداية
  String get startInfo => 'من سورة $startSurah آية $startAyah';

  /// معلومات النهاية
  String get endInfo => 'إلى سورة $endSurah آية $endAyah';

  ///نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'number': number,
    'name': name,
    'start_surah': startSurah,
    'start_ayah': startAyah,
    'end_surah': endSurah,
    'end_ayah': endAyah,
    'description': description,
  };

  /// إنشاء من Map
  factory Juz.fromMap(Map<String, dynamic> map) => Juz(
    number: map['number'] ?? 0,
    name: map['name'] ?? '',
    startSurah: map['start_surah'] ?? 1,
    startAyah: map['start_ayah'] ?? 1,
    endSurah: map['end_surah'] ?? 1,
    endAyah: map['end_ayah'] ?? 1,
    description: map['description'],
  );
}