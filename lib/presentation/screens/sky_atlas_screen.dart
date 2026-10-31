import 'dart:math' as math;

import 'package:flutter/material.dart';

/// واجهة مرصد السماء: طبقة عرض تفاعلية مستقلة عن قارئ المصحف.
/// مواقع النجوم هنا توزيع بصري توضيحي، وليست إحداثيات رصد فلكية محسوبة.
class SkyAtlasScreen extends StatefulWidget {
  const SkyAtlasScreen({super.key});

  @override
  State<SkyAtlasScreen> createState() => _SkyAtlasScreenState();
}

class _SkyAtlasScreenState extends State<SkyAtlasScreen> {
  double _timeOffsetHours = 0;
  String _filter = 'الكل';

  static const _objects = <_SkyObject>[
    _SkyObject('الشعرى اليمانية', 'Sirius', 'نجم', 0.78, 0.36, Color(0xFFEAF4FF), 'وَأَنَّهُ هُوَ رَبُّ الشِّعْرَىٰ', 'النجم: 49', 'سورة النجم، الآية 49.'),
    _SkyObject('القمر', 'Moon', 'القمر', 0.72, 0.22, Color(0xFFE4E9F5), 'وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ', 'يس: 39', 'سورة يس، الآية 39.'),
    _SkyObject('المريخ', 'Mars', 'كوكب', 0.28, 0.48, Color(0xFFFF806D), null, null, 'معلومة فلكية؛ لا توجد آية مخصصة لهذا الكوكب.'),
    _SkyObject('الزهرة', 'Venus', 'كوكب', 0.58, 0.57, Color(0xFFFFE1A3), null, null, 'معلومة فلكية؛ لا توجد آية مخصصة لهذا الكوكب.'),
    _SkyObject('المشتري', 'Jupiter', 'كوكب', 0.43, 0.29, Color(0xFFFFC98A), null, null, 'معلومة فلكية؛ لا توجد آية مخصصة لهذا الكوكب.'),
    _SkyObject('زحل', 'Saturn', 'كوكب', 0.84, 0.51, Color(0xFFD8C6A5), null, null, 'معلومة فلكية؛ لا توجد آية مخصصة لهذا الكوكب.'),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _objects.where((o) => _filter == 'الكل' || o.kind == _filter).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF050B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081329),
        foregroundColor: const Color(0xFFF2DC98),
        title: const Text('مرصد السماء', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'معلومات عن دقة العرض',
            onPressed: _showAccuracyInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => GestureDetector(
                  onTapDown: (details) => _selectAt(details.localPosition, constraints.biggest),
                  child: CustomPaint(
                    painter: _SkyPainter(objects: visible, timeOffset: _timeOffsetHours),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        const Icon(Icons.explore_rounded, color: Color(0xFF8ED8E8), size: 19),
        const SizedBox(width: 7),
        const Text('N  •  000°', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Text(_timeLabel, style: const TextStyle(color: Color(0xFFF2DC98), fontSize: 12)),
        const SizedBox(width: 8),
        const Icon(Icons.my_location_rounded, color: Colors.white38, size: 16),
      ],
    ),
  );

  String get _timeLabel {
    final time = DateTime.now().toUtc().add(Duration(minutes: (_timeOffsetHours * 60).round()));
    return '${time.toIso8601String().substring(0, 16).replaceFirst('T', ' ')} UTC';
  }

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
    decoration: const BoxDecoration(
      color: Color(0xFF0A1428),
      border: Border(top: BorderSide(color: Color(0x223E6688))),
    ),
    child: Column(
      children: [
        Row(
          children: [
            _filterChip('الكل'),
            const SizedBox(width: 7),
            _filterChip('نجم'),
            const SizedBox(width: 7),
            _filterChip('كوكب'),
            const SizedBox(width: 7),
            _filterChip('القمر'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.history_rounded, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            const Text('الزمن', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Expanded(
              child: Slider(
                value: _timeOffsetHours,
                min: -24,
                max: 24,
                divisions: 96,
                activeColor: const Color(0xFFF2DC98),
                inactiveColor: Colors.white12,
                onChanged: (v) => setState(() => _timeOffsetHours = v),
              ),
            ),
            Text('${_timeOffsetHours.toStringAsFixed(0)}h', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'واجهة استكشافية أولية • بيانات المواقع الفلكية الحية قيد الربط',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ),
      ],
    ),
  );

  Widget _filterChip(String value) {
    final active = _filter == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0x33F2DC98) : Colors.white.withOpacity(.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? const Color(0x99F2DC98) : Colors.white12),
          ),
          child: Text(value, textAlign: TextAlign.center, style: TextStyle(color: active ? const Color(0xFFF2DC98) : Colors.white60, fontSize: 11)),
        ),
      ),
    );
  }

  void _selectAt(Offset point, Size size) {
    _SkyObject? nearest;
    var best = 34.0;
    for (final object in _objects.where((o) => _filter == 'الكل' || o.kind == _filter)) {
      final target = Offset(object.x * size.width, object.y * size.height);
      final distance = (target - point).distance;
      if (distance < best) {
        best = distance;
        nearest = object;
      }
    }
    if (nearest == null) return;
    final selected = nearest;
    if (selected == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101D34),
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selected.nameAr, style: const TextStyle(color: Color(0xFFF2DC98), fontFamily: 'Amiri', fontSize: 25)),
              Text(selected.nameEn, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 18),
              if (selected.verse != null) ...[
                Text(nearest.verse!, style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 23, height: 1.8)),
                Text(selected.reference!, style: const TextStyle(color: Color(0xFFF2DC98), fontFamily: 'Amiri')),
                const SizedBox(height: 8),
              ],
              Text(selected.note, style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri', fontSize: 15)),
              const SizedBox(height: 8),
              const Text('الآية معروضة للاستئناس بموضوعها، ولا تعني أن النص يقرر تفاصيل فلكية حديثة.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccuracyInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101D34),
        title: const Text('حول المرصد', style: TextStyle(color: Color(0xFFF2DC98), fontFamily: 'Amiri')),
        content: const Text(
          'هذه نسخة الواجهة الأولى. مواقع الأجرام وتوزيع النجوم توضيحية وليست رصداً حقيقياً بعد. المرحلة التالية تربط الموقع والوقت وبيانات الأفيميرس ومستشعرات الهاتف قبل عرض أي إحداثيات على أنها دقيقة.',
          style: TextStyle(color: Colors.white70, fontFamily: 'Amiri', height: 1.6),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
      ),
    );
  }
}

class _SkyObject {
  final String nameAr;
  final String nameEn;
  final String kind;
  final double x;
  final double y;
  final Color color;
  final String? verse;
  final String? reference;
  final String note;

  const _SkyObject(this.nameAr, this.nameEn, this.kind, this.x, this.y, this.color, this.verse, this.reference, this.note);
}

class _SkyPainter extends CustomPainter {
  final List<_SkyObject> objects;
  final double timeOffset;

  const _SkyPainter({required this.objects, required this.timeOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF101F3D), Color(0xFF071126), Color(0xFF030814)],
    ).createShader(rect));

    final random = math.Random(2048);
    for (var i = 0; i < 260; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final radius = .35 + random.nextDouble() * 1.15;
      canvas.drawCircle(p, radius, Paint()..color = Colors.white.withOpacity(.2 + random.nextDouble() * .6));
    }

    final center = Offset(size.width * .5, size.height * .52);
    final horizon = Paint()..color = const Color(0x3369A6C8)..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * .82), Offset(size.width, size.height * .82), horizon);
    final compass = TextPainter(
      text: const TextSpan(text: 'N', style: TextStyle(color: Color(0xFF8ED8E8), fontSize: 12, letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout();
    compass.paint(canvas, Offset(center.dx - compass.width / 2, 16));

    for (final object in objects) {
      final drift = math.sin(timeOffset * .08 + object.x * 8) * 7;
      final p = Offset(object.x * size.width + drift, object.y * size.height);
      final glow = Paint()..color = object.color.withOpacity(.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13);
      canvas.drawCircle(p, object.kind == 'القمر' ? 12 : 7, glow);
      canvas.drawCircle(p, object.kind == 'القمر' ? 5 : 3, Paint()..color = object.color);
      final label = TextPainter(
        text: TextSpan(text: object.nameAr, style: const TextStyle(color: Colors.white70, fontFamily: 'Amiri', fontSize: 12)),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: 110);
      label.paint(canvas, Offset(p.dx - label.width / 2, p.dy + 13));
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.timeOffset != timeOffset || oldDelegate.objects != objects;
}
