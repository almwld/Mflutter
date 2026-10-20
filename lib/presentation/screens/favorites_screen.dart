import 'package:flutter/material.dart';

import '../../services/bookmark_service.dart';
import '../../services/mushaf_source.dart';
import 'quran/mushaf_screen.dart';

/// قائمة العلامات المحفوظة، مع فتح الآية في صفحة المصحف الصحيحة.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _bookmarks = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await BookmarkService.getBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarks = bookmarks;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل المفضلة: $error';
      });
    }
  }

  Future<void> _removeBookmark(Map<String, dynamic> bookmark) async {
    final surah = (bookmark['surah'] as num).toInt();
    final ayah = (bookmark['ayah'] as num).toInt();
    try {
      await BookmarkService.removeBookmark(surah, ayah);
      await _loadBookmarks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف العلامة من المفضلة')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف العلامة: $error')),
      );
    }
  }

  void _openBookmark(Map<String, dynamic> bookmark) {
    final surah = (bookmark['surah'] as num).toInt();
    final ayah = (bookmark['ayah'] as num).toInt();
    final page = MushafSource.pageForVerse(surah, ayah);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('المفضلة'),
        actions: [
          IconButton(
            tooltip: 'تحديث المفضلة',
            onPressed: _loading ? null : () {
              setState(() => _loading = true);
              _loadBookmarks();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
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
                            setState(() => _loading = true);
                            _loadBookmarks();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : _bookmarks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_border_rounded, size: 48, color: colors.primary),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد آيات محفوظة بعد',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.onSurface.withOpacity(.65),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'يمكنك حفظ أي آية من شاشة آية اليوم أو من أدوات المصحف.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _bookmarks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        final surah = (bookmark['surah'] as num).toInt();
                        final ayah = (bookmark['ayah'] as num).toInt();
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () => _openBookmark(bookmark),
                            title: Text(
                              (bookmark['text'] as String?) ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: 'Amiri',
                                height: 1.8,
                              ),
                              textDirection: TextDirection.rtl,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'سورة $surah • الآية $ayah • صفحة ${MushafSource.pageForVerse(surah, ayah)}',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: colors.primary),
                            ),
                            leading: Icon(Icons.menu_book_rounded, color: colors.primary),
                            trailing: IconButton(
                              tooltip: 'حذف من المفضلة',
                              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                              onPressed: () => _removeBookmark(bookmark),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
