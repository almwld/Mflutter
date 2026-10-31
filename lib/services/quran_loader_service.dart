import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/entities/verse.dart';
import 'mushaf_source.dart';

class QuranLoaderService {
  static const int expectedAyahCount = 6236;
  static const List<int> canonicalSurahAyahCounts = <int>[
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6
  ];
  static List<Ayah>? _cachedAyahs;
  static Map<int, List<Ayah>>? _cachedBySurah;
  static Future<List<Ayah>>? _loadingAyahs;
  static Future<Map<int, List<Ayah>>>? _loadingBySurah;

  /// Shares one in-flight parse/validation across all concurrent callers.
  /// Failed loads are not cached, so a later caller can retry.
  static Future<List<Ayah>> loadAllAyahs() {
    final cached = _cachedAyahs;
    if (cached != null) return Future<List<Ayah>>.value(cached);

    final pending = _loadingAyahs;
    if (pending != null) return pending;

    final loading = _loadAllAyahs();
    _loadingAyahs = loading;
    return loading.then<List<Ayah>>(
      (ayahs) => ayahs,
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_loadingAyahs, loading)) _loadingAyahs = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  static Future<List<Ayah>> _loadAllAyahs() async {

    final jsonStr = await rootBundle.loadString('assets/quran_full.json');
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) {
      throw const FormatException('صيغة فهرس القرآن غير صحيحة: المتوقع قائمة آيات');
    }

    final ayahs = <Ayah>[];
    final references = <String>{};
    final countsBySurah = <int, int>{};
    var previousSurah = 0;
    var previousAyah = 0;

    for (var index = 0; index < decoded.length; index++) {
      final row = decoded[index];
      if (row is! Map) {
        throw FormatException('سجل الآية رقم ${index + 1} ليس كائن JSON صالحًا');
      }

      final parsedAyah = Ayah.fromJson(Map<String, dynamic>.from(row));
      // The bundled search JSON has placeholder page/juz metadata. Derive
      // page numbers from the canonical 604-page Hafs Mushaf and juz numbers
      // from the canonical start reference of each juz.
      final pageNumber = MushafSource.pageForVerse(
        parsedAyah.surahNumber,
        parsedAyah.ayahNumber,
      );
      final ayah = Ayah(
        id: parsedAyah.id,
        surahNumber: parsedAyah.surahNumber,
        surahName: parsedAyah.surahName,
        ayahNumber: parsedAyah.ayahNumber,
        text: parsedAyah.text,
        isMakki: parsedAyah.isMakki,
        juzNumber: MushafSource.juzForVerse(
          parsedAyah.surahNumber,
          parsedAyah.ayahNumber,
        ),
        pageNumber: pageNumber,
        jummal: parsedAyah.jummal,
        axisType: parsedAyah.axisType,
        energyLevel: parsedAyah.energyLevel,
      );
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

      // The canonical corpus must be ordered, not merely contain 6,236 unique
      // references. This catches swapped records and gaps at surah boundaries.
      if (ayah.surahNumber != previousSurah) {
        if (ayah.surahNumber != previousSurah + 1 || ayah.ayahNumber != 1) {
          throw FormatException(
            'ترتيب القرآن غير متصل عند السجل ${index + 1}: $reference',
          );
        }
      } else if (ayah.ayahNumber != previousAyah + 1) {
        throw FormatException(
          'ترتيب آيات السورة ${ayah.surahNumber} غير متصل عند السجل ${index + 1}: $reference',
        );
      }
      previousSurah = ayah.surahNumber;
      previousAyah = ayah.ayahNumber;

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
      final expectedCount = canonicalSurahAyahCounts[surah - 1];
      if (count != expectedCount) {
        throw FormatException(
          'عدد آيات السورة $surah غير مطابق للمصحف المعتمد: '
          'المتوقع $expectedCount، والموجود ${count ?? 0}',
        );
      }
      for (var ayahNumber = 1; ayahNumber <= expectedCount; ayahNumber++) {
        if (!references.contains('$surah:$ayahNumber')) {
          throw FormatException('فهرس القرآن يتجاوز أو يفقد الآية $surah:$ayahNumber');
        }
      }
    }

    _cachedAyahs = List<Ayah>.unmodifiable(ayahs);
    return _cachedAyahs!;
  }

  /// Shares grouping work when multiple screens request surah groups together.
  static Future<Map<int, List<Ayah>>> loadBySurah() {
    final cached = _cachedBySurah;
    if (cached != null) return Future<Map<int, List<Ayah>>>.value(cached);

    final pending = _loadingBySurah;
    if (pending != null) return pending;

    final loading = _loadBySurah();
    _loadingBySurah = loading;
    return loading.then<Map<int, List<Ayah>>>(
      (groups) => groups,
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_loadingBySurah, loading)) _loadingBySurah = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  static Future<Map<int, List<Ayah>>> _loadBySurah() async {
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
