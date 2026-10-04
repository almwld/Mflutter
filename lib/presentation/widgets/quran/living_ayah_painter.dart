import 'dart:math';
import 'package:flutter/material.dart';

/// طبقة التأثير الحي للقراءة. لا تغيّر تخطيط QCF؛ ترسم فوق الصفحة فقط.
class LivingAyahPainter extends CustomPainter {
  LivingAyahPainter({
    required this.pulse,
    required this.glow,
    required this.isGreatVerse,
    required this.isActive,
    this.baseColor = const Color(0xFFE2B84A),
  });

  final double pulse;
  final double glow;
  final bool isGreatVerse;
  final bool isActive;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;
    final center = Offset(size.width / 2, size.height * .48);
    final breath = .85 + .15 * sin(pulse * 2 * pi);

    final haloRadius = min(size.width, size.height) * .42 * breath;
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withOpacity(.12 * glow),
          baseColor.withOpacity(.035 * glow),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: haloRadius));
    canvas.drawCircle(center, haloRadius, halo);

    final random = Random(42);
    final particlePaint = Paint()..color = baseColor.withOpacity(.34 * glow);
    for (var i = 0; i < 18; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final baseRadius = random.nextDouble() * min(size.width, size.height) * .34;
      final speed = .5 + random.nextDouble() * .5;
      final radius = baseRadius + sin(pulse * 2 * pi * speed + i) * 9 * breath;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius * .55;
      canvas.drawCircle(
        Offset(x, y),
        1.0 + random.nextDouble() * 1.8 * breath,
        particlePaint,
      );
    }

    if (isGreatVerse) {
      final ripple = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (var i = 0; i < 3; i++) {
        final phase = (pulse + i / 3) % 1.0;
        ripple
          ..color = baseColor.withOpacity(.20 * (1 - phase) * glow);
        canvas.drawCircle(
          center,
          min(size.width, size.height) * .22 + phase * 58,
          ripple,
        );
      }
    }

    final edge = Paint()
      ..color = baseColor.withOpacity(.10 * glow * breath)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * breath);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(18),
      ),
      edge,
    );
  }

  @override
  bool shouldRepaint(covariant LivingAyahPainter old) =>
      old.pulse != pulse ||
      old.glow != glow ||
      old.isGreatVerse != isGreatVerse ||
      old.isActive != isActive ||
      old.baseColor != baseColor;
}
