class Verse {
  final int id;
  final int surah;
  final int ayah;
  final String text;
  final String surahName;

  const Verse({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.text,
    this.surahName = '',
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] ?? 0,
      surah: map['surah'] ?? 0,
      ayah: map['ayah'] ?? 0,
      text: map['text_simple'] ?? map['text'] ?? '',
      surahName: map['surah_name'] ?? '',
    );
  }
}
