/// =============================================================================
/// Verse - نموذج الآية
/// =============================================================================

class Verse {
  final int surah;
  final int ayah;
  final String text;
  final String translation;
  final int juz;
  final int page;
  final bool isMakki;

  Verse({
    required this.surah,
    required this.ayah,
    required this.text,
    required this.translation,
    this.juz = 1,
    this.page = 1,
    this.isMakki = true,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String? ?? '',
      juz: json['juz'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      isMakki: json['isMakki'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': surah,
      'ayah': ayah,
      'text': text,
      'translation': translation,
      'juz': juz,
      'page': page,
      'isMakki': isMakki,
    };
  }

  @override
  String toString() {
    return 'Verse(surah: $surah, ayah: $ayah, text: $text)';
  }
}

/// =============================================================================
/// Surah - معلومات السورة
/// =============================================================================

class Surah {
  final int number;
  final String name;
  final String nameArabic;
  final int ayahCount;
  final bool isMakki;
  final int juzStart;
  final int pageStart;

  Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.ayahCount,
    this.isMakki = true,
    this.juzStart = 1,
    this.pageStart = 1,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      nameArabic: json['nameArabic'] as String? ?? json['name'] as String,
      ayahCount: json['ayahCount'] as int,
      isMakki: json['isMakki'] as bool? ?? true,
      juzStart: json['juzStart'] as int? ?? 1,
      pageStart: json['pageStart'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'nameArabic': nameArabic,
      'ayahCount': ayahCount,
      'isMakki': isMakki,
      'juzStart': juzStart,
      'pageStart': pageStart,
    };
  }
}