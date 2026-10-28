import 'package:flutter/material.dart';

import '../../domain/entities/verse.dart';
import '../../services/quran_loader_service.dart';

/// Quran reader backed by the bundled source corpus.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  Map<int, List<Ayah>> _bySurah = {};
  int _selectedSurah = 1;
  int _currentPage = 0;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final grouped = await QuranLoaderService.loadBySurah();
      if (!mounted) return;
      setState(() {
        _bySurah = grouped;
        _loading = false;
        _loadError = grouped.isEmpty ? 'لم يُعثر على آيات في المصدر المحلي.' : null;
        if (!grouped.containsKey(_selectedSurah) && grouped.isNotEmpty) {
          _selectedSurah = grouped.keys.reduce((a, b) => a < b ? a : b);
        }
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'تعذر تحميل المصحف المحلي: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('القرآن الكريم')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 40),
                const SizedBox(height: 12),
                Text(_loadError!, textDirection: TextDirection.rtl, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final surahs = _bySurah.keys.toList()..sort();
    final ayahs = _bySurah[_selectedSurah] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(ayahs.isEmpty ? 'القرآن الكريم' : ayahs.first.surahName, textDirection: TextDirection.rtl),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'اختيار السورة',
            icon: const Icon(Icons.list_rounded),
            onSelected: (surah) => setState(() {
              _selectedSurah = surah;
              _currentPage = 0;
            }),
            itemBuilder: (_) => surahs
                .map((surah) => PopupMenuItem<int>(
                      value: surah,
                      child: Text(
                        _bySurah[surah]!.first.surahName + ' (' + _bySurah[surah]!.length.toString() + ')',
                        textDirection: TextDirection.rtl,
                      ),
                    ))
                .toList(growable: false),
          ),
        ],
      ),
      body: ayahs.isEmpty
          ? const Center(child: Text('لا توجد آيات في هذه السورة.'))
          : PageView.builder(
              key: ValueKey<int>(_selectedSurah),
              itemCount: ayahs.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (_, index) => _buildVerseCard(ayahs[index]),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          color: colors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'الآية السابقة',
                onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
              Text(
                'الآية ' + (ayahs.isEmpty ? '0' : (_currentPage + 1).toString()) + ' من ' + ayahs.length.toString(),
                textDirection: TextDirection.rtl,
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: 'الآية التالية',
                onPressed: _currentPage + 1 < ayahs.length ? () => setState(() => _currentPage++) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard(Ayah ayah) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.all(12),
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: SelectableText(
                    ayah.text,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ayah.surahName + ' • ' + ayah.surahNumber.toString() + ':' + ayah.ayahNumber.toString(),
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
