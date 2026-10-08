import 'package:flutter/material.dart';
import '../../services/quran_loader_service.dart';
import '../../services/mushaf_source.dart';
import '../../domain/entities/verse.dart';
import 'quran/mushaf_screen.dart';

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});
  @override State<InsightScreen> createState() => _InsightScreenState();
}
class _InsightScreenState extends State<InsightScreen> {
  List<Ayah> _ayahs = const []; int _visible = 30; bool _loading = true; String? _error;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final all = await QuranLoaderService.loadAllAyahs(); if (mounted) setState(() { _ayahs = all; _loading = false; }); } catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); } }
  void _open(Ayah ayah) { final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber); Navigator.push(context, MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page))); }
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0A0E27) : const Color(0xFFF5F0E8);
    final surface = dark ? const Color(0xFF16213E) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF18202D);
    return Scaffold(backgroundColor: bg, appBar: AppBar(title: const Text('التدبر'), backgroundColor: Theme.of(context).colorScheme.secondary),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('تعذر تحميل القرآن: ' + _error!, textDirection: TextDirection.rtl))) :
      ListView.builder(padding: const EdgeInsets.all(12), itemCount: (_visible < _ayahs.length ? _visible : _ayahs.length) + (_visible < _ayahs.length ? 1 : 0), itemBuilder: (_, i) {
        if (i >= _visible || i >= _ayahs.length) return Padding(padding: const EdgeInsets.all(12), child: OutlinedButton(onPressed: () => setState(() => _visible += 30), child: Text('عرض 30 آية إضافية — المتبقي ' + (_ayahs.length - _visible).clamp(0, _ayahs.length).toString())));
        final a = _ayahs[i];
        return Card(color: surface, margin: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => _open(a), borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('سورة ' + a.surahName + ' • الآية ' + a.ayahNumber.toString() + ' • صفحة ' + a.pageNumber.toString(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8), Text('﴿' + a.text + '﴾', textDirection: TextDirection.rtl, style: TextStyle(color: fg, fontFamily: 'Amiri', fontSize: 17, height: 1.9)),
          const SizedBox(height: 8), Text('سؤال التدبر: ما الهداية أو المعنى الذي تستخلصه من هذه الآية في سياقها؟', textDirection: TextDirection.rtl, style: TextStyle(color: fg.withOpacity(.62), fontSize: 12)),
        ]))));
      }));
  }
}