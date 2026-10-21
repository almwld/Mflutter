import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../../services/mushaf_source.dart';
import '../../../services/mushaf_variant_layout_service.dart';
import '../../../services/quran_page_theme_service.dart';
import '../../../services/text_transformer.dart';
import '../../widgets/quran_wave_text.dart';

enum MushafVariantMode { musnad, dotless, kufi, hieroglyphic }

class MushafVariantScreen extends StatefulWidget {
  const MushafVariantScreen({super.key, required this.initialPage});
  final int initialPage;

  @override
  State<MushafVariantScreen> createState() => _MushafVariantScreenState();
}

class _MushafVariantScreenState extends State<MushafVariantScreen> {
  late final PageController _controller;
  int _page = 1;
  MushafVariantMode _mode = MushafVariantMode.musnad;

  static const _paper = Color(0xFFF8F1E4);
  Color get _pageBackground => QuranPageThemeService.background(_pageTheme);
  Color get _pageTextColor => QuranPageThemeService.text(_pageTheme);
  Color get _headerInk => _pageTheme == QuranPageTheme.paper
      ? const Color(0xFF241A12)
      : _pageTextColor;
  QuranPageTheme _pageTheme = QuranPageTheme.paper;
  bool _systemBarsVisible = false;

  Future<void> _setImmersiveMode(bool immersive) async {
    await SystemChrome.setEnabledSystemUIMode(
      immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    if (mounted) setState(() => _systemBarsVisible = !immersive);
  }

  Future<void> _toggleSystemBars() async {
    await _setImmersiveMode(_systemBarsVisible);
  }

  @override
  void initState() {
    super.initState();
    _page = MushafSource.normalizePage(widget.initialPage);
    _controller = PageController(initialPage: _page - 1);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _restorePageTheme();
  }

  Future<void> _restorePageTheme() async {
    final theme = await QuranPageThemeService.load();
    if (mounted) setState(() => _pageTheme = theme);
  }

  @override
  void dispose() {
    // Restore the app's normal system bars when leaving Mushaf reading.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  String _transform(String text) {
    switch (_mode) {
      case MushafVariantMode.musnad:
        return TextTransformer.toMusnad(text);
      case MushafVariantMode.dotless:
        return TextTransformer.toDotless(text);
      case MushafVariantMode.kufi:
        return TextTransformer.toDotless(text);
      case MushafVariantMode.hieroglyphic:
        return TextTransformer.toHieroglyphic(text);
    }
  }

  String get _modeName {
    switch (_mode) {
      case MushafVariantMode.musnad:
        return 'المسند';
      case MushafVariantMode.dotless:
        return 'بدون نقاط';
      case MushafVariantMode.kufi:
        return 'كوفي';
      case MushafVariantMode.hieroglyphic:
        return 'هيروغليفي';
    }
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
            _buildHeader(gold),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: MushafSource.totalPages,
                onPageChanged: (index) => setState(() => _page = index + 1),
                itemBuilder: (_, index) => _VariantPage(
                  page: index + 1,
                  mode: _mode,
                  paper: _pageBackground,
                  gold: gold,
                  transform: _transform,
                ),
              ),
            ),
            _buildNavigation(gold),
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
                style: const TextStyle(
                  color: Color(0xFF241A12),
                  fontWeight: FontWeight.w800,
                ),
              ),
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
      backgroundColor: _paper,
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
                (MushafVariantMode.musnad, 'المسند', 'حروف المسند مع تثبيت مواضع السطور'),
                (MushafVariantMode.dotless, 'بدون نقاط', 'إزالة نقاط الحروف مع الحفاظ على النص'),
                (MushafVariantMode.kufi, 'كوفي تجريبي', 'عرض تقريبي؛ لا يتوفر ملف خط كوفي مستقل حالياً'),
                (MushafVariantMode.hieroglyphic, 'هيروغليفي', 'رموز هيروغليفية داخل تخطيط السطور نفسه'),
              ])
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                    _mode == entry.$1 ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _mode == entry.$1 ? gold : const Color(0xFF8A7B61),
                  ),
                  title: Text(entry.$2, style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w700)),
                  subtitle: Text(entry.$3, style: const TextStyle(fontFamily: 'Amiri', fontSize: 11)),
                  onTap: () {
                    setState(() => _mode = entry.$1);
                    Navigator.pop(sheetContext);
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
  });

  final int page;
  final MushafVariantMode mode;
  final Color paper;
  final Color gold;
  final String Function(String) transform;

  static int _wordCount(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\\s+')).length;

  String get _fontFamily {
    switch (mode) {
      case MushafVariantMode.musnad:
        return 'Musnad';
      case MushafVariantMode.dotless:
        return 'Amiri';
      case MushafVariantMode.kufi:
        return 'Amiri';
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
          return const Center(
            child: Text(
              'بيانات تخطيط المصحف غير متوفرة بعد. أعد بناء التطبيق لتوليدها.',
              textAlign: TextAlign.center,
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
    required this.gold,
    required this.sequenceWordCount,
    required this.sequenceWordOffset,
  });

  final MushafVariantLine line;
  final String Function(String) transform;
  final String fontFamily;
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
                fontFamily: 'Amiri',
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
      final marker = RegExp('^﴿([0-9]+)﴾$').firstMatch(segment);
      if (marker != null) {
        tokens.add('۞' + marker.group(1)! + '۞');
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
            ),
          ),
        );
      },
    );
  }
}
