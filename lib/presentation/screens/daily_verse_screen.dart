import 'package:flutter/material.dart';

import '../../domain/entities/verse.dart';
import '../../services/bookmark_service.dart';
import '../../services/mushaf_source.dart';
import '../../services/quran_loader_service.dart';
import 'quran/mushaf_screen.dart';

/// آية اليوم مشتقة من فهرس القرآن المحلي حتى يبقى النص والمرجع متطابقين.
class DailyVerseScreen extends StatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  State<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends State<DailyVerseScreen> {
  List<Ayah> _verses = const <Ayah>[];
  int _index = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _isBookmarked = false;

  Ayah? get _current => _verses.isEmpty ? null : _verses[_index];

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  Future<void> _loadVerse() async {
    try {
      final verses = await QuranLoaderService.loadAllAyahs();
      if (!mounted) return;
      if (verses.isEmpty) {
        throw StateError('فهرس القرآن المحلي لا يحتوي على آيات.');
      }
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year)).inDays;
      final index = dayOfYear % verses.length;
      setState(() {
        _verses = verses;
        _index = index;
        _loading = false;
        _error = null;
      });
      await _refreshBookmark();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل آية اليوم من فهرس القرآن المحلي: $error';
      });
    }
  }

  Future<void> _retryLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _loadVerse();
  }

  Future<void> _refreshBookmark() async {
    final verse = _current;
    if (verse == null) return;
    try {
      final saved = await BookmarkService.isBookmarked(
        verse.surahNumber,
        verse.ayahNumber,
      );
      final current = _current;
      if (mounted &&
          current?.surahNumber == verse.surahNumber &&
          current?.ayahNumber == verse.ayahNumber) {
        setState(() => _isBookmarked = saved);
      }
    } catch (_) {
      // Bookmark storage is optional for rendering the verse itself.
      final current = _current;
      if (mounted &&
          current?.surahNumber == verse.surahNumber &&
          current?.ayahNumber == verse.ayahNumber) {
        setState(() => _isBookmarked = false);
      }
    }
  }

  Future<void> _nextVerse() async {
    if (_verses.isEmpty) return;
    setState(() => _index = (_index + 1) % _verses.length);
    await _refreshBookmark();
  }

  Future<void> _toggleBookmark() async {
    final verse = _current;
    if (verse == null || _saving) return;
    setState(() => _saving = true);
    try {
      if (_isBookmarked) {
        await BookmarkService.removeBookmark(
          verse.surahNumber,
          verse.ayahNumber,
        );
      } else {
        await BookmarkService.addBookmark(
          verse.surahNumber,
          verse.ayahNumber,
          verse.text,
        );
      }
      if (!mounted) return;
      setState(() {
        _isBookmarked = !_isBookmarked;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'أُضيفت الآية إلى المفضلة' : 'أُزيلت الآية من المفضلة'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحديث المفضلة: $error')),
      );
    }
  }

  void _openInMushaf(Ayah verse) {
    final page = MushafSource.pageForVerse(
      verse.surahNumber,
      verse.ayahNumber,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page, restoreLastPage: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final verse = _current;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('آية اليوم')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 42, color: colors.error),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _retryLoad,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : verse == null
                  ? const Center(child: Text('لا توجد آيات متاحة'))
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Icon(Icons.auto_awesome, color: colors.primary, size: 40),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: colors.primary.withOpacity(.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '﴿ ${verse.text} ﴾',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: 24,
                                  fontFamily: 'Amiri',
                                  height: 2,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'سورة ${verse.surahName} • الآية ${verse.ayahNumber}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.primary,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'صفحة ${MushafSource.pageForVerse(verse.surahNumber, verse.ayahNumber)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () => _openInMushaf(verse),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('فتح موضع الآية في المصحف'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _toggleBookmark,
                          icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined),
                          label: Text(_isBookmarked ? 'إزالة من المفضلة' : 'حفظ في المفضلة'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _nextVerse,
                          icon: const Icon(Icons.refresh),
                          label: const Text('آية أخرى من الفهرس المحلي'),
                        ),
                      ],
                    ),
    );
  }
}
