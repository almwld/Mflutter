import 'package:flutter/material.dart';

import '../../services/quran_loader_service.dart';
import '../../services/mushaf_source.dart';
import '../../domain/entities/verse.dart';
import 'quran/mushaf_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Ayah> _results = const [];
  List<Ayah> _ayahs = const [];
  bool _loadingIndex = true;
  bool _searching = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loadingIndex = true;
        _error = null;
      });
    }
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      if (!mounted) return;
      setState(() {
        _ayahs = ayahs;
        _loadingIndex = false;
      });
      if (ayahs.isEmpty) {
        setState(() => _error = 'مصدر القرآن لم يُرجع أي آية؛ تحقق من ملف المصدر.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingIndex = false;
        _error = 'تعذر تحميل فهرس القرآن: $error';
      });
    }
  }

  String _normalizeDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final output = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final arabicIndex = arabic.indexOf(char);
      final persianIndex = persian.indexOf(char);
      if (arabicIndex >= 0) {
        output.write(arabicIndex);
      } else if (persianIndex >= 0) {
        output.write(persianIndex);
      } else {
        output.write(char);
      }
    }
    return output.toString();
  }

  String _normalize(String value) => _normalizeDigits(value)
      .replaceAll(RegExp(r'[ًٌٍَُِّْـٰ]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[ۖۗۚۛۙۜ۞﴿﴾.,،؛:!?؟]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Future<void> _search(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _hasSearched = false;
        _error = 'أدخل كلمة أو نصًا أو مرجعًا مثل 2:255 للبحث.';
      });
      return;
    }
    if (_loadingIndex || _ayahs.isEmpty) {
      setState(() => _error = 'فهرس القرآن غير جاهز بعد. أعد المحاولة بعد اكتمال التحميل.');
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final normalizedQuery = _normalize(query);
      final normalizedReference = _normalizeDigits(query);
      final reference = RegExp(r'^(\d{1,3})\s*[:/.-]\s*(\d{1,3})$')
          .firstMatch(normalizedReference);
      final List<Ayah> hits;
      if (reference != null) {
        final surah = int.parse(reference.group(1)!);
        final ayah = int.parse(reference.group(2)!);
        if (surah < 1 || surah > 114 || ayah < 1) {
          hits = const [];
        } else {
          hits = _ayahs
              .where((verse) =>
                  verse.surahNumber == surah && verse.ayahNumber == ayah)
              .toList(growable: false);
        }
      } else {
        final words = normalizedQuery
            .split(' ')
            .where((word) => word.length >= 2)
            .toList(growable: false);
        if (normalizedQuery.isEmpty || words.isEmpty) {
          hits = const [];
        } else {
          hits = _ayahs.where((verse) {
            final text = _normalize(verse.text);
            return text.contains(normalizedQuery) ||
                words.every(text.contains);
          }).take(100).toList(growable: false);
        }
      }

      if (!mounted) return;
      setState(() {
        _results = hits;
        _searching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = 'تعذر تنفيذ البحث: $error';
      });
    }
  }

  void _open(Ayah ayah) {
    final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MushafScreen(
          initialPage: page,
          restoreLastPage: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث في القرآن'),
        actions: [
          IconButton(
            tooltip: 'إعادة تحميل الفهرس',
            onPressed: _loadingIndex ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'كلمة، جزء من آية، أو 2:255',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'مسح البحث',
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _results = const [];
                      _hasSearched = false;
                      _error = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: _search,
            ),
          ),
          if (_loadingIndex || _searching) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _error!,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                  if (!_loadingIndex)
                    IconButton(
                      tooltip: 'إعادة المحاولة',
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
            ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _error != null
                                ? Icons.error_outline_rounded
                                : (_hasSearched
                                    ? Icons.search_off_rounded
                                    : Icons.menu_book_rounded),
                            size: 38,
                            color: colors.onSurface.withOpacity(.55),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _loadingIndex
                                ? 'جارٍ تحميل فهرس الآيات…'
                                : (_error != null
                                    ? 'تعذر تجهيز البحث'
                                    : (_hasSearched
                                        ? 'لم يُعثر على نتائج مطابقة.'
                                        : 'اكتب كلمة أو نص آية أو مرجعًا مثل 2:255 ثم اضغط بحثًا من لوحة المفاتيح.')),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface.withOpacity(.7),
                            ),
                          ),
                          if (_error != null && !_loadingIndex) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('إعادة تحميل فهرس القرآن'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final verse = _results[index];
                      return Card(
                        child: InkWell(
                          onTap: () => _open(verse),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'سورة ${verse.surahName} • الآية ${verse.ayahNumber} • صفحة ${verse.pageNumber}',
                                  textDirection: TextDirection.rtl,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  '﴿${verse.text}﴾',
                                  textDirection: TextDirection.rtl,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    height: 1.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _controller.text.trim().isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _loadingIndex || _searching
                  ? null
                  : () => _search(_controller.text),
              icon: const Icon(Icons.search_rounded),
              label: const Text('بحث'),
            ),
    );
  }
}
