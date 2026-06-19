import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 📖 شاشة المصحف — ٤ خطوط × ٣ خلفيات
enum QuranMode { musnad, oldArabic, uthmaniGold, hieroglyphic }
enum QuranBackground { navy, brown, black }

class QuranMultiModeScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranMultiModeScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranMultiModeScreen> createState() => _QuranMultiModeScreenState();
}

class _QuranMultiModeScreenState extends State<QuranMultiModeScreen> {
  QuranMode _currentMode = QuranMode.uthmaniGold;
  QuranBackground _currentBg = QuranBackground.navy;
  List<dynamic> _verses = [];
  bool _loading = true;

  // ═══════════════════════════════════════
  // أسماء الأوضاع
  // ═══════════════════════════════════════
  static const Map<QuranMode, String> modeNames = {
    QuranMode.musnad: 'المسند 𐩱',
    QuranMode.oldArabic: 'بدون نقاط',
    QuranMode.uthmaniGold: 'عثماني',
    QuranMode.hieroglyphic: 'هيلوغريفي 𓀀',
  };

  static const Map<QuranMode, IconData> modeIcons = {
    QuranMode.musnad: Icons.history,
    QuranMode.oldArabic: Icons.text_fields,
    QuranMode.uthmaniGold: Icons.auto_awesome,
    QuranMode.hieroglyphic: Icons.museum,
  };

  static const Map<QuranMode, String> modeFonts = {
    QuranMode.musnad: 'Musnad',
    QuranMode.oldArabic: 'MudabbirOld',
    QuranMode.uthmaniGold: 'Amiri',
    QuranMode.hieroglyphic: 'Hieroglyphic',
  };

  // ═══════════════════════════════════════
  // ألوان ذهبية حسب الخط
  // ═══════════════════════════════════════
  static const Map<QuranMode, Color> modeColors = {
    QuranMode.musnad: Color(0xFFDAA520),       // ذهبي برونزي
    QuranMode.oldArabic: Color(0xFFFFD700),    // ذهبي صافي
    QuranMode.uthmaniGold: Color(0xFFFFEC8B),  // ذهبي فاتح
    QuranMode.hieroglyphic: Color(0xFFFFB347), // ذهبي فرعوني
  };

  // ═══════════════════════════════════════
  // الخلفيات الفاخرة
  // ═══════════════════════════════════════
  static const Map<QuranBackground, String> bgNames = {
    QuranBackground.navy: 'كحلي ملكي',
    QuranBackground.brown: 'بني فاخر',
    QuranBackground.black: 'أسود ليلي',
  };

  static const Map<QuranBackground, IconData> bgIcons = {
    QuranBackground.navy: Icons.nights_stay,
    QuranBackground.brown: Icons.coffee,
    QuranBackground.black: Icons.dark_mode,
  };

  static const Map<QuranBackground, Color> bgColors = {
    QuranBackground.navy: Color(0xFF0A0E27),
    QuranBackground.brown: Color(0xFF1A0F07),
    QuranBackground.black: Color(0xFF000000),
  };

  static const Map<QuranBackground, Color> bgAccents = {
    QuranBackground.navy: Color(0xFF1A237E),
    QuranBackground.brown: Color(0xFF3E2723),
    QuranBackground.black: Color(0xFF111111),
  };

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
      final data = jsonDecode(jsonStr);
      setState(() {
        _verses = List<dynamic>.from(data[widget.surahNumber.toString()] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _verses = _getBuiltIn();
        _loading = false;
      });
    }
  }

  List<dynamic> _getBuiltIn() {
    return [
      {'text': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'},
      {'text': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
      {'text': 'الرَّحْمَنِ الرَّحِيمِ'},
    ];
  }

  String _transformText(String text) {
    switch (_currentMode) {
      case QuranMode.musnad:
        return _toMusnad(text);
      case QuranMode.oldArabic:
        return _removeDots(text);
      case QuranMode.hieroglyphic:
        return _toHiero(text);
      case QuranMode.uthmaniGold:
        return text;
    }
  }

  String _toMusnad(String text) {
    const map = {
      'ا': '𐩱', 'ب': '𐩨', 'ت': '𐩩', 'ث': '𐩶', 'ج': '𐩳',
      'ح': '𐩢', 'خ': '𐩮', 'د': '𐩴', 'ذ': '𐩹', 'ر': '𐩧',
      'ز': '𐩷', 'س': '𐩪', 'ش': '𐩦', 'ص': '𐩯', 'ض': '𐩲',
      'ط': '𐩷', 'ظ': '𐩷', 'ع': '𐩰', 'غ': '𐩵', 'ف': '𐩸',
      'ق': '𐩤', 'ك': '𐩬', 'ل': '𐩡', 'م': '𐩣', 'נ': '𐩭',
      'ه': '𐩠', 'و': '𐩥', 'ي': '𐩺', 'ى': '𐩺', 'ة': '𐩠',
      ' ': ' ', 'أ': '𐩱', 'إ': '𐩱',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  String _removeDots(String text) {
    const map = {
      'ب': 'ٮ', 'ت': 'ٮ', 'ث': 'ٮ', 'ج': 'ح', 'خ': 'ح',
      'ذ': 'د', 'ز': 'د', 'ش': 'س', 'ض': 'ص', 'ظ': 'ط',
      'غ': 'ع', 'ف': 'ڡ', 'ق': 'ڡ', 'ن': 'ٮ', 'ي': 'ى',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  String _toHiero(String text) {
    const map = {
      'ا': '𓂝', 'ب': '𓃀', 'ت': '𓏏', 'ث': '𓍿', 'ج': '𓆓',
      'ح': '𓎛', 'خ': '𓐍', 'د': '𓂧', 'ذ': '𓆑', 'ر': '𓂋',
      'ز': '𓊃', 'س': '𓋴', 'ش': '𓈙', 'ص': '𓊮', 'ض': '𓍑',
      'ط': '𓍔', 'ظ': '𓊪', 'ع': '𓂝', 'غ': '𓎼', 'ف': '𓆑',
      'ق': '𓏘', 'ك': '𓎡', 'ل': '𓃭', 'م': '𓅓', 'ن': '𓈖',
      'ه': '𓉔', 'و': '𓅱', 'ي': '𓇌', 'ى': '𓇌', 'ة': '𓉔',
      ' ': ' ', 'أ': '𓂝', 'إ': '𓂝',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: _currentMode == QuranMode.musnad ? 28 :
                _currentMode == QuranMode.hieroglyphic ? 30 : 22,
      fontFamily: modeFonts[_currentMode],
      fontWeight: _currentMode == QuranMode.uthmaniGold ? FontWeight.bold : FontWeight.normal,
      color: modeColors[_currentMode],
      height: 2.2,
      letterSpacing: _currentMode == QuranMode.musnad ? 4 :
                     _currentMode == QuranMode.hieroglyphic ? 6 : 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = bgColors[_currentBg]!;
    final accent = bgAccents[_currentBg]!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.surahName,
            style: TextStyle(color: modeColors[_currentMode], fontFamily: 'Amiri')),
        backgroundColor: accent,
        elevation: 0,
        actions: [
          // أزرار الخطوط
          ...QuranMode.values.map((m) => IconButton(
            icon: Icon(modeIcons[m],
                color: _currentMode == m ? modeColors[m] : Colors.grey,
                size: _currentMode == m ? 26 : 20),
            onPressed: () => setState(() => _currentMode = m),
            tooltip: modeNames[m],
          )),
          const SizedBox(width: 8),
          // أزرار الخلفيات
          PopupMenuButton<QuranBackground>(
            icon: Icon(bgIcons[_currentBg]!, color: modeColors[_currentMode]),
            onSelected: (b) => setState(() => _currentBg = b),
            itemBuilder: (_) => QuranBackground.values.map((b) => PopupMenuItem(
              value: b,
              child: Row(
                children: [
                  Icon(bgIcons[b], color: bgColors[b], size: 20),
                  const SizedBox(width: 8),
                  Text(bgNames[b]!, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: modeColors[_currentMode]))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bg, accent.withOpacity(0.3), bg],
                ),
              ),
              child: Column(
                children: [
                  // شريط الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: accent.withOpacity(0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(modeIcons[_currentMode], color: modeColors[_currentMode], size: 18),
                        const SizedBox(width: 8),
                        Text('${modeNames[_currentMode]} • ${bgNames[_currentBg]}',
                            style: TextStyle(color: modeColors[_currentMode], fontSize: 13)),
                      ],
                    ),
                  ),
                  // الآيات
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _verses.length,
                      itemBuilder: (context, index) {
                        final verse = _verses[index];
                        final text = verse['text'] ?? '';
                        final transformed = _transformText(text);
                        final ayahNum = index + 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: modeColors[_currentMode]!.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: modeColors[_currentMode]!.withOpacity(0.15)),
                            boxShadow: [
                              BoxShadow(
                                color: modeColors[_currentMode]!.withOpacity(0.05),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(transformed,
                                  style: _getTextStyle(),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: modeColors[_currentMode]!.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('﴿$ayahNum﴾',
                                    style: TextStyle(color: modeColors[_currentMode],
                                        fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
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
}
