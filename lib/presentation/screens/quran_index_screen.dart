import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import '../services/mushaf_source.dart';
import 'quran/mushaf_screen.dart';

/// الفهرس الحقيقي للمصحف المدني: 114 سورة مرتبطة بصفحات QCF/Hafs.
class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});
  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  static const _background = Color(0xFF0B0D12);
  static const _surface = Color(0xFF15181F);
  static const _gold = Color(0xFFD8B65A);
  static const _muted = Color(0xFF8B919C);

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();
    final items = List<int>.generate(MushafSource.totalSurahs, (i) => i + 1)
        .where((number) => query.isEmpty ||
            getSurahNameArabic(number).contains(query) ||
            '$number'.contains(query))
        .toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text('فهرس المصحف',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(children: [
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
            Text(query.isEmpty ? '114 سورة' : '${items.length} نتيجة',
              style: const TextStyle(fontFamily: 'Amiri', color: _muted, fontSize: 12)),
            const Spacer(),
            const Text('حفص • 604 صفحة',
              style: TextStyle(fontFamily: 'Amiri', color: _gold, fontSize: 12)),
          ]),
        ),
        Expanded(child: ListView.separated(
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
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MushafScreen(initialPage: page))),
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
        )),
      ]),
    );
  }
}
