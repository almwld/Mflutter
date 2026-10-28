import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/mushaf_source.dart';
import 'quran/mushaf_screen.dart';
import 'quran/mushaf_variant_screen.dart';

/// الفهرس الحقيقي للمصحف المدني: 114 سورة مرتبطة بصفحات QCF/Hafs.
class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});
  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  int _tab = 0;
  int? _lastVariantPage;

  @override
  void initState() {
    super.initState();
    _restoreLastVariantPage();
  }

  Future<void> _restoreLastVariantPage() async {
    final preferences = await SharedPreferences.getInstance();
    final page = preferences.getInt('mudabbir_mushaf_variant_last_page');
    if (!mounted || page == null) return;
    setState(() => _lastVariantPage = MushafSource.normalizePage(page));
  }

  Future<void> _openVariantPage(int page) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => MushafVariantScreen(initialPage: page)),
    );
    await _restoreLastVariantPage();
  }

  String _normalizeArabicSearch(String value) => value
      .replaceAllMapped(
        RegExp(r'[٠-٩۰-۹]'),
        (match) {
          final code = match.group(0)!.codeUnitAt(0);
          final digit = code >= 0x06F0 && code <= 0x06F9
              ? code - 0x06F0
              : code - 0x0660;
          return String.fromCharCode(0x30 + digit);
        },
      )
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static const _background = Color(0xFF0B0D12);
  static const _surface = Color(0xFF15181F);
  static const _gold = Color(0xFFD8B65A);
  static const _muted = Color(0xFF8B919C);

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _normalizeArabicSearch(_query);
    final items = List<int>.generate(MushafSource.totalSurahs, (i) => i + 1)
        .where((number) => query.isEmpty ||
            _normalizeArabicSearch(getSurahNameArabic(number)).contains(query) ||
            '$number'.contains(query))
        .toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text('فهرس المصحف',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'فتح عرض صفحات QCF الأصلي',
            icon: const Icon(Icons.menu_book_rounded, color: _gold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MushafScreen(initialPage: 1, restoreLastPage: false),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('السور', style: TextStyle(fontFamily: 'Amiri'))),
              ButtonSegment(value: 1, label: Text('الأجزاء', style: TextStyle(fontFamily: 'Amiri'))),
              ButtonSegment(value: 2, label: Text('الأحزاب', style: TextStyle(fontFamily: 'Amiri'))),
            ],
            selected: {_tab},
            onSelectionChanged: (value) => setState(() => _tab = value.first),
          ),
        ),
        if (_lastVariantPage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openVariantPage(_lastVariantPage!),
                icon: const Icon(Icons.play_arrow_rounded, color: _gold),
                label: Text(
                  'متابعة القراءة — صفحة $_lastVariantPage',
                  style: const TextStyle(fontFamily: 'Amiri', color: _gold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF665226)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        if (_tab == 0)
          Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            controller: _search,
            textDirection: TextDirection.rtl,
            onChanged: (value) => setState(() => _query = value),
            style: const TextStyle(fontFamily: 'Amiri', color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ابحث باسم السورة أو رقمها',
              hintStyle: const TextStyle(fontFamily: 'Amiri', color: _muted),
              prefixIcon: const Icon(Icons.search_rounded, color: _gold),
              suffixIcon: query.isEmpty ? null : IconButton(
                tooltip: 'مسح البحث',
                onPressed: () { _search.clear(); setState(() => _query = ''); },
                icon: const Icon(Icons.close_rounded, color: _muted),
              ),
              filled: true, fillColor: _surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF292D35))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF292D35))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _gold)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(textDirection: TextDirection.rtl, children: [
            Text(
              _tab == 0
                  ? (query.isEmpty ? '114 سورة' : items.length.toString() + ' نتيجة')
                  : _tab == 1 ? '30 جزءًا' : '60 حزبًا',
              style: const TextStyle(fontFamily: 'Amiri', color: _muted, fontSize: 12),
            ),
            const Spacer(),
            const Text('حفص • 604 صفحة',
              style: TextStyle(fontFamily: 'Amiri', color: _gold, fontSize: 12)),
          ]),
        ),
        Expanded(child: _tab == 0 ? ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final number = items[index];
            final name = getSurahNameArabic(number);
            final page = MushafSource.pageForVerse(number, 1);
            return Material(
              color: _surface, borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openVariantPage(page),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(textDirection: TextDirection.rtl, children: [
                    Container(
                      width: 46, height: 46, alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF665226)),
                        color: const Color(0xFF1D1A13)),
                      child: Text('$number',
                        style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(name, textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 20,
                            fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('أول السورة • صفحة $page', textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 11, color: _muted)),
                      ],
                    )),
                    const Icon(Icons.chevron_left_rounded, color: _gold),
                  ]),
                ),
              ),
            );
          },
        )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
                itemCount: _tab == 1 ? MushafSource.totalJuz : MushafSource.totalHizb,
                separatorBuilder: (_, __) => const SizedBox(height: 7),
                itemBuilder: (context, index) {
                  final number = index + 1;
                  final page = _tab == 1
                      ? MushafSource.firstPageForJuz(number)
                      : MushafSource.firstPageForHizb(number);
                  final title = _tab == 1 ? 'الجزء ' + number.toString() : 'الحزب ' + number.toString();
                  final extra = _tab == 1
                      ? 'يبدأ من صفحة ' + page.toString()
                      : 'يبدأ من صفحة ' + page.toString() + ' • ' + MushafSource.hizbTextForPage(page);
                  return Material(
                    color: _surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openVariantPage(page),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1D1A13),
                          child: Icon(
                            _tab == 1 ? Icons.auto_stories_rounded : Icons.bookmark_outline_rounded,
                            color: _gold,
                          ),
                        ),
                        title: Text(title, style: const TextStyle(fontFamily: 'Amiri', color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(extra, style: const TextStyle(fontFamily: 'Amiri', color: _muted, fontSize: 10)),
                        trailing: const Icon(Icons.chevron_left_rounded, color: _gold),
                      ),
                    ),
                  );
                },
              ),
        ),
      ]),
    );
  }
}
