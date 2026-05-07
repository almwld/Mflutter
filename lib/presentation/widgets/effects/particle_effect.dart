import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// =============================================================================
/// ParticleEffect - تأثير الجزيئات
/// =============================================================================

class ParticleEffect extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double speed;

  const ParticleEffect({
    super.key,
    this.particleCount = 20,
    this.color = AppColors.gold,
    this.speed = 1.0,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final _random = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (3000 / widget.speed).toInt()),
      vsync: this,
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 4 + 2,
        speedX: (_random.nextDouble() - 0.5) * 0.01,
        speedY: (_random.nextDouble() - 0.5) * 0.01 - 0.005,
        opacity: _random.nextDouble() * 0.5 + 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            color: widget.color,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * (1 - progress))
        ..style = PaintingStyle.fill;

      final x = (particle.x + particle.speedX * progress * 100) * size.width;
      final y = (particle.y + particle.speedY * progress * 100 - progress * 0.2) * size.height;

      if (y > 0 && y < size.height && x > 0 && x < size.width) {
        canvas.drawCircle(Offset(x, y), particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}