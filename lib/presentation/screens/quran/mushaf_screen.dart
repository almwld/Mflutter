import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/mushaf_source.dart';
import '../../../services/reading_progress_service.dart';
import '../../../services/ayah_coordinate_service.dart';
import 'mushaf_variant_screen.dart';
import '../../widgets/quran/living_ayah_painter.dart';
import '../../widgets/quran/mushaf_nebula.dart';
import '../../../services/quran_page_theme_service.dart';

/// قارئ المصحف — تخطيط صفحات المصحف المدني 604 صفحة.
/// يعتمد على QCF Hafs لضمان ثبات مواضع الأسطر والآيات وحدود الصفحات،
/// بدلاً من إعادة توزيع النص اعتماداً على عدد الأحرف.
class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key, this.initialPage = 1});

  final int initialPage;

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _mushafViewportKey = GlobalKey();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  List<HighlightVerse> _highlights = const [];
  late final AnimationController _livingPulse;
  late final AnimationController _livingGlow;
  late final TransformationController _mushafZoomController;
  bool _zoomMode = false;
  QuranPageTheme _pageTheme = QuranPageTheme.paper;

  static const _paper = Color(0xFFF8F1E4);
  static const _ink = Color(0xFF241A12);
  // لون نص المصحف: ذهبي فاخر، مع درجة أعمق للنهار لرفع التباين على ورق المصحف.
  static const _quranGoldLight = Color(0xFFD49A16);
  static const _quranGoldDark = Color(0xFFFFD45A);
  static const _frame = Color(0xFF8C6A2D);

  @override
  void initState() {
    super.initState();
    final page = MushafSource.normalizePage(widget.initialPage);
    _currentPage.value = page;
    _pageController = PageController(initialPage: page - 1);
    _livingPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _livingGlow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _mushafZoomController = TransformationController();
    _restoreLastPage();
    _restorePageTheme();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _livingPulse.dispose();
    _livingGlow.dispose();
    _mushafZoomController.dispose();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _startLivingEffects() {
    if (_livingPulse.isAnimating && _livingGlow.isAnimating) return;
    _livingPulse.repeat();
    _livingGlow.repeat(reverse: true);
  }

  void _stopLivingEffects() {
    _livingPulse.stop();
    _livingGlow.stop();
    _livingPulse.value = 0;
    _livingGlow.value = 0;
  }

  Future<void> _restorePageTheme() async { final value = await QuranPageThemeService.load(); if (mounted) setState(() => _pageTheme = value); }

  Future<void> _showPageThemePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF8F1E4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مظهر صفحات المصحف',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF241A12),
                ),
              ),
              const SizedBox(height: 10),
              for (final theme in QuranPageTheme.values)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: QuranPageThemeService.background(theme),
                    child: Icon(
                      _pageTheme == theme
                          ? Icons.check_rounded
                          : Icons.menu_book_rounded,
                      color: QuranPageThemeService.text(theme),
                    ),
                  ),
                  title: Text(
                    QuranPageThemeService.label(theme),
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      color: Color(0xFF241A12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: _pageTheme == theme
                      ? const Icon(Icons.check_circle, color: Color(0xFF8C6A2D))
                      : null,
                  onTap: () async {
                    setState(() => _pageTheme = theme);
                    await QuranPageThemeService.save(theme);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restoreLastPage() async {
    final last = await ReadingProgressService.getLastPage(fallback: _currentPage.value);
    if (!mounted || last == _currentPage.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _goToPage(last);
    });
  }

  void _goToPage(int page) {
    final target = MushafSource.normalizePage(page);
    _pageController.animateToPage(
      target - 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _showPagePicker() {
    final controller = TextEditingController(text: '${_currentPage.value}');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: '1 - 604'),
          onSubmitted: (_) {
            final value = int.tryParse(controller.text);
            if (value != null) {
              Navigator.pop(context);
              _goToPage(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context);
              if (value != null) _goToPage(value);
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }


  void _showSurahIndex() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .78,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFB8A98D),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'فهرس السور',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'اختر سورة للانتقال إلى أول آياتها',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 11,
                  color: Color(0xFF766A57),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                  itemCount: MushafSource.totalSurahs,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final surah = index + 1;
                    final page = MushafSource.pageForVerse(surah, 1);
                    final name = getSurahNameArabic(surah);
                    return Material(
                      color: const Color(0xFFF2E9D8),
                      borderRadius: BorderRadius.circular(15),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _frame),
                          ),
                          child: Text(
                            '$surah',
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        subtitle: Text(
                          'صفحة $page',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 11,
                            color: Color(0xFF766A57),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_left_rounded,
                          color: _frame,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _goToPage(page);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAyahCoordinate(int surah, int ayah, Offset position) async {
    final renderObject = _mushafViewportKey.currentContext?.findRenderObject();
    final box = renderObject is RenderBox ? renderObject : null;
    if (box == null || box.size.isEmpty) return;

    final viewportPoint = box.globalToLocal(position);
    final scenePoint = _mushafZoomController.toScene(viewportPoint);

    await AyahCoordinateService.save(
      page: _currentPage.value,
      surah: surah,
      ayah: ayah,
      x: scenePoint.dx,
      y: scenePoint.dy,
      width: box.size.width,
      height: box.size.height,
    );
  }

  void _showAyahMenu(int surah, int ayah, Offset position) {
    final page = _currentPage.value;
    setState(() {
      _highlights = [
        HighlightVerse(
          surah: surah,
          verseNumber: ayah,
          page: page,
          color: const Color(0xFFC8A85B),
        ),
      ];
    });
    _startLivingEffects();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final local = overlay.globalToLocal(position);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(local.dx, local.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: 'bookmark', child: Text('حفظ الآية')),
        PopupMenuItem(value: 'clear', child: Text('إلغاء التحديد')),
      ],
    ).then((action) async {
      if (!mounted) return;
      if (action == 'bookmark') {
        final text = MushafSource.verse(surah, ayah);
        await BookmarkService.addBookmark(surah, ayah, text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الآية في العلامات المرجعية')),
          );
        }
      }
      if (mounted) {
        setState(() => _highlights = const []);
        _stopLivingEffects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranGold = _pageTheme == QuranPageTheme.paper ? (isDark ? _quranGoldDark : _quranGoldLight) : QuranPageThemeService.text(_pageTheme);
    final pageBackground = QuranPageThemeService.background(_pageTheme);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: MushafNebula(),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_livingPulse, _livingGlow]),
                builder: (context, child) {
                  final selected = _highlights.isNotEmpty;
                  final great = selected && _isGreatVerse(_highlights.first);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      child!,
                      IgnorePointer(
                        child: CustomPaint(
                          painter: LivingAyahPainter(
                            pulse: _livingPulse.value,
                            glow: selected ? .72 + _livingGlow.value * .28 : 0,
                            isGreatVerse: great,
                            isActive: selected,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: RepaintBoundary(
                  child: InteractiveViewer(
                  key: _mushafViewportKey,
                  transformationController: _mushafZoomController,
                  panEnabled: _zoomMode,
                  scaleEnabled: _zoomMode,
                  minScale: 1.0,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(120),
                  constrained: true,
                  child: QuranPageView(
                  pageController: _pageController,
                  highlights: _highlights,
                  scrollDirection: Axis.horizontal,
                  pageSnapping: true,
                  pagePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  // QCF يحتفظ بخطوط الصفحة الخاصة بكل صفحة؛ هنا نغيّر اللون فقط.
                  // بذلك يبقى تخطيط حفص ثابتًا ولا يتأثر بتحويل النص إلى Text عادي.
                  ayahStyle: TextStyle(
                    color: quranGold,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: quranGold.withValues(alpha: 0.28),
                        blurRadius: 1.8,
                      ),
                    ],
                  ),
                  customHighlightDecoration: (highlightColor) {
                    final pulse = 0.5 + 0.5 * _livingGlow.value;
                    final isGreat = _highlights.isNotEmpty &&
                        _isGreatVerse(_highlights.first);
                    final opacity = isGreat
                        ? 0.12 + pulse * 0.22
                        : 0.10 + pulse * 0.12;
                    return BoxDecoration(
                      color: highlightColor.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(isGreat ? 7 : 4),
                      border: Border.all(
                        color: highlightColor.withOpacity(
                          isGreat ? 0.28 + pulse * 0.34 : 0.12 + pulse * 0.18,
                        ),
                        width: isGreat ? 1.2 : 0.8,
                      ),
                      boxShadow: isGreat
                          ? [
                              BoxShadow(
                                color: highlightColor.withOpacity(0.12 + pulse * 0.12),
                                blurRadius: 8 + pulse * 8,
                              ),
                            ]
                          : null,
                    );
                  },
                  pageBackgroundBuilder: (context, pageContent) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: pageBackground,
                        border: Border.all(color: _frame, width: 1.6),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(blurRadius: 10, spreadRadius: 1, offset: Offset(0, 2), color: Colors.black26)],
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: pageBackground, border: Border.all(color: _frame.withOpacity(.38), width: .7)),
                        child: pageContent,
                      ),
                    );
                  },
                  onPageChanged: (pageNumber) {
                    final page = MushafSource.normalizePage(pageNumber);
                    _currentPage.value = page;
                    if (_zoomMode) {
                      _mushafZoomController.value = Matrix4.identity();
                    }
                    ReadingProgressService.saveLastPage(page);
                    if (_highlights.isNotEmpty) {
                      setState(() => _highlights = const []);
                      _stopLivingEffects();
                    }
                  },
                  onDoubleTap: (surah, ayah) {
                    final page = _currentPage.value;
                    setState(() {
                      _highlights = [
                        HighlightVerse(
                          surah: surah,
                          verseNumber: ayah,
                          page: page,
                          color: quranGold,
                        ),
                      ];
                    });
                    _startLivingEffects();
                  },
                  onLongPressStart: (surah, ayah, details) {
                    _saveAyahCoordinate(surah, ayah, details.globalPosition);
                    _showAyahMenu(surah, ayah, details.globalPosition);
                  },
                  ),
                ),
                ),
              ),
            ),
            _topOverlay(),
            Positioned(
              top: 48,
              right: 18,
              child: _roundButton(
                icon: Icons.palette_outlined,
                onPressed: _showPageThemePicker,
              ),
            ),
            _pageProgress(),
            _bottomOverlay(),
          ],
        ),
      ),
    );
  }

  bool _isGreatVerse(HighlightVerse verse) {
    const great = {
      '1:1', '2:255', '3:190', '24:35',
      '36:1', '55:13', '67:1', '112:1',
    };
    return great.contains('${verse.surah}:${verse.verseNumber}');
  }

  Widget _topOverlay() {
    return Positioned(
      top: 8,
      left: 18,
      right: 18,
      child: IgnorePointer(
        child: ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (_, page, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _badge('الجزء ${MushafSource.juzForPage(page)}'),
                    const SizedBox(width: 6),
                    _badge(MushafSource.hizbTextForPage(page)),
                  ],
                ),
                _badge('المصحف المدني'),
              ],
            );
          },
        ),
      ),
    );
  }

  /// شريط تنقّل سريع بين جميع صفحات المصحف.
  /// التنقير على الخط أو سحب النقطة يقفز مباشرة إلى الصفحة المقابلة.
  Widget _pageProgress() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 56,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (_, page, __) {
          final maxPage = MushafSource.totalPages;
          return Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _paper.withOpacity(0.94),
                border: Border.all(color: _frame.withOpacity(0.72), width: 0.8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(
                    '$maxPage',
                    style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        activeTrackColor: _quranGoldDark,
                        inactiveTrackColor: _frame.withOpacity(0.28),
                        thumbColor: _quranGoldDark,
                        overlayColor: _quranGoldDark.withOpacity(0.16),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                      ),
                      child: Slider(
                        min: 1,
                        max: maxPage.toDouble(),
                        divisions: maxPage - 1,
                        value: page.clamp(1, maxPage).toDouble(),
                        semanticFormatterCallback: (value) => 'صفحة ${value.round()} من $maxPage',
                        onChanged: (value) {
                          _currentPage.value = value.round();
                        },
                        onChangeEnd: (value) {
                          _goToPage(value.round());
                        },
                      ),
                    ),
                  ),
                  Text(
                    '$page',
                    style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bottomOverlay() {
    return Positioned(
      bottom: 8,
      left: 18,
      right: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundButton(
            icon: Icons.chevron_right_rounded,
            onPressed: () => _goToPage(_currentPage.value - 1),
          ),
          _roundButton(
            icon: _zoomMode ? Icons.zoom_out_map_rounded : Icons.zoom_in_rounded,
            onPressed: () {
              setState(() => _zoomMode = !_zoomMode);
            },
          ),
          _roundButton(
            icon: Icons.center_focus_strong_rounded,
            onPressed: () {
              _mushafZoomController.value = Matrix4.identity();
            },
          ),
          _roundButton(
            icon: Icons.menu_book_rounded,
            onPressed: _showSurahIndex,
          ),
          _roundButton(
            icon: Icons.tune_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MushafVariantScreen(
                    initialPage: _currentPage.value,
                  ),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: _showPagePicker,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (_, page, __) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _paper.withOpacity(0.96),
                  border: Border.all(color: _frame, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'صفحة $page / ${MushafSource.totalPages}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          _roundButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => _goToPage(_currentPage.value + 1),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: _paper.withOpacity(0.94),
        border: Border.all(color: _frame, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: _paper.withOpacity(0.96),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: _ink, size: 24),
        ),
      ),
    );
  }
}

