import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/entities/verse.dart';

class QuranLoaderService {
  static const int expectedAyahCount = 6236;
  static List<Ayah>? _cachedAyahs;
  static Map<int, List<Ayah>>? _cachedBySurah;

  static Future<List<Ayah>> loadAllAyahs() async {
    final cached = _cachedAyahs;
    if (cached != null) return cached;

    final jsonStr = await rootBundle.loadString('assets/quran_full.json');
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) {
      throw const FormatException('صيغة فهرس القرآن غير صحيحة: المتوقع قائمة آيات');
    }

    final ayahs = <Ayah>[];
    final references = <String>{};
    final countsBySurah = <int, int>{};

    for (var index = 0; index < decoded.length; index++) {
      final row = decoded[index];
      if (row is! Map) {
        throw FormatException('سجل الآية رقم ${index + 1} ليس كائن JSON صالحًا');
      }

      final ayah = Ayah.fromJson(Map<String, dynamic>.from(row));
      if (ayah.surahNumber < 1 || ayah.surahNumber > 114 ||
          ayah.ayahNumber < 1 || ayah.text.trim().isEmpty) {
        throw FormatException(
          'بيانات آية غير صالحة عند السجل ${index + 1} '
          '(سورة ${ayah.surahNumber}، آية ${ayah.ayahNumber})',
        );
      }

      final reference = '${ayah.surahNumber}:${ayah.ayahNumber}';
      if (!references.add(reference)) {
        throw FormatException('مرجع آية مكرر في فهرس القرآن: $reference');
      }

      countsBySurah.update(
        ayah.surahNumber,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      ayahs.add(ayah);
    }

    if (ayahs.length != expectedAyahCount) {
      throw FormatException(
        'عدد آيات فهرس القرآن غير صحيح: المتوقع $expectedAyahCount، '
        'والموجود ${ayahs.length}',
      );
    }
    if (countsBySurah.length != 114) {
      throw FormatException(
        'فهرس القرآن لا يحتوي على السور الـ114 كاملة '
        '(الموجود ${countsBySurah.length} سورة)',
      );
    }

    for (var surah = 1; surah <= 114; surah++) {
      final count = countsBySurah[surah];
      if (count == null || count < 1) {
        throw FormatException('لا توجد آيات للسورة رقم $surah');
      }
      for (var ayahNumber = 1; ayahNumber <= count; ayahNumber++) {
        if (!references.contains('$surah:$ayahNumber')) {
          throw FormatException('فهرس القرآن يتجاوز أو يفقد الآية $surah:$ayahNumber');
        }
      }
    }

    _cachedAyahs = List<Ayah>.unmodifiable(ayahs);
    return _cachedAyahs!;
  }

  static Future<Map<int, List<Ayah>>> loadBySurah() async {
    final cached = _cachedBySurah;
    if (cached != null) return cached;

    final ayahs = await loadAllAyahs();
    final grouped = <int, List<Ayah>>{};
    for (final ayah in ayahs) {
      grouped.putIfAbsent(ayah.surahNumber, () => <Ayah>[]).add(ayah);
    }

    _cachedBySurah = Map<int, List<Ayah>>.unmodifiable({
      for (final entry in grouped.entries)
        entry.key: List<Ayah>.unmodifiable(entry.value),
    });
    return _cachedBySurah!;
  }
}
