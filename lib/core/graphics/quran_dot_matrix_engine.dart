import 'package:flutter/foundation.dart';

import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';

/// A deterministic visual cell mapped to one canonical Quran ayah.
@immutable
class QuranDot {
  const QuranDot({
    required this.index,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  final int index;
  final int surahNumber;
  final int ayahNumber;
  final String text;

  String get reference => '$surahNumber:$ayahNumber';
}

/// Live Quran Dot Matrix controller.
///
/// The canonical Quran corpus is loaded through [QuranLoaderService]. No
/// illustrative/random verse indices or hard-coded statistics are used.
class QuranDotMatrixEngine extends ChangeNotifier {
  QuranDotMatrixEngine({this.columns = 79}) {
    if (columns < 1) {
      throw ArgumentError.value(columns, 'columns', 'Must be positive.');
    }
  }

  final int columns;
  List<QuranDot> _dots = const <QuranDot>[];
  Set<int> _activeIndices = <int>{};
  bool _isLoading = false;
  Object? _error;
  int? _focusedIndex;
  String _query = '';

  List<QuranDot> get dots => _dots;
  Set<int> get activeIndices => Set<int>.unmodifiable(_activeIndices);
  bool get isLoading => _isLoading;
  bool get isReady => _dots.length == QuranLoaderService.expectedAyahCount;
  Object? get error => _error;
  int? get focusedIndex => _focusedIndex;
  String get query => _query;
  int get totalAyahs => _dots.length;
  int get activeCount => _activeIndices.length;
  int get rowCount => (_dots.length / columns).ceil();

  Future<void> load() async {
    if (isReady || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      _dots = List<QuranDot>.unmodifiable(
        ayahs.asMap().entries.map((entry) {
          final Ayah ayah = entry.value;
          return QuranDot(
            index: entry.key,
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            text: ayah.text,
          );
        }),
      );
      _activeIndices = <int>{};
      _focusedIndex = null;
      _query = '';
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects every ayah belonging to a surah, using its real corpus records.
  int selectSurah(int surahNumber) {
    _ensureLoaded();
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }
    _activeIndices = _dots
        .where((dot) => dot.surahNumber == surahNumber)
        .map((dot) => dot.index)
        .toSet();
    _query = '';
    _focusedIndex = _activeIndices.isEmpty ? null : _activeIndices.first;
    notifyListeners();
    return _activeIndices.length;
  }

  /// Selects one ayah by its canonical surah/ayah reference.
  bool focusVerse(int surahNumber, int ayahNumber) {
    _ensureLoaded();
    final index = _dots.indexWhere(
      (dot) =>
          dot.surahNumber == surahNumber && dot.ayahNumber == ayahNumber,
    );
    if (index < 0) return false;
    _activeIndices = <int>{index};
    _focusedIndex = index;
    _query = '';
    notifyListeners();
    return true;
  }

  /// Highlights every ayah containing the requested whole word or phrase.
  /// Search normalization is applied only to comparison; Quran text is kept
  /// byte-for-byte as supplied by the canonical local corpus.
  int searchWord(String value) {
    _ensureLoaded();
    final needle = _normalize(value);
    _query = value.trim();
    if (needle.isEmpty) {
      clearSelection();
      return 0;
    }

    final phrase = needle.split(' ').where((part) => part.isNotEmpty).toList();
    _activeIndices = <int>{};
    for (final dot in _dots) {
      final tokens = _normalize(dot.text)
          .split(RegExp(r'[^ء-ي]+'))
          .where((token) => token.isNotEmpty)
          .toList(growable: false);
      final matches = phrase.length == 1
          ? tokens.contains(needle)
          : _containsPhrase(tokens, phrase);
      if (matches) _activeIndices.add(dot.index);
    }
    _focusedIndex =
        _activeIndices.isEmpty ? null : _activeIndices.first;
    notifyListeners();
    return _activeIndices.length;
  }

  bool _containsPhrase(List<String> tokens, List<String> phrase) {
    if (phrase.length > tokens.length) return false;
    for (var start = 0; start <= tokens.length - phrase.length; start++) {
      var matched = true;
      for (var offset = 0; offset < phrase.length; offset++) {
        if (tokens[start + offset] != phrase[offset]) {
          matched = false;
          break;
        }
      }
      if (matched) return true;
    }
    return false;
  }

  static String _normalize(String value) => value
      .replaceAll(RegExp(r'[ًٌٍَُِّْٰۖۗۘۙۚۛۜ۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp(r'[أإآٱٲٳٵٶٷ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void clearSelection() {
    _activeIndices = <int>{};
    _focusedIndex = null;
    _query = '';
    notifyListeners();
  }

  QuranDot? dotAt(int index) {
    if (index < 0 || index >= _dots.length) return null;
    return _dots[index];
  }

  void _ensureLoaded() {
    if (!isReady) {
      throw StateError('Load the QuranDotMatrixEngine before querying it.');
    }
  }
}
