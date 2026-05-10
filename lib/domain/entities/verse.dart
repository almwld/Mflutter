class Verse {
  final int id;
  final int surah;
  final int ayah;
  final String text;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String textWithDiacritics;

  const Verse({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.text,
    this.surahName = '',
    this.surahNumber = 0,
    this.ayahNumber = 0,
    this.textWithDiacritics = '',
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] ?? 0,
      surah: map['surah'] ?? 0,
      ayah: map['ayah'] ?? 0,
      text: map['text_simple'] ?? map['text'] ?? '',
      surahName: map['surah_name'] ?? '',
      surahNumber: map['surah'] ?? 0,
      ayahNumber: map['ayah'] ?? 0,
      textWithDiacritics: map['text_uthmani'] ?? map['text'] ?? '',
    );
  }
}
