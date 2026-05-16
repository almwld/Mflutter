class Ayah {
  final int id;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String text;
  final bool isMakki;
  final int juzNumber;
  final int pageNumber;
  final int jummal;
  final String axisType; // 'cosmic', 'tranquil', 'calculation'
  final double energyLevel;

  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
    this.isMakki = true,
    this.juzNumber = 1,
    this.pageNumber = 1,
    this.jummal = 0,
    this.axisType = 'cosmic',
    this.energyLevel = 0.5,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] ?? json['ayah_text'] ?? '').toString();
    int jummal = 0;
    for (final char in text.runes) {
      jummal += char % 1000;
    }
    
    // تحديد محور الآية
    final cosmicKeywords = ['سماء', 'أرض', 'نجم', 'شمس', 'قمر', 'كوكب', 'فلك', 'بحر', 'جبل', 'كون'];
    final tranquilKeywords = ['ليل', 'نوم', 'سكينة', 'طمأنينة', 'سلام', 'راحة'];
    final calcKeywords = ['عدد', 'حساب', 'ميزان', 'قص', 'نبأ'];
    
    String axisType = 'cosmic';
    for (final kw in tranquilKeywords) {
      if (text.contains(kw)) { axisType = 'tranquil'; break; }
    }
    for (final kw in calcKeywords) {
      if (text.contains(kw)) { axisType = 'calculation'; break; }
    }

    return Ayah(
      id: json['id'] ?? 0,
      surahNumber: json['surah_number'] ?? json['surah'] ?? 1,
      surahName: json['surah_name'] ?? '',
      ayahNumber: json['ayah_number'] ?? json['ayah'] ?? 1,
      text: text,
      isMakki: json['is_makki'] ?? true,
      juzNumber: json['juz_number'] ?? json['juz'] ?? 1,
      pageNumber: json['page_number'] ?? json['page'] ?? 1,
      jummal: jummal.abs(),
      axisType: axisType,
      energyLevel: (jummal % 100) / 100.0,
    );
  }
}
