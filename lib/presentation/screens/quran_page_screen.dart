import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/quran_wave_text.dart';
import '../../services/quran_source_corrections.dart';
import '../../services/daily_streak_service.dart';
import '../../services/nucleus_service.dart';
import '../../services/bookmark_service.dart';

/// 📄 شاشة تصفح المصحف — عرض الصفحات كاملة
class QuranPageScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranPageScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends State<QuranPageScreen> {
  List<dynamic> _verses = [];
  bool _loading = true;
  String? _loadError;
  int _fontSize = 22;
  bool _chromeVisible = true;
  Set<int> _bookmarkedAyahs = <int>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _restoreFontSize();
  }

  Future<void> _restoreFontSize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getInt('mudabbir_quran_page_font_size');
      if (!mounted || saved == null) return;
      setState(() => _fontSize = saved.clamp(16, 32).toInt());
    } catch (error) {
      debugPrint('Could not restore Quran font size: $error');
    }
  }

  Future<void> _changeFontSize(int delta) async {
    final next = (_fontSize + delta).clamp(16, 32).toInt();
    setState(() => _fontSize = next);
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setInt('mudabbir_quran_page_font_size', next);
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تغير حجم الخط لهذه الجلسة، لكن تعذر حفظ التفضيل.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تغير حجم الخط لهذه الجلسة، لكن تعذر حفظ التفضيل: $error')),
      );
    }
  }

  Future<void> _loadSurah() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
      final data = jsonDecode(jsonStr);
      final rawVerses = data[widget.surahNumber.toString()];
      if (!mounted) return;
      setState(() {
        _verses = rawVerses is List
            ? QuranSourceCorrections.correctSurahVerses(widget.surahNumber, rawVerses)
            : <dynamic>[];
        _loading = false;
        _loadError = rawVerses is List && rawVerses.isNotEmpty
            ? null
            : 'لم يُعثر على آيات للسورة المطلوبة داخل مصدر القرآن المحلي.';
      });
      await _loadBookmarksForCurrentSurah();
      // Publish the actual selected Quran context to the shared nucleus.
      if (_verses.isNotEmpty) {
        final firstVerse = _verses.first;
        final firstText = firstVerse is Map ? (firstVerse['text'] ?? '').toString() : '';
        if (firstText.isNotEmpty) {
          NucleusService().setQuranContext(
            surahNumber: widget.surahNumber,
            ayahNumber: 1,
            verseText: firstText,
          );
        }
      }
      // Count activity only when the requested surah contains real verse data.
      if (rawVerses is List && rawVerses.isNotEmpty) {
        try {
          await DailyStreakService.recordActivity();
        } catch (error) {
          debugPrint('Could not persist reading activity: $error');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verses = [];
        _loadError = 'تعذر تحميل بيانات المصحف المحلية: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadBookmarksForCurrentSurah() async {
    try {
      final saved = await BookmarkService.getBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarkedAyahs = saved
            .where((item) => (item['surah'] as num).toInt() == widget.surahNumber)
            .map((item) => (item['ayah'] as num).toInt())
            .toSet();
      });
    } catch (error) {
      debugPrint('Could not load Quran bookmarks: $error');
    }
  }

  Future<void> _toggleBookmark(int ayahNumber, String verseText) async {
    final alreadySaved = _bookmarkedAyahs.contains(ayahNumber);
    try {
      if (alreadySaved) {
        await BookmarkService.removeBookmark(widget.surahNumber, ayahNumber);
      } else {
        await BookmarkService.addBookmark(
          widget.surahNumber,
          ayahNumber,
          verseText,
        );
      }
      if (!mounted) return;
      setState(() {
        if (alreadySaved) {
          _bookmarkedAyahs.remove(ayahNumber);
        } else {
          _bookmarkedAyahs.add(ayahNumber);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadySaved ? 'تمت إزالة العلامة المحفوظة' : 'تم حفظ الآية في علامات المصحف',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحديث العلامة: $error')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _chromeVisible ? AppBar(
        title: Text(
          widget.surahName,
          style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri'),
        ),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase, color: AppColors.gold),
            onPressed: () => _changeFontSize(2),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease, color: AppColors.gold),
            onPressed: () => _changeFontSize(-2),
          ),
        ],
      ) : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () => setState(() => _chromeVisible = !_chromeVisible),
        child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _loadError != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_loadError!, textAlign: TextAlign.center, textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri')),
            ))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.primaryNavy,
                    AppColors.backgroundDark,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _verses.length,
                itemBuilder: (context, index) {
                  final verse = _verses[index];
                  final text = verse['text'] ?? '';
                  final ayahNum = index + 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => NucleusService().setQuranContext(
                            surahNumber: widget.surahNumber,
                            ayahNumber: ayahNum,
                            verseText: text.toString(),
                          ),
                          onLongPress: () async {
                            await Clipboard.setData(
                              ClipboardData(text: text.toString()),
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم نسخ الآية $ayahNum من سورة ${widget.surahName}'),
                              ),
                            );
                          },
                          child: QuranWaveText(
                          text: text,
                          style: TextStyle(
                            fontSize: _fontSize.toDouble(),
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFECB3),
                            height: 1.8,
                          ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: _bookmarkedAyahs.contains(ayahNum)
                                  ? 'إزالة العلامة المحفوظة'
                                  : 'حفظ الآية',
                              onPressed: () => _toggleBookmark(
                                ayahNum,
                                text.toString(),
                              ),
                              icon: Icon(
                                _bookmarkedAyahs.contains(ayahNum)
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_add_outlined,
                                color: AppColors.gold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.gold,
                                    Color(0xFFB8860B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '﴿$ayahNum﴾',
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}
