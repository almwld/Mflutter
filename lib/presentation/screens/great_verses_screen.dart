import 'package:flutter/material.dart';

import '../../domain/entities/verse.dart';
import '../../services/bookmark_service.dart';
import '../../services/mushaf_source.dart';
import '../../services/quran_loader_service.dart';
import 'quran/mushaf_screen.dart';

/// مجموعة آيات منتقاة؛ نص كل آية ومرجعها يُستخرجان من الفهرس المحلي.
class GreatVersesScreen extends StatefulWidget {
  const GreatVersesScreen({super.key});

  static const List<Map<String, String>> verses = <Map<String, String>>[
    {'ref': '2:255', 'title': 'آية الكرسي', 'desc': 'آية في سورة البقرة'},
    {'ref': '1:1', 'title': 'فاتحة الكتاب', 'desc': 'بداية المصحف الشريف'},
    {'ref': '112:1', 'title': 'مطلع سورة الإخلاص', 'desc': 'بداية سورة الإخلاص'},
    {'ref': '24:35', 'title': 'آية النور', 'desc': 'من سورة النور'},
    {'ref': '36:1', 'title': 'مطلع سورة يس', 'desc': 'الحروف المقطعة في مطلع السورة'},
    {'ref': '55:13', 'title': 'آية النعم', 'desc': 'من سورة الرحمن'},
    {'ref': '67:1', 'title': 'مطلع سورة الملك', 'desc': 'بداية سورة الملك'},
    {'ref': '3:190', 'title': 'آية التفكر', 'desc': 'التفكر في خلق السماوات والأرض'},
    {'ref': '59:22', 'title': 'آية الأسماء الحسنى', 'desc': 'من سورة الحشر'},
    {'ref': '56:1', 'title': 'مطلع سورة الواقعة', 'desc': 'بداية سورة الواقعة'},
  ];

  @override
  State<GreatVersesScreen> createState() => _GreatVersesScreenState();
}

class _GreatVersesScreenState extends State<GreatVersesScreen> {
  Map<String, Ayah> _ayahByReference = const <String, Ayah>{};
  bool _loading = true;
  String? _error;
  final Set<String> _saving = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      if (!mounted) return;
      if (ayahs.isEmpty) {
        throw StateError('فهرس القرآن المحلي لا يحتوي على آيات.');
      }
      setState(() {
        _ayahByReference = <String, Ayah>{
          for (final ayah in ayahs)
            '${ayah.surahNumber}:${ayah.ayahNumber}': ayah,
        };
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل فهرس الآيات: $error';
      });
    }
  }

  void _open(Ayah ayah) {
    final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MushafScreen(
          initialPage: page,
          initialSurah: ayah.surahNumber,
          initialAyah: ayah.ayahNumber,
          restoreLastPage: false,
        ),
      ),
    );
  }

  Future<void> _save(Ayah ayah, String reference) async {
    if (_saving.contains(reference)) return;
    setState(() => _saving.add(reference));
    try {
      await BookmarkService.addBookmark(
        ayah.surahNumber,
        ayah.ayahNumber,
        ayah.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حُفظت آية ${ayah.surahNumber}:${ayah.ayahNumber} في المفضلة')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ الآية: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving.remove(reference));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('آيات مختارة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _load();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: GreatVersesScreen.verses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = GreatVersesScreen.verses[index];
                    final reference = item['ref']!;
                    final ayah = _ayahByReference[reference];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: ayah == null ? null : () => _open(ayah),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: colors.primary.withOpacity(.12),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${item['desc']} • ${ayah?.surahName ?? reference}',
                                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'حفظ في المفضلة',
                                    onPressed: ayah == null || _saving.contains(reference)
                                        ? null
                                        : () => _save(ayah, reference),
                                    icon: _saving.contains(reference)
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.bookmark_add_outlined),
                                  ),
                                ],
                              ),
                              if (ayah != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '﴿ ${ayah.text} ﴾',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Amiri', fontSize: 19, height: 1.9),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'سورة ${ayah.surahName} • الآية ${ayah.ayahNumber} • صفحة ${MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber)}',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(color: colors.primary),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton.icon(
                                    onPressed: () => _open(ayah),
                                    icon: const Icon(Icons.menu_book_rounded),
                                    label: const Text('فتح في المصحف'),
                                  ),
                                ),
                              ] else
                                Text('المرجع غير موجود في فهرس القرآن المحلي: $reference', style: TextStyle(color: colors.error)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
