import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/entities/verse.dart';

class QuranLoaderService {
  static List<Ayah>? _cachedAyahs;
  static Map<int, List<Ayah>>? _cachedBySurah;

  static Future<List<Ayah>> loadAllAyahs() async {
    if (_cachedAyahs != null) return _cachedAyahs!;
    
    final jsonStr = await rootBundle.loadString('assets/quran_full.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    _cachedAyahs = jsonList.map((j) => Ayah.fromJson(j as Map<String, dynamic>)).toList();
    return _cachedAyahs!;
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

}
