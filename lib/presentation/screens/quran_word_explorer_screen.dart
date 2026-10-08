import 'package:flutter/material.dart';

import '../../domain/entities/verse.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quran_word_index_service.dart';
import '../../services/mushaf_source.dart';

/// Interactive, data-derived word and letter coordinates for the Hafs Mushaf.
class QuranWordExplorerScreen extends StatefulWidget {
  const QuranWordExplorerScreen({super.key});

  @override
  State<QuranWordExplorerScreen> createState() => _QuranWordExplorerScreenState();
}

class _QuranWordExplorerScreenState extends State<QuranWordExplorerScreen> {
  Map<int, List<Ayah>> _bySurah = const {};
  List<QuranWordEntry> _words = const [];
  List<QuranLetterEntry> _letters = const [];
  int _surah = 1;
  int _ayah = 1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _bySurah = await QuranLoaderService.loadBySurah();
      await _loadVerse();
    } catch (error) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'تعذر بناء فهرس الكلمات والحروف: ' + error.toString();
      });
    }
  }

  Future<void> _loadVerse() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final words = await QuranWordIndexService.wordsForVerse(_surah, _ayah);
      final letters = await QuranWordIndexService.lettersForVerse(_surah, _ayah);
      if (!mounted) return;
      setState(() {
        _words = words;
        _letters = letters;
        _loading = false;
      });
    } catch (error) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'تعذر تحميل مواضع الآية: ' + error.toString();
      });
    }
  }

  Future<void> _move(int delta) async {
    var nextSurah = _surah;
    var nextAyah = _ayah + delta;
    final count = _bySurah[nextSurah]?.length ?? 0;
    if (nextAyah > count) {
      if (nextSurah == 114) return;
      nextSurah++;
      nextAyah = 1;
    } else if (nextAyah < 1) {
      if (nextSurah == 1) return;
      nextSurah--;
      nextAyah = _bySurah[nextSurah]?.length ?? 1;
    }
    setState(() {
      _surah = nextSurah;
      _ayah = nextAyah;
    });
    await _loadVerse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final verses = _bySurah[_surah] ?? const <Ayah>[];
    final matching = verses.where((verse) => verse.ayahNumber == _ayah);
    final text = matching.isEmpty ? '' : matching.first.text;
    final page = _words.isEmpty
        ? MushafSource.pageForVerse(_surah, _ayah)
        : _words.first.pageNumber;
    final juz = _words.isEmpty
        ? MushafSource.juzForPage(page)
        : _words.first.juzNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('مستكشف الكلمات والحروف')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('سورة ' + _surah.toString() + ' • الآية ' + _ayah.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: colors.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('صفحة ' + page.toString() + ' • جزء ' + juz.toString() +
                                ' • ' + _words.length.toString() + ' كلمات • ' +
                                _letters.length.toString() + ' حرفًا',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 14),
                            Text(text, textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    fontFamily: 'Amiri', height: 1.9)),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: OutlinedButton.icon(
                                onPressed: _surah == 1 && _ayah == 1 ? null : () => _move(-1),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('السابقة'))),
                              const SizedBox(width: 10),
                              Expanded(child: OutlinedButton.icon(
                                onPressed: _surah == 114 &&
                                    _ayah == (_bySurah[114]?.length ?? 0)
                                    ? null : () => _move(1),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('التالية'))),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('الكلمات مرتبة حسب ورودها', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final word in _words)
                      Card(
                        child: ExpansionTile(
                          key: ValueKey(word.surahNumber.toString() + ':' +
                              word.ayahNumber.toString() + ':' + word.wordNumber.toString()),
                          title: Text(word.text, textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Amiri')),
                          subtitle: Text('الكلمة ' + word.wordNumber.toString() +
                              ' • ' + word.normalized, textDirection: TextDirection.rtl),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.end,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _letters.where((letter) =>
                                      letter.wordNumber == word.wordNumber).map((letter) =>
                                        Chip(
                                          avatar: const Icon(Icons.text_fields_rounded, size: 16),
                                          label: Text(letter.letter + ' • ' +
                                              letter.letterNumber.toString()),
                                        )).toList(growable: false),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('الموضع: سورة ' + word.surahNumber.toString() +
                                      '، آية ' + word.ayahNumber.toString() +
                                      '، كلمة ' + word.wordNumber.toString() +
                                      ' • صفحة ' + word.pageNumber.toString() +
                                      ' • جزء ' + word.juzNumber.toString(),
                                      textDirection: TextDirection.rtl),
                                  const SizedBox(height: 4),
                                  Text('قيمة الجُمّل التقليدية: ' +
                                      _letters.where((letter) =>
                                        letter.wordNumber == word.wordNumber).fold<int>(
                                          0, (sum, letter) => sum + letter.abjadValue).toString(),
                                      textDirection: TextDirection.rtl),
                                  Text('هذه قيمة حسابية اصطلاحية، ولا تثبت وحدها معنى غيبيًا أو نبوءة.',
                                      textDirection: TextDirection.rtl,
                                      style: theme.textTheme.bodySmall),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final matches = await QuranWordIndexService.searchWords(word.text);
                                        if (!context.mounted) return;
                                        showModalBottomSheet<void>(
                                          context: context,
                                          showDragHandle: true,
                                          builder: (context) => SafeArea(
                                            child: ListView(
                                              padding: const EdgeInsets.all(16),
                                              children: [
                                                Text('مواضع الكلمة: ' + word.text,
                                                    style: theme.textTheme.titleMedium),
                                                for (final match in matches)
                                                  ListTile(
                                                    title: Text('سورة ' +
                                                        match.surahNumber.toString() +
                                                        ' • آية ' + match.ayahNumber.toString(),
                                                        textDirection: TextDirection.rtl),
                                                    subtitle: Text('كلمة ' +
                                                        match.wordNumber.toString() +
                                                        ' • صفحة ' + match.pageNumber.toString() +
                                                        ' • جزء ' + match.juzNumber.toString(),
                                                        textDirection: TextDirection.rtl),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.manage_search),
                                      label: const Text('عرض جميع مواضع الكلمة'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
