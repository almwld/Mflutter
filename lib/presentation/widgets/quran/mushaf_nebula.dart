import 'dart:math';
import 'package:flutter/material.dart';

/// خلفية ثابتة خفيفة للمصحف.
/// لا تستخدم مؤقتات أو مستشعرات أو إعادة رسم مستمرة أثناء القراءة.
class MushafNebula extends StatelessWidget {
  const MushafNebula({super.key, this.particleCount = 18});

  final int particleCount;

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _NebulaPainter(),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  const _NebulaPainter();

  static final List<Offset> _particles = List<Offset>.generate(18, (index) {
    // Deterministic positions: no random generation or animation per frame.
    final x = ((index * 37 + 11) % 97) / 97.0;
    final y = ((index * 53 + 7) % 89) / 89.0;
    return Offset(x, y);
  }, growable: false);

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = min(size.width, size.height);
    final center = Offset(size.width * .5, size.height * .48);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(.025),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: minSide * .48));
    canvas.drawCircle(center, minSide * .48, glow);

    final particlePaint = Paint()..color = Colors.white.withOpacity(.12);
    for (var i = 0; i < _particles.length; i++) {
      final point = _particles[i];
      final radius = .45 + (i % 3) * .18;
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) => false;
}
