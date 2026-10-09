import 'dart:math';
import 'package:flutter/material.dart';

/// خلفية كونية خفيفة للمصحف. تتفاعل مع ميل الجهاز دون لمس تخطيط QCF.
class MushafNebula extends StatefulWidget {
  const MushafNebula({super.key, this.particleCount = 48});

  final int particleCount;

  @override
  State<MushafNebula> createState() => _MushafNebulaState();
}

class _MushafNebulaState extends State<MushafNebula>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    final random = Random(73);
    for (var i = 0; i < widget.particleCount; i++) {
      _particles.add(Offset(random.nextDouble(), random.nextDouble()));
    }

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _NebulaPainter(
              particles: _particles,
              phase: _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  const _NebulaPainter({
    required this.particles,
    required this.phase,
  });

  final List<Offset> particles;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = min(size.width, size.height);
    final center = Offset(size.width * .5, size.height * .48);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(.035),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: minSide * .55),
      );
    canvas.drawCircle(center, minSide * .55, glow);

    final paint = Paint()..color = Colors.white.withOpacity(.18);
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final drift = sin((phase * 2 * pi) + i * .37) * .0025;
      final x = (p.dx + drift) % 1.0;
      final y = p.dy;
      final radius = .45 + (i % 4) * .22;
      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter old) =>
      old.phase != phase || old.particles != particles;
}
