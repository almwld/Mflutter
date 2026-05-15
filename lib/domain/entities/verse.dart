class Verse {
  final int surah;
  final int ayah;
  final String text;
  final String surahName;

  const Verse({
    required this.surah,
    required this.ayah,
    required this.text,
    this.surahName = '',
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      surah: map['surah'] ?? 0,
      ayah: map['ayah'] ?? 0,
      text: map['text'] ?? '',
      surahName: map['surah_name'] ?? '',
    );
  }
}
