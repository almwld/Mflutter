import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/entities/verse.dart';

class QuranLoaderService {
  static List<Ayah>? _cachedAyahs;
  static Map<int, List<Ayah>>? _cachedBySurah;

  static Future<List<Ayah>> loadAllAyahs() async {
    if (_cachedAyahs != null) return _cachedAyahs!;
    
    try {
      final jsonStr = await rootBundle.loadString('assets/quran_full.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _cachedAyahs = jsonList.map((j) => Ayah.fromJson(j)).toList();
      return _cachedAyahs!;
    } catch (e) {
      // إذا لم يوجد الملف، استخدم بيانات مضمنة
      return _loadBuiltInQuran();
    }
  }

  static Future<Map<int, List<Ayah>>> loadBySurah() async {
    if (_cachedBySurah != null) return _cachedBySurah!;
    
    final ayahs = await loadAllAyahs();
    _cachedBySurah = {};
    for (final ayah in ayahs) {
      _cachedBySurah!.putIfAbsent(ayah.surahNumber, () => []);
      _cachedBySurah![ayah.surahNumber]!.add(ayah);
    }
    return _cachedBySurah!;
  }

  static List<Ayah> _loadBuiltInQuran() {
    // بيانات مضمنة لأشهر الآيات
    return [
      Ayah(id: 1, surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 1, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', axisType: 'tranquil'),
      Ayah(id: 2, surahNumber: 1, surahName: 'الفاتحة', ayahNumber: 2, text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', axisType: 'cosmic'),
      Ayah(id: 255, surahNumber: 2, surahName: 'البقرة', ayahNumber: 255, text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ', axisType: 'tranquil', jummal: 287, energyLevel: 0.87),
      Ayah(id: 35, surahNumber: 24, surahName: 'النور', ayahNumber: 35, text: 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', axisType: 'cosmic', jummal: 256, energyLevel: 0.95),
      Ayah(id: 1, surahNumber: 112, surahName: 'الإخلاص', ayahNumber: 1, text: 'قُلْ هُوَ اللَّهُ أَحَدٌ', axisType: 'calculation'),
    ];
  }
}
