import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/mushaf_source.dart';
import '../../../services/reading_progress_service.dart';
import 'mushaf_variant_screen.dart';
import '../../widgets/quran/living_ayah_painter.dart';

/// قارئ المصحف — تخطيط صفحات المصحف المدني 604 صفحة.
/// يعتمد على QCF Hafs لضمان ثبات مواضع الأسطر والآيات وحدود الصفحات،
/// بدلاً من إعادة توزيع النص اعتماداً على عدد الأحرف.
class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key, this.initialPage = 1});

  final int initialPage;

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(1);
  List<HighlightVerse> _highlights = const [];
  late final AnimationController _livingPulse;
  late final AnimationController _livingGlow;

  static const _paper = Color(0xFFF8F1E4);
  static const _ink = Color(0xFF241A12);
  // لون نص المصحف: ذهبي فاخر، مع درجة أعمق للنهار لرفع التباين على ورق المصحف.
  static const _quranGoldLight = Color(0xFF9A6B00);
  static const _quranGoldDark = Color(0xFFE2B84A);
  static const _frame = Color(0xFF8C6A2D);
  static const _frameLight = Color(0xFFC8A85B);

  @override
  void initState() {
    super.initState();
    final page = MushafSource.normalizePage(widget.initialPage);
    _currentPage.value = page;
    _pageController = PageController(initialPage: page - 1);
    _livingPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _livingGlow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _restoreLastPage();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _livingPulse.dispose();
    _livingGlow.dispose();
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
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
      if (mounted) setState(() => _highlights = const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranGold = isDark ? _quranGoldDark : _quranGoldLight;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF17130F),
      body: SafeArea(
        child: Stack(
          children: [
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
                            glow: selected ? .72 + _livingGlow.value * .28 : .18,
                            isGreatVerse: great,
                            isActive: true,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                  ),
                  customHighlightDecoration: (highlightColor) {
                    return BoxDecoration(
                      color: highlightColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                    );
                  },
                  pageBackgroundBuilder: (context, pageContent) {
                    return DecoratedBox(
                      decoration: const BoxDecoration(color: _paper),
                      child: pageContent,
                    );
                  },
                  onPageChanged: (pageNumber) {
                    final page = MushafSource.normalizePage(pageNumber);
                    _currentPage.value = page;
                    ReadingProgressService.saveLastPage(page);
                    if (_highlights.isNotEmpty) {
                      setState(() => _highlights = const []);
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
                  },
                  onLongPress: (surah, ayah) {
                    _showAyahMenu(surah, ayah, const Offset(0, 0));
                  },
                ),
              ),
            ),
            _topOverlay(),
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
                _badge('الجزء ${MushafSource.juzForPage(page)}'),
                _badge('المصحف المدني'),
              ],
            );
          },
        ),
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

