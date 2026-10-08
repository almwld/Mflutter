import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../../../services/mushaf_source.dart';
import '../../../services/mushaf_variant_layout_service.dart';
import '../../../services/text_transformer.dart';

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
  static const _gold = Color(0xFF9A6B00);
  static const _darkGold = Color(0xFFE2B84A);

  @override
  void initState() {
    super.initState();
    _page = MushafSource.normalizePage(widget.initialPage);
    _controller = PageController(initialPage: _page - 1);
  }

  @override
  void dispose() {
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? _darkGold : _gold;

    return Scaffold(
      backgroundColor: const Color(0xFF17130F),
      body: SafeArea(
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
                  paper: _paper,
                  gold: gold,
                  transform: _transform,
                ),
              ),
            ),
            _buildNavigation(gold),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color gold) {
    return Material(
      color: _paper,
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
              icon: Icon(Icons.tune_rounded, color: gold),
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
                (MushafVariantMode.musnad, 'المسند', 'النص العربي بحروف المسند'),
                (MushafVariantMode.dotless, 'بدون نقاط', 'إزالة نقاط الحروف مع الحفاظ على النص'),
                (MushafVariantMode.kufi, 'كوفي تجريبي', 'عرض تقريبي؛ لا يتوفر ملف خط كوفي مستقل حالياً'),
                (MushafVariantMode.hieroglyphic, 'هيروغليفي', 'تحويل العرض إلى الرموز الهيروغليفية'),
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
      color: _paper,
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final lineHeight = constraints.maxHeight / 15.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              color: paper,
              child: Column(
                children: [
                  for (final line in lines)
                    SizedBox(
                      height: lineHeight,
                      width: double.infinity,
                      child: line.isBlank
                          ? const SizedBox.shrink()
                          : _FixedMushafLine(
                              line: line,
                              transform: transform,
                              fontFamily: _fontFamily,
                              gold: gold,
                            ),
                    ),
                ],
              ),
            );
          },
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
  });

  final MushafVariantLine line;
  final String Function(String) transform;
  final String fontFamily;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    if (line.isSurahHeader) {
      return Center(
        child: Text(
          line.surah == null ? '' : getSurahNameArabic(line.surah!),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: gold,
          ),
        ),
      );
    }

    final text = transform(line.text);
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
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: line.centered ? TextAlign.center : TextAlign.right,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: style,
            ),
          ),
        );
      },
    );
  }
}
