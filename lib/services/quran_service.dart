import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/quran_models.dart';

class QuranService {
  static Map<String, dynamic>? _cachedQuran;

  static Future<Map<String, dynamic>> loadQuran() async {
    if (_cachedQuran != null) return _cachedQuran!;
    final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
    _cachedQuran = jsonDecode(jsonStr);
    return _cachedQuran!;
  }

  static List<Surah> getSurahs() {
    return [
      const Surah(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatiha', verseCount: 7, revelationType: 'مكية', pageNumber: 1),
      const Surah(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', verseCount: 286, revelationType: 'مدنية', pageNumber: 2),
      const Surah(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Aal-E-Imran', verseCount: 200, revelationType: 'مدنية', pageNumber: 50),
      const Surah(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', verseCount: 176, revelationType: 'مدنية', pageNumber: 77),
      const Surah(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Maidah', verseCount: 120, revelationType: 'مدنية', pageNumber: 106),
      const Surah(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', verseCount: 83, revelationType: 'مكية', pageNumber: 440),
      const Surah(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', verseCount: 78, revelationType: 'مدنية', pageNumber: 531),
      const Surah(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', verseCount: 30, revelationType: 'مكية', pageNumber: 562),
      const Surah(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', verseCount: 4, revelationType: 'مكية', pageNumber: 604),
      const Surah(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', verseCount: 5, revelationType: 'مكية', pageNumber: 604),
      const Surah(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', verseCount: 6, revelationType: 'مكية', pageNumber: 604),
    ];
  }
}
