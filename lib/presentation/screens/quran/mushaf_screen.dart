import 'package:flutter/material.dart';
import '../../../services/page_builder_service.dart';
import '../../../services/bookmark_service.dart';
import '../../../domain/models/quran_page.dart';
import '../../widgets/surah_banner.dart';
import '../../widgets/ayah_number.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;
  bool _showBars = true;
  int? _highlightedAyah;
  Map<int, List<AyahData>> _pages = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    _pages = await PageBuilderService.buildPages();
    setState(() => _loading = false);
  }

  void _toggleHighlight(int ayahNum) {
    setState(() => _highlightedAyah = (_highlightedAyah == ayahNum) ? null : ayahNum);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB8860B))),
      );
    }

    final pageKeys = _pages.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Stack(
          children: [
            // ═══════════════════════════════════
            // المصحف
            // ═══════════════════════════════════
            GestureDetector(
              onTap: () => setState(() => _showBars = !_showBars),
              child: PageView.builder(
                controller: _pageController,
                itemCount: pageKeys.length,
                reverse: true,
                onPageChanged: (i) => setState(() {
                  _currentPage = pageKeys[i];
                  _highlightedAyah = null;
                }),
                itemBuilder: (context, index) {
                  final pageNum = pageKeys[index];
                  final verses = _pages[pageNum] ?? [];
                  return _buildCompletePage(pageNum, verses);
                },
              ),
            ),

            // ═══════════════════════════════════
            // شريط علوي
            // ═══════════════════════════════════
            if (_showBars)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: const Color(0xFFF5F0E8).withOpacity(0.95),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الجزء ${PageBuilderService.getJuz(_currentPage)}',
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 15, color: Color(0xFF8B6914))),
                      Text(_getPageSurahName(_currentPage),
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                    ],
                  ),
                ),
              ),

            // ═══════════════════════════════════
            // شريط سفلي
            // ═══════════════════════════════════
            if (_showBars)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFF5F0E8).withOpacity(0.95),
                  child: Center(
                    child: Text('صفحة $_currentPage',
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 14, color: Color(0xFF8B6914))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// بناء صفحة كاملة — إطار + بانر + آيات
  Widget _buildCompletePage(int pageNum, List<AyahData> verses) {
    final surahName = _getPageSurahName(pageNum);
    final isNewSurah = verses.isNotEmpty && verses.first.ayahNumber == 1;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFB8860B).withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // بانر السورة
            if (isNewSurah) SurahBanner(surahName: surahName, showBismillah: pageNum != 1),

            // الآيات
            Expanded(
              child: ListView.builder(
                itemCount: verses.length,
                itemBuilder: (context, i) {
                  final ayah = verses[i];
                  final isHighlighted = _highlightedAyah == ayah.ayahNumber;

                  return GestureDetector(
                    onTap: () => _toggleHighlight(ayah.ayahNumber),
                    onLongPress: () async {
                      await BookmarkService.addBookmark(ayah.surahNumber, ayah.ayahNumber, ayah.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ تمت الإضافة للمفضلة'), backgroundColor: Color(0xFFFFD700)),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      decoration: BoxDecoration(
                        color: isHighlighted ? const Color(0xFFFFD700).withOpacity(0.25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1810),
                            height: 2.0,
                          ),
                          children: [
                            TextSpan(text: ayah.text),
                            WidgetSpan(child: AyahNumber(number: ayah.ayahNumber)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageSurahName(int page) {
    final verses = _pages[page];
    if (verses == null || verses.isEmpty) return '';
    return PageBuilderService.getSurahName(verses.first.surahNumber);
  }
}
