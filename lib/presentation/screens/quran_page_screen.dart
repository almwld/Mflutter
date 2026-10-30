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


/// Presets affect only the Quran page presentation; canonical verse data is untouched.
const Map<String, Map<String, Color>> _quranDisplayPalettes = {
  'classic': {'background': Color(0xFF101B2D), 'surface': Color(0xFF19263A), 'text': Color(0xFFFFECB3), 'accent': Color(0xFFD6B36A)},
  'paper': {'background': Color(0xFFF4EBD8), 'surface': Color(0xFFFFF9EC), 'text': Color(0xFF493A28), 'accent': Color(0xFF967344)},
  'white': {'background': Color(0xFFFFFFFF), 'surface': Color(0xFFF5F5F5), 'text': Color(0xFF202020), 'accent': Color(0xFF52796F)},
  'ivory': {'background': Color(0xFFFFF8E7), 'surface': Color(0xFFFFFDF5), 'text': Color(0xFF403629), 'accent': Color(0xFF9A7848)},
  'midnight': {'background': Color(0xFF080B14), 'surface': Color(0xFF141927), 'text': Color(0xFFE6EAF2), 'accent': Color(0xFF91A7D0)},
  'black': {'background': Color(0xFF000000), 'surface': Color(0xFF101010), 'text': Color(0xFFFFFFFF), 'accent': Color(0xFFBDBDBD)},
  'emerald': {'background': Color(0xFF092C27), 'surface': Color(0xFF124239), 'text': Color(0xFFE0F2E9), 'accent': Color(0xFF80CBC4)},
  'sage': {'background': Color(0xFFE4EBDD), 'surface': Color(0xFFF2F5EC), 'text': Color(0xFF26382D), 'accent': Color(0xFF66866F)},
  'ocean': {'background': Color(0xFF102B45), 'surface': Color(0xFF183D5C), 'text': Color(0xFFE1F3FF), 'accent': Color(0xFF75B9DF)},
  'lavender': {'background': Color(0xFF28243D), 'surface': Color(0xFF393451), 'text': Color(0xFFF0EAFE), 'accent': Color(0xFFC5A9E8)},
  'rose': {'background': Color(0xFF3A2028), 'surface': Color(0xFF512D38), 'text': Color(0xFFFFE9ED), 'accent': Color(0xFFE5A2B1)},
  'sand': {'background': Color(0xFFDCC9A8), 'surface': Color(0xFFEBDDCA), 'text': Color(0xFF3E3326), 'accent': Color(0xFF876B45)},
  'slate': {'background': Color(0xFF303943), 'surface': Color(0xFF414D59), 'text': Color(0xFFF0F3F5), 'accent': Color(0xFFAABAC8)},
  'highContrast': {'background': Color(0xFF000000), 'surface': Color(0xFF000000), 'text': Color(0xFFFFFF00), 'accent': Color(0xFFFFFFFF)},
};

const Map<String, String> _quranPaletteNames = {
  'classic': 'ليلي كلاسيكي', 'paper': 'ورق المصحف', 'white': 'أبيض نقي',
  'ivory': 'عاجي دافئ', 'midnight': 'منتصف الليل', 'black': 'أسود خالص',
  'emerald': 'زمردي', 'sage': 'أخضر هادئ', 'ocean': 'أزرق محيطي',
  'lavender': 'لافندر', 'rose': 'وردي داكن', 'sand': 'رملي',
  'slate': 'رمادي أردوازي', 'highContrast': 'تباين مرتفع',
};

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
  String _fontFamily = 'Amiri';
  String _paletteKey = 'classic';
  Color get _pageColor => _quranDisplayPalettes[_paletteKey]!['background']!;
  Color get _surfaceColor => _quranDisplayPalettes[_paletteKey]!['surface']!;
  Color get _textColor => _quranDisplayPalettes[_paletteKey]!['text']!;
  Color get _accentColor => _quranDisplayPalettes[_paletteKey]!['accent']!;
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
      final savedFont = preferences.getString('mudabbir_quran_page_font_family');
      final savedPalette = preferences.getString('mudabbir_quran_page_palette');
      if (!mounted) return;
      setState(() {
        if (saved != null) _fontSize = saved.clamp(16, 40).toInt();
        if (savedFont == 'Amiri' || savedFont == 'Musnad') _fontFamily = savedFont!;
        if (_quranDisplayPalettes.containsKey(savedPalette)) _paletteKey = savedPalette!;
      });
    } catch (error) {
      debugPrint('Could not restore Quran font size: $error');
    }
  }

  Future<void> _changeFontSize(int delta) async {
    final next = (_fontSize + delta).clamp(16, 40).toInt();
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

  Future<void> _setDisplayPreference({String? fontFamily, String? paletteKey}) async {
    setState(() {
      if (fontFamily != null) _fontFamily = fontFamily;
      if (paletteKey != null && _quranDisplayPalettes.containsKey(paletteKey)) {
        _paletteKey = paletteKey;
      }
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      if (fontFamily != null) {
        await preferences.setString('mudabbir_quran_page_font_family', fontFamily);
      }
      if (paletteKey != null) {
        await preferences.setString('mudabbir_quran_page_palette', paletteKey);
      }
    } catch (error) {
      debugPrint('Could not persist Quran display preferences: $error');
    }
  }

  Future<void> _showDisplaySettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refreshSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Container(width: 42, height: 4,
                    decoration: BoxDecoration(color: _textColor.withOpacity(.3),
                      borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 18),
                  Text('تخصيص عرض الصفحة', style: TextStyle(
                    color: _textColor, fontSize: 20, fontWeight: FontWeight.bold,
                    fontFamily: _fontFamily)),
                  const SizedBox(height: 18),
                  Text('نوع الخط', style: TextStyle(color: _textColor,
                    fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 10, runSpacing: 8, children: [
                    _fontChoice('Amiri', 'أميري', refreshSheet),
                    _fontChoice('Musnad', 'المسند', refreshSheet),
                  ]),
                  const SizedBox(height: 22),
                  Text('ألوان وفلاتر الصفحة', style: TextStyle(color: _textColor,
                    fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quranDisplayPalettes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
                      childAspectRatio: 1.7),
                    itemBuilder: (context, index) {
                      final key = _quranDisplayPalettes.keys.elementAt(index);
                      final palette = _quranDisplayPalettes[key]!;
                      final selected = _paletteKey == key;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await _setDisplayPreference(paletteKey: key);
                          refreshSheet(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette['background'],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? palette['accent']! : palette['text']!.withOpacity(.25),
                              width: selected ? 3 : 1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('أبجد', style: TextStyle(color: palette['text'],
                                fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(_quranPaletteNames[key]!, style: TextStyle(
                                color: palette['text'], fontSize: 10)),
                              if (selected) Icon(Icons.check_circle,
                                color: palette['accent'], size: 15),
                            ]),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('حجم الخط: $_fontSize', style: TextStyle(color: _textColor)),
                  Slider(
                    value: _fontSize.toDouble(), min: 16, max: 40, divisions: 12,
                    activeColor: _accentColor,
                    onChanged: (value) {
                      setState(() => _fontSize = value.round());
                      refreshSheet(() {});
                    },
                    onChangeEnd: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('mudabbir_quran_page_font_size', value.round());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fontChoice(String family, String label, StateSetter refreshSheet) {
    final selected = _fontFamily == family;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontFamily: family)),
      selected: selected,
      onSelected: (_) async {
        await _setDisplayPreference(fontFamily: family);
        refreshSheet(() {});
      },
      selectedColor: _accentColor.withOpacity(.25),
      labelStyle: TextStyle(color: _textColor),
      side: BorderSide(color: selected ? _accentColor : _textColor.withOpacity(.25)),
    );
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
          if (!mounted || !_scrollController.hasClients) return;
          // Verse cards have variable heights; this estimate brings a distant
          // verse into the lazy list, then the keyed target is aligned exactly.
          final position = _scrollController.position;
          final estimatedOffset = ((widget.initialAyahNumber - 1) * 180.0)
              .clamp(0.0, position.maxScrollExtent)
              .toDouble();
          _scrollController.jumpTo(estimatedOffset);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final targetContext =
                _verseKeys[widget.initialAyahNumber]?.currentContext;
            if (!mounted || targetContext == null) return;
            Scrollable.ensureVisible(
              targetContext,
              alignment: 0.2,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            );
          });
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
      backgroundColor: _pageColor,
      appBar: _chromeVisible ? AppBar(
        title: Text(
          widget.surahName,
          style: TextStyle(color: _accentColor, fontFamily: _fontFamily),
        ),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(
            icon: Icon(Icons.text_increase, color: _accentColor),
            onPressed: () => _changeFontSize(2),
          ),
          IconButton(
            icon: Icon(Icons.text_decrease, color: _accentColor),
            onPressed: () => _changeFontSize(-2),
          ),
          IconButton(
            tooltip: 'ألوان وخط الصفحة',
            icon: Icon(Icons.palette_outlined, color: _accentColor),
            onPressed: _showDisplaySettings,
          ),
        ],
      ) : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: _toggleChrome,
        child: _loading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
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
                    style: TextStyle(color: _textColor.withOpacity(.8), fontFamily: _fontFamily),
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
              color: _pageColor,
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
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentColor.withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.08),
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
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
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
                                color: _accentColor,
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
                                  color: _pageColor,
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
