import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// خلفية كونية خفيفة للمصحف. تتفاعل مع ميل الجهاز دون لمس تخطيط QCF.
class MushafNebula extends StatefulWidget {
  const MushafNebula({super.key, this.particleCount = 250});

  final int particleCount;

  @override
  State<MushafNebula> createState() => _MushafNebulaState();
}

class _MushafNebulaState extends State<MushafNebula>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Offset> _particles = [];
  double _tiltX = 0;
  double _tiltY = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

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

    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((event) {
      if (!mounted) return;
      setState(() {
        _tiltX = (_tiltX * .88 + (event.y / 9.81) * .12).clamp(-1.0, 1.0);
        _tiltY = (_tiltY * .88 + (event.x / 9.81) * .12).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
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
              tiltX: _tiltX,
              tiltY: _tiltY,
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
    required this.tiltX,
    required this.tiltY,
  });

  final List<Offset> particles;
  final double phase;
  final double tiltX;
  final double tiltY;

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = min(size.width, size.height);
    final center = Offset(
      size.width * (.5 + tiltY * .018),
      size.height * (.48 + tiltX * .018),
    );

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
      final x = (p.dx + drift + tiltY * .012) % 1.0;
      final y = (p.dy + tiltX * .012) % 1.0;
      final radius = .45 + (i % 4) * .22;
      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter old) =>
      old.phase != phase || old.tiltX != tiltX || old.tiltY != tiltY;
}
