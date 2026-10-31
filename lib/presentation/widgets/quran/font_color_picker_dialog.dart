import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dialog for selecting a readable custom Quran font color.
class FontColorPickerDialog extends StatefulWidget {
  const FontColorPickerDialog({super.key, required this.initialColor});

  final Color initialColor;

  @override
  State<FontColorPickerDialog> createState() => _FontColorPickerDialogState();
}

class _FontColorPickerDialogState extends State<FontColorPickerDialog> {
  late Color _selected;
  late final TextEditingController _hexController;
  bool _invalidHex = false;

  static const _presets = <Color>[
    Color(0xFF241A12), Color(0xFF5B3424), Color(0xFF8B4513),
    Color(0xFFD49A16), Color(0xFFFFD45A), Color(0xFFB3261E),
    Color(0xFF1B5E20), Color(0xFF087F8C), Color(0xFF1565C0),
    Color(0xFF3949AB), Color(0xFF6A1B9A), Color(0xFF616161),
    Color(0xFF111827), Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
    _hexController = TextEditingController(text: _toHex(_selected));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _toHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  void _setColor(Color color) {
    setState(() {
      _selected = color;
      _hexController.text = _toHex(color);
      _invalidHex = false;
    });
  }

  void _readHex(String value) {
    final raw = value.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(raw)) {
      setState(() => _invalidHex = true);
      return;
    }
    setState(() {
      _selected = Color(int.parse('FF$raw', radix: 16));
      _invalidHex = false;
    });
  }

  void _setHue(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = local - center;
    final radius = math.min(size.width, size.height) / 2;
    if (delta.distance > radius) return;
    final hue = (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
    final saturation = (delta.distance / radius).clamp(0.0, 1.0);
    final hsv = HSVColor.fromColor(_selected).withHue(hue).withSaturation(saturation);
    _setColor(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(_selected);
    return AlertDialog(
      title: const Text('لون خط صفحات المصحف', textDirection: TextDirection.rtl),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F1E4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: _selected,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('عجلة الألوان', textDirection: TextDirection.rtl),
              const SizedBox(height: 8),
              GestureDetector(
                onPanDown: (d) {
                  final box = context.findRenderObject();
                  if (box is RenderBox) {
                    final wheelBox = _wheelKey.currentContext?.findRenderObject();
                    if (wheelBox is RenderBox) {
                      _setHue(wheelBox.globalToLocal(d.globalPosition), wheelBox.size);
                    }
                  }
                },
                onPanUpdate: (d) {
                  final wheelBox = _wheelKey.currentContext?.findRenderObject();
                  if (wheelBox is RenderBox) {
                    _setHue(wheelBox.globalToLocal(d.globalPosition), wheelBox.size);
                  }
                },
                child: SizedBox(
                  key: _wheelKey,
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter: _ColorWheelPainter(hsv.hue, hsv.saturation),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('السطوع'),
                  Expanded(
                    child: Slider(
                      value: hsv.value.clamp(.08, 1.0),
                      onChanged: (v) => _setColor(hsv.withValue(v).toColor()),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('ألوان مقترحة', textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _presets.map((color) => InkWell(
                  onTap: () => _setColor(color),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selected.value == color.value
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black26,
                        width: _selected.value == color.value ? 3 : 1,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _hexController,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'رمز اللون HEX',
                  hintText: '#D6DBDB',
                  errorText: _invalidHex ? 'أدخل رمزاً صحيحاً مثل #D6DBDB' : null,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'تطبيق الرمز',
                    icon: const Icon(Icons.check),
                    onPressed: () => _readHex(_hexController.text),
                  ),
                ),
                onChanged: _readHex,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _invalidHex ? null : () => Navigator.pop(context, _selected),
          child: const Text('تطبيق اللون'),
        ),
      ],
    );
  }

  final GlobalKey _wheelKey = GlobalKey();
}

class _ColorWheelPainter extends CustomPainter {
  const _ColorWheelPainter(this.hue, this.saturation);

  final double hue;
  final double saturation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
          Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF),
          Color(0xFFFF0000),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * .68, Paint()..color = Colors.white.withOpacity(.92));
    canvas.drawCircle(center, radius * .34, Paint()..color = Colors.white);
    final angle = hue * math.pi / 180;
    final markerRadius = radius * saturation;
    final marker = center + Offset(math.cos(angle), math.sin(angle)) * markerRadius;
    canvas.drawCircle(marker, 8, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(marker, 5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) =>
      oldDelegate.hue != hue || oldDelegate.saturation != saturation;
}
