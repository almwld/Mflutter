import 'dart:math';
import 'package:flutter/material.dart';

class _LivingParticle {
  const _LivingParticle({
    required this.angle,
    required this.radiusFactor,
    required this.speed,
    required this.sizeFactor,
  });

  final double angle;
  final double radiusFactor;
  final double speed;
  final double sizeFactor;
}

/// طبقة التأثير الحي للقراءة. لا تغيّر تخطيط QCF؛ ترسم فوق الصفحة فقط.
/// خصائص الجسيمات تُحسب مرة واحدة بدل إنشاء مولّد عشوائي في كل إطار.
class LivingAyahPainter extends CustomPainter {
  static final List<_LivingParticle> _particles = _createParticles();

  static List<_LivingParticle> _createParticles() {
    final random = Random(42);
    return List<_LivingParticle>.generate(
      18,
      (_) => _LivingParticle(
        angle: random.nextDouble() * 2 * pi,
        radiusFactor: random.nextDouble(),
        speed: .5 + random.nextDouble() * .5,
        sizeFactor: random.nextDouble(),
      ),
      growable: false,
    );
  }

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

    final minSide = min(size.width, size.height);
    final particlePaint = Paint()..color = baseColor.withOpacity(.34 * glow);
    for (var i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      final baseRadius = particle.radiusFactor * minSide * .34;
      final radius = baseRadius +
          sin(pulse * 2 * pi * particle.speed + i) * 9 * breath;
      final x = center.dx + cos(particle.angle) * radius;
      final y = center.dy + sin(particle.angle) * radius * .55;
      canvas.drawCircle(
        Offset(x, y),
        1.0 + particle.sizeFactor * 1.8 * breath,
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
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.5 * breath);
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
