import 'package:flutter/material.dart';
import '../../services/quran_loader_service.dart';
import '../../services/mushaf_source.dart';
import '../../domain/entities/verse.dart';
import 'quran/mushaf_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});
  @override State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _controller = TextEditingController();
  List<Ayah> _results = const [];
  List<Ayah> _ayahs = const [];
  bool _searching = false;
  String? _error;

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      if (mounted) setState(() => _ayahs = ayahs);
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذر تحميل فهرس القرآن: $e');
    }
  }

  String _normalize(String value) {
    return value
      .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[ۖۗۚۛۙۜ۞﴿﴾.,،؛:!?]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  }

  Future<void> _search(String raw) async {
    final q = raw.trim();
    if (q.isEmpty || _ayahs.isEmpty) return;
    setState(() { _searching = true; _error = null; });
    final n = _normalize(q);
    final ref = RegExp(r'^(\d{1,3})\s*[:/.-]\s*(\d{1,3})$').firstMatch(q);
    final List<Ayah> hits;
    if (ref != null) {
      final s = int.parse(ref.group(1)!); final a = int.parse(ref.group(2)!);
      hits = _ayahs.where((v) => v.surahNumber == s && v.ayahNumber == a).toList();
    } else {
      final queryWords = n.split(' ').where((w) => w.length >= 2).toList();
      hits = _ayahs.where((v) {
        final text = _normalize(v.text);
        return text.contains(n) || (queryWords.isNotEmpty && queryWords.every(text.contains));
      }).take(100).toList();
    }
    if (mounted) setState(() { _results = hits; _searching = false; });
  }

  void _open(Ayah ayah) {
    final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page)));
  }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0A0E27) : const Color(0xFFF5F0E8);
    final surface = dark ? const Color(0xFF16213E) : Colors.white;
    final primary = dark ? Colors.white : const Color(0xFF172033);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('بحث في القرآن'), backgroundColor: Theme.of(context).colorScheme.secondary),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          controller: _controller, textDirection: TextDirection.rtl, style: TextStyle(color: primary),
          decoration: InputDecoration(hintText: 'كلمة، جزء من آية، أو 2:255', filled: true, fillColor: surface, prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
          onSubmitted: _search,
        )),
        if (_searching) const LinearProgressIndicator(),
        if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!, textDirection: TextDirection.rtl)),
        Expanded(child: _results.isEmpty
          ? Center(child: Text(_ayahs.isEmpty ? 'جارِ تحميل فهرس 6236 آية…' : 'اكتب كلمة أو نص آية للبحث', style: TextStyle(color: primary.withOpacity(.55))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) { final v = _results[i]; return Card(
                color: surface, child: InkWell(onTap: () => _open(v), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('سورة ${v.surahName} • الآية ${v.ayahNumber} • صفحة ${v.pageNumber}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 7), Text('﴿${v.text}﴾', textDirection: TextDirection.rtl, style: TextStyle(color: primary, fontFamily: 'Amiri', fontSize: 17, height: 1.8)),
                ]))),
              ); },
            )),
      ]),
    );
  }
}
