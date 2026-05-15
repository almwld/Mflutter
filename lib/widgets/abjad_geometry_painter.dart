import 'package:flutter/material.dart';
import 'dart:math' as math;

class AbjadGeometryPainter extends CustomPainter {
  final int abjadValue;
  final Color goldColor;

  AbjadGeometryPainter({required this.abjadValue, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (abjadValue == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = goldColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    int sides = (math.sqrt(abjadValue).toInt() % 10) + 3;
    double radius = size.width * 0.35;
    var path = Path();
    double angleStep = (2 * math.pi) / sides;
    path.moveTo(center.dx + radius * math.cos(0), center.dy + radius * math.sin(0));
    for (int i = 1; i <= sides; i++) {
      path.lineTo(center.dx + radius * math.cos(i * angleStep + abjadValue * 0.01), center.dy + radius * math.sin(i * angleStep + abjadValue * 0.01));
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, radius * 0.2, Paint()..color = goldColor.withOpacity(0.05)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
  }

  @override
  bool shouldRepaint(covariant AbjadGeometryPainter old) => old.abjadValue != abjadValue;
}
