import '../../../domain/entities/verse.dart';
import '../../../domain/models/quran_models.dart';
import '../../../services/mushaf_source.dart';
import '../../../services/quran_loader_service.dart';

/// Quran data source backed by the bundled, validated Hafs dataset.
///
/// This deliberately avoids relying on a database at a hard-coded external
/// storage path, which is unavailable on fresh installs and scoped-storage
/// Android versions.
class QuranLocalDatasource {
  final Map<String, List<Map<String, dynamic>>> _versesCache = {};
  List<Ayah>? _allAyahs;

  Future<List<Ayah>> _loadAyahs() async =>
      _allAyahs ??= await QuranLoaderService.loadAllAyahs();

  Map<String, dynamic> _toRow(Ayah ayah) => <String, dynamic>{
        'id': ayah.id,
        'surah': ayah.surahNumber,
        'surah_name': ayah.surahName,
        'ayah': ayah.ayahNumber,
        'text': ayah.text,
        'text_simple': _normalize(ayah.text),
        'juz': ayah.juzNumber,
        'page': ayah.pageNumber,
        'is_makki': ayah.isMakki ? 1 : 0,
      };

  String _normalize(String value) => value
      .replaceAll(RegExp(r'[ًٌٍَُِّْٰۖۗۘۙۚۛۜ۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp(r'[ٱأإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .trim();

  Future<List<Map<String, dynamic>>> getAllSurahs() async {
    final ayahs = await _loadAyahs();
    final firstBySurah = <int, Ayah>{};
    final counts = <int, int>{};
    for (final ayah in ayahs) {
      firstBySurah.putIfAbsent(ayah.surahNumber, () => ayah);
      counts.update(ayah.surahNumber, (count) => count + 1, ifAbsent: () => 1);
    }
    return firstBySurah.keys.toList()..sort();
  }

  Future<Surah> getSurah(int number) async {
    if (number < 1 || number > 114) {
      throw ArgumentError.value(number, 'number', 'يجب أن يكون رقم السورة بين 1 و114');
    }
    final ayahs = await _loadAyahs();
    final verses = ayahs.where((ayah) => ayah.surahNumber == number).toList();
    if (verses.isEmpty) throw StateError('السورة غير موجودة: $number');
    return Surah(
      number: number,
      nameArabic: verses.first.surahName,
      nameEnglish: '',
      verseCount: verses.length,
      revelationType: verses.first.isMakki ? 'مكية' : 'مدنية',
      pageNumber: verses.first.pageNumber.clamp(1, 604).toInt(),
    );
  }

  Future<List<Surah>> getSurahs() async {
    final ayahs = await _loadAyahs();
    final grouped = <int, List<Ayah>>{};
    for (final ayah in ayahs) {
      grouped.putIfAbsent(ayah.surahNumber, () => <Ayah>[]).add(ayah);
    }
    final numbers = grouped.keys.toList()..sort();
    return numbers.map((number) {
      final verses = grouped[number]!;
      return Surah(
        number: number,
        nameArabic: verses.first.surahName,
        nameEnglish: '',
        verseCount: verses.length,
        revelationType: verses.first.isMakki ? 'مكية' : 'مدنية',
        pageNumber: verses.first.pageNumber.clamp(1, 604).toInt(),
      );
    }).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getVerses(int surahNumber) =>
      getVersesBySurah(surahNumber);

  Future<List<Map<String, dynamic>>> getVersesByJuz(int juzNumber) async {
    if (juzNumber < 1 || juzNumber > 30) {
      throw ArgumentError.value(juzNumber, 'juzNumber', 'يجب أن يكون رقم الجزء بين 1 و30');
    }
    final ayahs = await _loadAyahs();
    return ayahs
        .where((ayah) => ayah.juzNumber == juzNumber)
        .map(_toRow)
        .toList(growable: false);
  }

  Future<List<Juz>> getAllJuzs() async => List<Juz>.generate(30, (index) {
        final number = index + 1;
        final start = MushafSource.firstPageForJuz(number);
        final end = number == 30
            ? MushafSource.totalPages
            : MushafSource.firstPageForJuz(number + 1) - 1;
        return Juz(
          number: number,
          name: 'الجزء $number',
          startPage: start,
          endPage: end < start ? start : end,
        );
      }, growable: false);

  Future<Juz> getJuz(int number) async {
    if (number < 1 || number > 30) {
      throw ArgumentError.value(number, 'number', 'يجب أن يكون رقم الجزء بين 1 و30');
    }
    return (await getAllJuzs())[number - 1];
  }

  Future<List<Map<String, dynamic>>> getVersesBySurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError.value(surahNumber, 'surahNumber', 'يجب أن يكون رقم السورة بين 1 و114');
    }
    final key = surahNumber.toString();
    final cached = _versesCache[key];
    if (cached != null) return cached;

    final ayahs = await _loadAyahs();
    final rows = ayahs
        .where((ayah) => ayah.surahNumber == surahNumber)
        .map(_toRow)
        .toList(growable: false);
    _versesCache[key] = rows;
    return rows;
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final normalized = _normalize(query);
    final ayahs = await _loadAyahs();
    if (normalized.isEmpty) return ayahs.map(_toRow).toList(growable: false);

    return ayahs
        .where((ayah) => _normalize(ayah.text).contains(normalized))
        .take(50)
        .map(_toRow)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> getVerse(int surah, int ayah) async {
    if (surah < 1 || surah > 114 || ayah < 1) return null;
    final verses = await getVersesBySurah(surah);
    for (final verse in verses) {
      if ((verse['ayah'] as int) == ayah) return verse;
    }
    return null;
  }
}
