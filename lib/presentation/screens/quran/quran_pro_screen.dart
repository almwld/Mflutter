import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/quran_models.dart';
import '../../../services/text_transformer.dart';

/// 📖 شاشة القرآن الاحترافية — 5 أنماط عرض
class QuranProScreen extends StatefulWidget {
  const QuranProScreen({super.key});

  @override
  State<QuranProScreen> createState() => _QuranProScreenState();
}

class _QuranProScreenState extends State<QuranProScreen>
    with SingleTickerProviderStateMixin {
  // البيانات
  Map<String, dynamic>? _quran;
  List<dynamic> _currentVerses = [];
  int _currentSurah = 1;
  String _surahName = 'الفاتحة';
  bool _loading = true;

  // العرض
  QuranDisplayMode _mode = QuranDisplayMode.uthmaniGold;
  double _fontSize = 22;
  bool _showFrame = true;
  bool _autoScroll = false;

  // متحكمات
  final ScrollController _scroll = ScrollController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // الثوابت
  static const _bgColor = Color(0xFF0A0E27);
  static const _goldColor = Color(0xFFFFD700);

  // قائمة السور
  final _surahs = [
    {'n': 1, 'name': 'الفاتحة'}, {'n': 2, 'name': 'البقرة'},
    {'n': 3, 'name': 'آل عمران'}, {'n': 4, 'name': 'النساء'},
    {'n': 36, 'name': 'يس'}, {'n': 55, 'name': 'الرحمن'},
    {'n': 67, 'name': 'الملك'}, {'n': 112, 'name': 'الإخلاص'},
    {'n': 113, 'name': 'الفلق'}, {'n': 114, 'name': 'الناس'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulse = Tween(begin: 0.8, end: 1.0).animate(_pulseCtrl);
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
    setState(() {
      _quran = jsonDecode(jsonStr);
      _loadSurah(1);
      _loading = false;
    });
  }

  void _loadSurah(int n) {
    if (_quran == null) return;
    setState(() {
      _currentSurah = n;
      _currentVerses = List<dynamic>.from(_quran![n.toString()] ?? []);
      _surahName = _surahs.firstWhere((s) => s['n'] == n)['name'] ?? 'سورة $n';
      _scroll.jumpTo(0);
    });
  }

  String _transform(String text) => TextTransformer.transform(text, _mode);

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: _fontSize,
      fontFamily: _mode == QuranDisplayMode.musnadAncient ? 'Musnad' : 'Amiri',
      fontWeight: FontWeight.bold,
      color: _mode == QuranDisplayMode.uthmaniGold
          ? const Color(0xFFFFD700)
          : _mode == QuranDisplayMode.musnadAncient
              ? const Color(0xFFB8860B)
              : _mode == QuranDisplayMode.hieroglyphic
                  ? const Color(0xFFCD853F)
                  : const Color(0xFFDAA520),
      height: 2.2,
      letterSpacing: _mode == QuranDisplayMode.musnadAncient ? 4 : 1.5,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _goldColor)),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildModeBar(),
          Expanded(child: _buildVerseList()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_surahName,
          style: const TextStyle(color: _goldColor, fontFamily: 'Amiri')),
      backgroundColor: const Color(0xFF1A237E),
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.search, color: _goldColor),
            onPressed: () {}),
        IconButton(
            icon: Icon(_autoScroll ? Icons.pause : Icons.play_arrow,
                color: _goldColor),
            onPressed: () => setState(() => _autoScroll = !_autoScroll)),
        PopupMenuButton<int>(
          icon: const Icon(Icons.list, color: _goldColor),
          onSelected: _loadSurah,
          itemBuilder: (_) => _surahs
              .map((s) => PopupMenuItem(
                  value: s['n'],
                  child: Text('${s['name']} (${s['n']})',
                      style: const TextStyle(color: Colors.white))))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildModeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: _bgColor.withOpacity(0.9),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _modeButton('عثماني', QuranDisplayMode.uthmaniGold, '🕌'),
            _modeButton('المسند', QuranDisplayMode.musnadAncient, '𐩱'),
            _modeButton('بدون نقاط', QuranDisplayMode.dotless, 'ٮ'),
            _modeButton('كوفي', QuranDisplayMode.kufi, '│'),
            _modeButton('هيلوغريفية', QuranDisplayMode.hieroglyphic, '𓂝'),
            const SizedBox(width: 16),
            // أزرار التحكم
            IconButton(
                icon: const Icon(Icons.remove, color: _goldColor, size: 20),
                onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(14, 40))),
            Text('${_fontSize.toInt()}',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            IconButton(
                icon: const Icon(Icons.add, color: _goldColor, size: 20),
                onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(14, 40))),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, QuranDisplayMode mode, String icon) {
    final active = _mode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? _goldColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? _goldColor : Colors.white24, width: active ? 1.5 : 0.5),
          ),
          child: Text('$icon $label',
              style: TextStyle(
                  color: active ? _goldColor : Colors.white54, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildVerseList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _currentVerses.length,
      itemBuilder: (context, i) {
        final v = _currentVerses[i];
        final text = v['text'] ?? '';
        final transformed = _transform(text);
        final num = i + 1;

        return AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _goldColor.withOpacity(0.1)),
                boxShadow: [
                  if (_showFrame)
                    BoxShadow(
                      color: _goldColor.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(transformed,
                      style: _textStyle(),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl),
                  const SizedBox(height: 8),
                  _buildVerseNumber(num),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVerseNumber(int num) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('﴿$num﴾',
          style: const TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1A237E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton(Icons.skip_previous, () {
            if (_currentSurah > 1) _loadSurah(_currentSurah - 1);
          }),
          Text('${_currentVerses.length} آية',
              style: const TextStyle(color: _goldColor)),
          _navButton(Icons.skip_next, () {
            if (_currentSurah < 114) _loadSurah(_currentSurah + 1);
          }),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return IconButton(
        icon: Icon(icon, color: _goldColor, size: 28), onPressed: onTap);
  }
}
