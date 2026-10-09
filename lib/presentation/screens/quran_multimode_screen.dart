import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/quran_source_corrections.dart';
import '../../services/text_transformer.dart';

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
  String? _loadError;

  // ═══════════════════════════════════════
  // أسماء الأوضاع
  // ═══════════════════════════════════════
  static const Map<QuranMode, String> modeNames = {
    QuranMode.musnad: 'المسند 𐩱',
    QuranMode.oldArabic: 'الكوفي القديم — بدون نقاط',
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
    QuranMode.oldArabic: 'Amiri',
    QuranMode.uthmaniGold: 'Amiri',
    QuranMode.hieroglyphic: 'NotoSansEgyptianHieroglyphs',
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
      final rawVerses = data[widget.surahNumber.toString()];
      if (!mounted) return;
      setState(() {
        _verses = rawVerses is List
            ? QuranSourceCorrections.correctSurahVerses(widget.surahNumber, rawVerses)
            : <dynamic>[];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verses = [];
        _loadError = 'تعذر تحميل بيانات المصحف المحلية: $e';
        _loading = false;
      });
    }
  }

  String _transformText(String text) {
    switch (_currentMode) {
      case QuranMode.musnad:
        return TextTransformer.toMusnad(text);
      case QuranMode.oldArabic:
        return TextTransformer.toDotless(text);
      case QuranMode.hieroglyphic:
        return _toHiero(text);
      case QuranMode.uthmaniGold:
        return text;
    }
  }
  String _toHiero(String text) => TextTransformer.toHieroglyphic(text);

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
          : _loadError != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_loadError!, textAlign: TextAlign.center, textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri')),
            ))
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
