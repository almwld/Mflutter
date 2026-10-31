import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/verse.dart';
import '../../../services/quran_loader_service.dart';

/// All editorial and visual data for the 60-second study lives here.
/// Counts and verse locations are derived from the bundled canonical Quran
/// corpus at runtime; no random/illustrative verse markers are used.
class DotMatrixCosmosConfig {
  static const int verseCount = 6236;
  static const int columns = 79;
  static const int rows = 79;
  static const Duration duration = Duration(seconds: 60);
  static const Color navyTop = Color(0xFF12224F);
  static const Color navyMid = Color(0xFF0A1330);
  static const Color navyBottom = Color(0xFF050A1C);
  static const Color gold = Color(0xFFF2DC98);

  static const List<(String, String)> prophets = [
    ('آدم', 'ADAM'), ('إدريس', 'IDRIS'), ('نوح', 'NOAH'),
    ('هود', 'HUD'), ('صالح', 'SALIH'), ('إبراهيم', 'ABRAHAM'),
    ('لوط', 'LOT'), ('إسماعيل', 'ISHMAEL'), ('إسحاق', 'ISAAC'),
    ('يعقوب', 'JACOB'), ('يوسف', 'JOSEPH'), ('أيوب', 'JOB'),
    ('شعيب', 'SHUAYB'), ('موسى', 'MOSES'), ('هارون', 'AARON'),
    ('ذو الكفل', 'DHUL-KIFL'), ('داود', 'DAVID'), ('سليمان', 'SOLOMON'),
    ('إلياس', 'ELIAS'), ('اليسع', 'ELISHA'), ('يونس', 'JONAH'),
    ('زكريا', 'ZECHARIAH'), ('يحيى', 'JOHN'), ('عيسى', 'JESUS'),
    ('محمد', 'MUHAMMAD'),
  ];

  /// Address patterns are searched as complete normalized token sequences.
  static const List<String> addressPatterns = [
    'يا ايها النبي',
    'يا ايها الرسول',
    'يا ايها المزمل',
    'يا ايها المدثر',
    'يا ايها الذين امنوا',
    'يا بني ادم',
    'يا بني اسرائيل',
  ];
}

class DotMatrixCosmosScreen extends StatefulWidget {
  const DotMatrixCosmosScreen({super.key});

  @override
  State<DotMatrixCosmosScreen> createState() => _DotMatrixCosmosScreenState();
}

class _DotMatrixCosmosScreenState extends State<DotMatrixCosmosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: DotMatrixCosmosConfig.duration,
  )..addListener(() => setState(() {}));
  List<Ayah> _ayahs = const [];
  List<int> _allahVerseIndices = const [];
  List<int> _allahOccurrences = const [];
  List<String> _allahRefs = const [];
  List<String> _directAddresses = const [];
  Set<int> _prophetsCalled = const {};
  bool _loading = true;
  String? _error;

  double get _time => _clock.value * 60;
  int get _scene => (_time / 10).floor().clamp(0, 5).toInt();

  @override
  void initState() {
    super.initState();
    _loadCorpus();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  String _normalize(String value) => value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('ـ', '')
      .replaceAll('ٱ', 'ا')
      .replaceAll(RegExp('[أإآٲٳ]'), 'ا')
      .replaceAll('ى', 'ي');

  List<String> _tokens(String value) => _normalize(value)
      .split(RegExp(r'[^ء-ي]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  bool _isAllahToken(String token) =>
      token == 'الله' || token == 'لله' || token == 'اللهم' || token.endsWith('الله');

  Future<void> _loadCorpus() async {
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      final lit = <int>[];
      final occurrences = <int>[];
      final refs = <String>[];
      final addresses = <String>[];
      final called = <int>{};

      for (var index = 0; index < ayahs.length; index++) {
        final ayah = ayahs[index];
        final words = _tokens(ayah.text);
        final count = words.where(_isAllahToken).length;
        if (count > 0) {
          lit.add(index);
          occurrences.add(count);
          refs.add('${ayah.surahNumber}:${ayah.ayahNumber}');
        }

        final joined = words.join(' ');
        if (DotMatrixCosmosConfig.addressPatterns.any(
          (pattern) => joined.contains(pattern),
        )) {
          addresses.add(
            '${ayah.surahName} ${ayah.surahNumber}:${ayah.ayahNumber} — ${ayah.text}',
          );
        }

        for (var p = 0; p < DotMatrixCosmosConfig.prophets.length; p++) {
          final nameTokens = _tokens(DotMatrixCosmosConfig.prophets[p].$1);
          if (nameTokens.isEmpty) continue;
          for (var i = 1; i + nameTokens.length <= words.length; i++) {
            if (words[i - 1] != 'يا') continue;
            var matches = true;
            for (var part = 0; part < nameTokens.length; part++) {
              if (words[i + part] != nameTokens[part]) {
                matches = false;
                break;
              }
            }
            if (matches) called.add(p);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _ayahs = ayahs;
        _allahVerseIndices = lit;
        _allahOccurrences = occurrences;
        _allahRefs = refs;
        _directAddresses = addresses;
        _prophetsCalled = called;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    final progress = (_time / 60).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: DotMatrixCosmosConfig.navyBottom,
      appBar: AppBar(
        backgroundColor: DotMatrixCosmosConfig.navyBottom,
        foregroundColor: DotMatrixCosmosConfig.gold,
        title: const Text('الكون القرآني', style: TextStyle(fontFamily: 'Amiri')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: DotMatrixCosmosConfig.gold))
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('تعذر تحليل النص القرآني المحلي\n$_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri')),
                ))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: AnimatedBuilder(
                              animation: _clock,
                              builder: (context, _) => CustomPaint(
                                painter: _CosmosPainter(
                                  time: _time,
                                  scene: scene,
                                  litIndices: _allahVerseIndices,
                                  occurrenceCount: _allahOccurrences.fold<int>(0, (a, b) => a + b),
                                  firstRef: _allahRefs.isEmpty ? '—' : _allahRefs.first,
                                  lastRef: _allahRefs.isEmpty ? '—' : _allahRefs.last,
                                  calledProphets: _prophetsCalled,
                                  addresses: _directAddresses,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                        child: Column(
                          children: [
                            Slider(
                              value: progress,
                              onChanged: (v) => _clock.value = v,
                              activeColor: DotMatrixCosmosConfig.gold,
                              inactiveColor: Colors.white24,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _clock.value = 0,
                                  icon: const Icon(Icons.replay, color: Colors.white70),
                                ),
                                IconButton(
                                  onPressed: () => _clock.isAnimating ? _clock.stop() : _clock.forward(),
                                  icon: Icon(_clock.isAnimating ? Icons.pause : Icons.play_arrow,
                                      color: DotMatrixCosmosConfig.gold),
                                ),
                                const Spacer(),
                                Text('${_time.toStringAsFixed(1)}s / 60s',
                                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _CosmosPainter extends CustomPainter {
  final double time;
  final int scene;
  final List<int> litIndices;
  final int occurrenceCount;
  final String firstRef;
  final String lastRef;
  final Set<int> calledProphets;
  final List<String> addresses;

  _CosmosPainter({
    required this.time,
    required this.scene,
    required this.litIndices,
    required this.occurrenceCount,
    required this.firstRef,
    required this.lastRef,
    required this.calledProphets,
    required this.addresses,
  });

  void _text(Canvas canvas, Size size, String text, double y, {
    double fontSize = 18,
    Color color = Colors.white,
    String font = 'Amiri',
    TextAlign align = TextAlign.center,
    double maxWidthFactor = .86,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        fontFamily: font, fontSize: fontSize, color: color,
        height: 1.3, shadows: [Shadow(color: color.withOpacity(.35), blurRadius: 9)],
      )),
      textDirection: TextDirection.rtl,
      textAlign: align,
      maxLines: 3,
    )..layout(maxWidth: size.width * maxWidthFactor);
    painter.paint(canvas, Offset((size.width - painter.width) / 2, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.25),
      radius: 1.1,
      colors: [DotMatrixCosmosConfig.navyTop, DotMatrixCosmosConfig.navyMid, DotMatrixCosmosConfig.navyBottom],
      stops: [0, .55, 1],
    ).createShader(rect));

    final random = math.Random(6236);
    for (var i = 0; i < 110; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = .25 + .5 * (math.sin(time * .9 + i) + 1) / 2;
      canvas.drawCircle(Offset(x, y), .35 + random.nextDouble() * .55,
          Paint()..color = Colors.white.withOpacity(twinkle * .45));
    }

    if (scene == 0) {
      final reveal = ((time - 1) / 7).clamp(0.0, 1.0);
      _text(canvas, size, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          size.height * .37, fontSize: 24 + reveal * 3, color: DotMatrixCosmosConfig.gold);
      _text(canvas, size, 'In the name of Allah, the Most Compassionate, Most Merciful',
          size.height * .48, fontSize: 12, font: 'serif');
      _text(canvas, size, 'AL-FATIHAH 1:1', size.height * .58,
          fontSize: 9, color: const Color(0xFF8290B2), font: 'Cormorant Garamond');
      for (var i = 0; i < 170; i++) {
        final angle = i * 2.399;
        final radius = (1 - reveal) * size.width * .42 + (i % 13) * 1.1;
        final p = Offset(size.width / 2 + math.cos(angle) * radius,
            size.height * .43 + math.sin(angle) * radius * .38);
        canvas.drawCircle(p, .7, Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.35 + reveal * .5));
      }
      return;
    }

    if (scene == 1 || scene == 2) {
      _drawGrid(canvas, size, scene == 2 ? ((time - 20) / 5).clamp(0.0, 1.0) : 1);
      if (scene == 1) {
        _text(canvas, size, 'أَوَّلُ وَآخِرُ مَوْضِع', size.height * .12,
            color: DotMatrixCosmosConfig.gold, fontSize: 17);
        _text(canvas, size, 'FIRST & LAST OCCURRENCE', size.height * .19,
            color: const Color(0xFF8290B2), fontSize: 9, font: 'Cormorant Garamond');
        _text(canvas, size, firstRef, size.height * .76, fontSize: 13);
        _text(canvas, size, lastRef, size.height * .82, fontSize: 13);
      } else {
        final value = (occurrenceCount * ((time - 20) / 5).clamp(0.0, 1.0)).round();
        _text(canvas, size, value.toString(), size.height * .12,
            fontSize: 36, color: DotMatrixCosmosConfig.gold, font: 'Cormorant Garamond');
        _text(canvas, size, 'TIMES IN THE QURAN', size.height * .22,
            fontSize: 9, color: const Color(0xFF8290B2), font: 'Cormorant Garamond');
      }
      return;
    }

    if (scene == 3) {
      _text(canvas, size, 'أَسْمَاءُ الْأَنْبِيَاءِ', size.height * .08,
          color: DotMatrixCosmosConfig.gold, fontSize: 20);
      _text(canvas, size, 'PROPHET NAMES', size.height * .15,
          fontSize: 9, color: const Color(0xFF8290B2), font: 'Cormorant Garamond');
      final names = DotMatrixCosmosConfig.prophets;
      final cellW = size.width / 6;
      final startY = size.height * .27;
      final line = Path();
      for (var i = 0; i < 24; i++) {
        final row = i ~/ 6;
        final inRow = i % 6;
        final col = row.isOdd ? 5 - inRow : inRow;
        final point = Offset(cellW * (col + .5), startY + row * size.height * .105);
        if (i == 0) { line.moveTo(point.dx, point.dy); } else { line.lineTo(point.dx, point.dy); }
      }
      final pathMetric = line.computeMetrics().first;
      final drawn = pathMetric.extractPath(0, pathMetric.length *
          ((time - 30) / 4).clamp(0.0, 1.0));
      canvas.drawPath(drawn, Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.25)
        ..style = PaintingStyle.stroke..strokeWidth = .8);
      for (var i = 0; i < 24; i++) {
        final row = i ~/ 6;
        final inRow = i % 6;
        final col = row.isOdd ? 5 - inRow : inRow;
        final point = Offset(cellW * (col + .5), startY + row * size.height * .105);
        final active = calledProphets.contains(i) && time > 32 + i * .25;
        final color = active ? DotMatrixCosmosConfig.gold : Colors.white.withOpacity(.25);
        canvas.drawCircle(point, active ? 3.5 : 2, Paint()..color = color);
        _text(canvas, size, names[i].$1, point.dy + 8,
            fontSize: 10, color: color, maxWidthFactor: .17);
      }
      _text(canvas, size, '25', size.height * .72,
          fontSize: 30, color: DotMatrixCosmosConfig.gold, font: 'serif');
      _text(canvas, size, 'أَسْمَاءٌ نَبَوِيَّةٌ فِي الْقُرْآن', size.height * .76,
          fontSize: 12, color: Colors.white70);
      _text(canvas, size, 'مُحَمَّد ﷺ', size.height * .82,
          fontSize: 18, color: DotMatrixCosmosConfig.gold);
      _text(canvas, size, 'MUHAMMAD', size.height * .84,
          fontSize: 9, color: const Color(0xFF8290B2), font: 'Cormorant Garamond');
      return;
    }

    if (scene == 4) {
      _text(canvas, size, 'نِدَاءَاتٌ مُبَاشِرَة', size.height * .1,
          color: DotMatrixCosmosConfig.gold, fontSize: 20);
      _text(canvas, size, 'DIRECT ADDRESSES', size.height * .18,
          color: const Color(0xFF8290B2), fontSize: 9, font: 'Cormorant Garamond');
      final visible = ((time - 40) * 1.2).floor().clamp(0, addresses.length).toInt();
      if (visible > 0) {
        final item = addresses[(visible - 1).clamp(0, addresses.length - 1).toInt()];
        _text(canvas, size, item, size.height * .36, fontSize: 15, color: Colors.white);
        _text(canvas, size, '$visible', size.height * .65,
            fontSize: 30, color: DotMatrixCosmosConfig.gold, font: 'Cormorant Garamond');
      }
      return;
    }

    _text(canvas, size, 'الْقُرْآنُ كِتَابٌ يُتْلَىٰ', size.height * .34,
        fontSize: 27, color: DotMatrixCosmosConfig.gold);
    _text(canvas, size, 'A REVELATION TO BE RECITED,\nREFLECTED UPON, AND LIVED.',
        size.height * .48, fontSize: 17, color: Colors.white, font: 'Cormorant Garamond');
    _text(canvas, size, '6236 VERSES • VERIFIED LOCAL TEXT',
        size.height * .66, fontSize: 9, color: const Color(0xFF8290B2), font: 'Cormorant Garamond');
  }

  void _drawGrid(Canvas canvas, Size size, double sweep) {
    final left = size.width * .08;
    final top = size.height * .29;
    final width = size.width * .84;
    final height = size.height * .36;
    final dx = width / 79;
    final dy = height / 79;
    final lit = litIndices.toSet();
    final scanRow = (sweep * 79).floor();
    for (var index = 0; index < DotMatrixCosmosConfig.verseCount; index++) {
      final row = index ~/ 79;
      final col = 78 - (index % 79);
      final point = Offset(left + (col + .5) * dx, top + (row + .5) * dy);
      final isLit = lit.contains(index);
      final swept = row < scanRow;
      final active = isLit && (sweep >= 1 || swept);
      if (active) {
        canvas.drawCircle(point, 2.0, Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.14));
      }
      canvas.drawCircle(point, .72, Paint()
        ..color = active ? DotMatrixCosmosConfig.gold : Colors.white.withOpacity(.15));
    }
    if (litIndices.isNotEmpty) {
      final pulse = 1.0 + .8 * (math.sin(time * 3.2) + 1) / 2;
      for (final markerIndex in <int>[litIndices.first, litIndices.last]) {
        final markerRow = markerIndex ~/ 79;
        final markerCol = 78 - (markerIndex % 79);
        final marker = Offset(left + (markerCol + .5) * dx, top + (markerRow + .5) * dy);
        canvas.drawCircle(marker, 3.2 * pulse,
            Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.18)
              ..style = PaintingStyle.stroke..strokeWidth = 1.1);
        canvas.drawCircle(marker, 1.6, Paint()..color = DotMatrixCosmosConfig.gold);
        if (scene == 1) {
          final targetY = markerIndex == litIndices.first ? .76 : .82;
          canvas.drawLine(
            marker,
            Offset(size.width / 2, size.height * targetY),
            Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.35)
              ..strokeWidth = .65,
          );
        }
      }
    }
    if (sweep < 1) {
      final y = top + scanRow * dy;
      canvas.drawLine(Offset(left, y), Offset(left + width, y),
          Paint()..color = DotMatrixCosmosConfig.gold.withOpacity(.6)..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.scene != scene ||
      oldDelegate.litIndices != litIndices ||
      oldDelegate.occurrenceCount != occurrenceCount;
}
