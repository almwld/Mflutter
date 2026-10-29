import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/quran_wave_text.dart';
import '../../services/quran_source_corrections.dart';
import '../../services/quran_loader_service.dart';
import '../../services/daily_streak_service.dart';
import '../../services/nucleus_service.dart';
import '../../services/bookmark_service.dart';

/// 📄 شاشة تصفح المصحف — عرض الصفحات كاملة
class QuranPageScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int initialAyahNumber;

  const QuranPageScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialAyahNumber = 1,
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
  final Map<int, GlobalKey> _verseKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _restoreFontSize();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).catchError((error) {
      debugPrint('QuranPageScreen: could not set system bars: $error');
    });
  }

  Future<void> _toggleChrome() async {
    final showChrome = !_chromeVisible;
    if (mounted) setState(() => _chromeVisible = showChrome);
    try {
      await SystemChrome.setEnabledSystemUIMode(
        showChrome ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
      );
    } catch (error) {
      debugPrint('QuranPageScreen: could not update system bars: $error');
    }
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
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      if (widget.surahNumber < 1 || widget.surahNumber > 114) {
        throw ArgumentError.value(
          widget.surahNumber,
          'surahNumber',
          'يجب أن يكون رقم السورة بين 1 و114.',
        );
      }
      final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
      final data = jsonDecode(jsonStr);
      if (data is! Map) {
        throw const FormatException('مصدر القرآن المحلي ليس كائن السور المتوقع.');
      }
      final rawVerses = data[widget.surahNumber.toString()];
      final expectedCount =
          QuranLoaderService.canonicalSurahAyahCounts[widget.surahNumber - 1];
      if (rawVerses is! List || rawVerses.length != expectedCount) {
        throw FormatException(
          'بيانات السورة غير مكتملة: المتوقع $expectedCount آية، '
          'والموجود ${rawVerses is List ? rawVerses.length : 0}.',
        );
      }
      for (var index = 0; index < rawVerses.length; index++) {
        final verse = rawVerses[index];
        if (verse is! Map ||
            verse['text'] is! String ||
            (verse['text'] as String).trim().isEmpty) {
          throw FormatException(
            'نص الآية ${widget.surahNumber}:${index + 1} غير صالح.',
          );
        }
      }
      final correctedVerses =
          QuranSourceCorrections.correctSurahVerses(widget.surahNumber, rawVerses);
      if (correctedVerses.length != expectedCount) {
        throw FormatException('تغيّر عدد آيات السورة بعد تصحيح المصدر المحلي.');
      }
      if (!mounted) return;
      setState(() {
        _verses = correctedVerses;
        _loading = false;
        _loadError = correctedVerses.isNotEmpty
            ? null
            : 'لم يُعثر على آيات صالحة للسورة المطلوبة داخل مصدر القرآن المحلي.';
      });
      if (widget.initialAyahNumber > 1 &&
          widget.initialAyahNumber <= correctedVerses.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetContext = _verseKeys[widget.initialAyahNumber]?.currentContext;
          if (!mounted || targetContext == null) return;
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.2,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        });
      }
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
      if (correctedVerses.isNotEmpty) {
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).catchError((error) {
      debugPrint('QuranPageScreen: could not restore system bars: $error');
    });
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
        onDoubleTap: _toggleChrome,
        child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _loadError != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri'),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _loadSurah,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة تحميل السورة'),
                  ),
                ],
              ),
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
                  final verseKey = _verseKeys.putIfAbsent(ayahNum, GlobalKey.new);

                  return Container(
                    key: verseKey,
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
