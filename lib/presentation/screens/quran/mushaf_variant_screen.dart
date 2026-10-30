import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/mushaf_source.dart';
import '../../../core/themes/font_manager.dart';
import '../../../services/mushaf_variant_layout_service.dart';
import '../../../services/reading_progress_service.dart';
import '../../../services/daily_streak_service.dart';
import '../../../services/quran_fonts_service.dart';
import '../../../services/quran_page_theme_service.dart';
import '../../../services/text_transformer.dart';
import '../../widgets/quran_wave_text.dart';

enum MushafVariantMode { uthmani, musnad, dotless, dotlessPlain, kufi, hieroglyphic }

class MushafVariantScreen extends StatefulWidget {
  const MushafVariantScreen({super.key, required this.initialPage});
  final int initialPage;

  @override
  State<MushafVariantScreen> createState() => _MushafVariantScreenState();
}

class _MushafVariantScreenState extends State<MushafVariantScreen> {
  late final PageController _controller;
  int _page = 1;
  MushafVariantMode _mode = MushafVariantMode.uthmani;

  Color get _pageBackground => QuranPageThemeService.background(_pageTheme);
  Color get _pageTextColor => QuranPageThemeService.text(_pageTheme);
  Color get _headerInk => _pageTheme == QuranPageTheme.paper
      ? const Color(0xFF241A12)
      : _pageTextColor;
  QuranPageTheme _pageTheme = QuranPageTheme.paper;
  bool _chromeVisible = true;
  Future<void> _pagePersistence = Future<void>.value();

  Future<void> _setImmersiveMode(bool immersive) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    } catch (error) {
      debugPrint('MushafVariantScreen: could not update system bars: $error');
    }
  }

  Future<void> _toggleSystemBars() async {
    final showChrome = !_chromeVisible;
    if (mounted) setState(() => _chromeVisible = showChrome);
    // Keep the app's reader controls and Android system bars in sync so a
    // double tap genuinely enters/exits immersive reading.
    await _setImmersiveMode(!showChrome);
  }

  @override
  void initState() {
    super.initState();
    _page = MushafSource.normalizePage(widget.initialPage);
    _controller = PageController(initialPage: _page - 1);
    _persistCurrentPage(_page);
    // The controls are visible initially, so keep Android system bars
    // visible too; the double-tap toggle will switch both layers together.
    _setImmersiveMode(false);
    _restorePageTheme();
    _restoreDisplayMode();
    _loadQuranFonts();
  }

  Future<void> _loadQuranFonts() async {
    await QuranFontsService.load();
    if (mounted) setState(() {});
  }

  Future<void> _persistCurrentPage(int page) {
    final normalizedPage = MushafSource.normalizePage(page);
    // Serialize writes so a slow earlier preference write cannot overwrite
    // the most recently viewed page after rapid swipes.
    _pagePersistence = _pagePersistence.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      try {
        final saved = await preferences.setInt(
          'mudabbir_mushaf_variant_last_page',
          normalizedPage,
        );
        if (!saved) {
          debugPrint('MushafVariantScreen: variant page write was rejected.');
        }
      } catch (error) {
        debugPrint('MushafVariantScreen: variant page save failed: $error');
      }
      try {
        await ReadingProgressService.saveLastPage(normalizedPage);
      } catch (error) {
        debugPrint('MushafVariantScreen: shared progress save failed: $error');
      }
      try {
        await DailyStreakService.recordActivity();
      } catch (error) {
        debugPrint('MushafVariantScreen: streak activity save failed: $error');
      }
    }).catchError((Object error) {
      debugPrint('MushafVariantScreen: could not save reading page: $error');
    });
    return _pagePersistence;
  }

  Future<void> _restorePageTheme() async {
    final theme = await QuranPageThemeService.load();
    if (mounted) setState(() => _pageTheme = theme);
  }

  Future<void> _restoreDisplayMode() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedIndex = preferences.getInt('mudabbir_mushaf_variant_mode');
      if (savedIndex == null ||
          savedIndex < 0 ||
          savedIndex >= MushafVariantMode.values.length ||
          !mounted) {
        return;
      }
      setState(() => _mode = MushafVariantMode.values[savedIndex]);
    } catch (error) {
      debugPrint('MushafVariantScreen: could not restore display mode: $error');
    }
  }

  Future<void> _persistVariantPreference(
    Future<bool> Function(SharedPreferences preferences) write,
    String setting,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await write(preferences);
      if (!saved) {
        debugPrint('MushafVariantScreen: preference write rejected: $setting');
      }
    } catch (error) {
      debugPrint('MushafVariantScreen: could not save $setting: $error');
    }
  }

  Future<void> _setDisplayMode(MushafVariantMode mode) async {
    setState(() => _mode = mode);
    await _persistVariantPreference(
      (preferences) => preferences.setInt('mudabbir_mushaf_variant_mode', mode.index),
      'display mode',
    );
  }

  @override
  void dispose() {
    // Restore the app's normal system bars when leaving Mushaf reading.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).catchError((error) {
      debugPrint('MushafVariantScreen: could not restore system bars on dispose: $error');
    });
    _controller.dispose();
    super.dispose();
  }

  String _transform(String text) {
    switch (_mode) {
      case MushafVariantMode.uthmani:
        return text;
      case MushafVariantMode.musnad:
        return TextTransformer.toMusnad(text);
      case MushafVariantMode.dotless:
        return FontManager.isRaqqFontLoaded
            ? text
            : TextTransformer.toDotlessPreservingMarks(text);
      case MushafVariantMode.dotlessPlain:
        return FontManager.isRaqqFontLoaded
            ? TextTransformer.removeArabicMarks(text)
            : TextTransformer.toDotless(text);
      case MushafVariantMode.kufi:
        return text;
      case MushafVariantMode.hieroglyphic:
        return TextTransformer.toHieroglyphic(text);
    }
  }

  String get _modeName {
    switch (_mode) {
      case MushafVariantMode.uthmani:
        return 'عثماني Unicode';
      case MushafVariantMode.musnad:
        return 'المسند';
      case MushafVariantMode.dotless:
        return 'بدون نقاط مع التشكيل';
      case MushafVariantMode.dotlessPlain:
        return 'بدون نقاط أو تشكيل';
      case MushafVariantMode.kufi:
        return FontManager.isRaqqFontLoaded
            ? 'رَقّ — كوفي مصحفي مبكر'
            : 'رَقّ — الخط غير متاح';
      case MushafVariantMode.hieroglyphic:
        return 'هيروغليفي';
    }
  }

  int? _parsePageNumber(String raw) {
    final normalized = raw.trim().replaceAllMapped(
      RegExp(r'[٠-٩۰-۹]'),
      (match) {
        final code = match.group(0)!.codeUnitAt(0);
        final digit = code >= 0x06F0 && code <= 0x06F9
            ? code - 0x06F0
            : code - 0x0660;
        return String.fromCharCode(0x30 + digit);
      },
    );
    final page = int.tryParse(normalized);
    if (page == null || page < 1 || page > MushafSource.totalPages) return null;
    return page;
  }

  void _showPagePicker() {
    final input = TextEditingController(text: '$_page');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: TextField(
          controller: input,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: '1 - 604'),
          onSubmitted: (_) {
            final page = _parsePageNumber(input.text);
            if (page == null) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('أدخل رقم صفحة صحيحًا من 1 إلى 604.')),
              );
              return;
            }
            Navigator.pop(dialogContext);
            _jump(page);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final page = _parsePageNumber(input.text);
              if (page == null) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('أدخل رقم صفحة صحيحًا من 1 إلى 604.')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              _jump(page);
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    ).whenComplete(input.dispose);
  }

  Future<void> _jump(int page) async {
    final target = MushafSource.normalizePage(page);
    await _controller.animateToPage(
      target - 1,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = _pageTextColor;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _toggleSystemBars,
        child: SafeArea(
          child: Column(
          children: [
            if (_chromeVisible) _buildHeader(gold),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: MushafSource.totalPages,
                onPageChanged: (index) {
                  final page = index + 1;
                  setState(() => _page = page);
                  _persistCurrentPage(page);
                },
                itemBuilder: (_, index) => _VariantPage(
                  page: index + 1,
                  mode: _mode,
                  paper: _pageBackground,
                  gold: gold,
                  transform: _transform,
                  onRetry: () {
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ),
            if (_chromeVisible) _buildNavigation(gold),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color gold) {
    return Material(
      color: _pageBackground,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xFF241A12),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                '$_modeName — صفحة $_page',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _pageTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'الانتقال إلى صفحة',
              icon: Icon(Icons.find_in_page_rounded, color: _headerInk),
              onPressed: _showPagePicker,
            ),
            IconButton(
              tooltip: 'اختيار نمط العرض',
              icon: Icon(Icons.tune_rounded, color: _headerInk),
              onPressed: () => _showModeSheet(context, gold),
            ),
          ],
        ),
      ),
    );
  }

  void _showModeSheet(BuildContext context, Color gold) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8A98D),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'نمط عرض المصحف',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF241A12),
                ),
              ),
              const SizedBox(height: 8),
              for (final entry in [
                (MushafVariantMode.uthmani, 'عثماني Unicode', 'عرض النص العربي مباشرة بخط Amiri كبديل عند تعذر عرض محارف QCF'),
                (MushafVariantMode.musnad, 'المسند', 'حروف المسند مع تثبيت مواضع السطور'),
                (MushafVariantMode.dotless, 'بدون نقاط مع التشكيل', 'إزالة نقاط الحروف مع إبقاء علامات التشكيل'),
                (MushafVariantMode.dotlessPlain, 'بدون نقاط أو تشكيل', 'إزالة نقاط الحروف وعلامات التشكيل من العرض فقط'),
                (MushafVariantMode.kufi, 'رَقّ — كوفي مصحفي مبكر', FontManager.isRaqqFontLoaded ? 'خط Raqq المصحفي؛ يتغير العرض فقط ويبقى نص المصدر محفوظًا' : 'تعذر تحميل الخط؛ سيُستخدم خط بديل دون تغيير نص المصدر'),
                (MushafVariantMode.hieroglyphic, 'هيروغليفي', 'رموز هيروغليفية داخل تخطيط السطور نفسه'),
              ])
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                    _mode == entry.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _mode == entry.$1 ? gold : _pageTextColor.withOpacity(.62),
                  ),
                  title: Text(entry.$2, style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w700, color: _pageTextColor)),
                  subtitle: Text(entry.$3, style: TextStyle(fontFamily: 'Amiri', fontSize: 11, color: _pageTextColor.withOpacity(.78))),
                  onTap: () async {
                    await _setDisplayMode(entry.$1);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(Color gold) {
    return Material(
      color: _pageBackground,
      child: SizedBox(
        height: 54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _jump(_page - 1),
              icon: const Icon(Icons.chevron_right_rounded),
              color: gold,
            ),
            Text(
              '$_page / ${MushafSource.totalPages}',
              style: TextStyle(color: gold, fontWeight: FontWeight.w800),
            ),
            IconButton(
              onPressed: () => _jump(_page + 1),
              icon: const Icon(Icons.chevron_left_rounded),
              color: gold,
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantPage extends StatelessWidget {
  const _VariantPage({
    required this.page,
    required this.mode,
    required this.paper,
    required this.gold,
    required this.transform,
    required this.onRetry,
  });

  final int page;
  final MushafVariantMode mode;
  final Color paper;
  final Color gold;
  final String Function(String) transform;
  final VoidCallback onRetry;

  static int _wordCount(String text) => text.trim().isEmpty ? 0 : text.trim().split(' ').where((word) => word.isNotEmpty).length;

  String get _fontFamily {
    switch (mode) {
      case MushafVariantMode.uthmani:
        return 'Amiri';
      case MushafVariantMode.musnad:
        return 'Musnad';
      case MushafVariantMode.dotless:
      case MushafVariantMode.dotlessPlain:
        return FontManager.isRaqqFontLoaded ? 'Raqq' : 'Amiri';
      case MushafVariantMode.kufi:
        return FontManager.isRaqqFontLoaded ? 'Raqq' : 'Amiri';
      case MushafVariantMode.hieroglyphic:
        return 'NotoSansEgyptianHieroglyphs';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MushafVariantLine>>(
      future: MushafVariantLayoutService.page(page),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: Colors.white54,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تعذر تحميل تخطيط هذه الصفحة. قد تكون بيانات الصفحة غير متاحة أو تالفة.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lines = snapshot.data!;
        final sequenceWordCount = lines.fold<int>(0, (sum, line) => sum + (line.isBlank || line.isSurahHeader ? 0 : _wordCount(line.text)));
        return Container(
          // Match the canonical MushafScreen page frame and outer geometry.
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: paper,
            border: Border.all(color: const Color(0xFF8C6A2D), width: 1.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: paper,
              border: Border.all(
                color: const Color(0xFF8C6A2D).withOpacity(.38),
                width: .7,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Exactly 15 fixed slots: script changes never reflow the page.
                final lineHeight = constraints.maxHeight / 15.0;
                return Column(
                  children: [
                    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++)
                      SizedBox(
                        height: lineHeight,
                        width: double.infinity,
                        child: lines[lineIndex].isBlank
                            ? const SizedBox.shrink()
                            : _FixedMushafLine(
                                line: lines[lineIndex],
                                transform: transform,
                                fontFamily: _fontFamily,
                                fontFeatures: FontManager.isRaqqFontLoaded &&
                                        (mode == MushafVariantMode.dotless ||
                                            mode == MushafVariantMode.dotlessPlain)
                                    ? const [FontFeature.enable('ss01')]
                                    : const [],
                                gold: gold,
                                sequenceWordCount: sequenceWordCount,
                                sequenceWordOffset: lines.take(lineIndex).fold<int>(
                                  0,
                                  (sum, previous) => sum + (previous.isBlank || previous.isSurahHeader ? 0 : _wordCount(previous.text)),
                                ),
                              ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FixedMushafLine extends StatelessWidget {
  const _FixedMushafLine({
    required this.line,
    required this.transform,
    required this.fontFamily,
    required this.fontFeatures,
    required this.gold,
    required this.sequenceWordCount,
    required this.sequenceWordOffset,
  });

  final MushafVariantLine line;
  final String Function(String) transform;
  final String fontFamily;
  final List<FontFeature> fontFeatures;
  final Color gold;
  final int sequenceWordCount;
  final int sequenceWordOffset;

  @override
  Widget build(BuildContext context) {
    if (line.isSurahHeader) {
      // Decorative surah plaque with the canonical Mushaf double-frame motif.
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8C6A2D), width: 1.0),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8C6A2D).withOpacity(.42),
                width: .6,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              line.surah == null ? '' : getSurahNameArabic(line.surah!),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontFamily: FontManager.isRaqqSuraFontLoaded ? 'RaqqSura' : 'Amiri',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: gold,
              ),
            ),
          ),
        ),
      );
    }

    if (line.segments.isEmpty) return const SizedBox.shrink();

    final tokens = <String>[];
    for (final segment in line.segments) {
      if (segment.startsWith('﴿') && segment.endsWith('﴾') && segment.length > 2) {
        // Keep the package's supported Quranic ayah-number delimiters.
        // Replacing them with ۞ can render as empty squares on fonts that
        // do not contain that ornamental Unicode glyph.
        final marker = segment.substring(1, segment.length - 1);
        tokens.add('﴿$marker﴾');
      } else {
        final converted = transform(segment);
        if (converted.isNotEmpty) tokens.add(converted);
      }
    }
    final text = tokens.join(' ');
    if (text.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = TextStyle(
          fontFamily: fontFamily,
          fontFeatures: fontFeatures,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: gold,
          height: 1.0,
        );
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.rtl,
          maxLines: 1,
        )..layout();
        final scaleX = painter.width <= constraints.maxWidth
            ? 1.0
            : constraints.maxWidth / painter.width;

        return Center(
          child: Transform.scale(
            scaleX: scaleX,
            alignment: Alignment.center,
            child: QuranWaveText(
              text: text,
              importanceText: line.text,
              style: style,
              sequenceWordCount: sequenceWordCount,
              sequenceWordOffset: sequenceWordOffset,
              textAlign: line.centered ? WrapAlignment.center : WrapAlignment.start,
              singleLine: true,
            ),
          ),
        );
      },
    );
  }
}
