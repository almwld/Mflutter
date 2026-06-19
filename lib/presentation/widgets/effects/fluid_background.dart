import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// =============================================================================
/// FluidBackground - الخلفية السيالة
/// =============================================================================

class FluidBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;

  const FluidBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<FluidBackground> createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية العميقة
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.deepGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        // الطبقة السيالة
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: FluidPainter(
                animation: _controller.value,
                primaryColor: widget.primaryColor ?? AppColors.primaryNavy,
                secondaryColor: widget.secondaryColor ?? AppColors.primaryNavyDark,
              ),
              size: Size.infinite,
            );
          },
        ),
        // المحتوى
        widget.child,
      ],
    );
  }
}

/// =============================================================================
/// FluidPainter - رسام الخلفية السيالة
/// =============================================================================

class FluidPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  FluidPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.3),
          secondaryColor.withOpacity(0.2),
          primaryColor.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // إنشاء موجة متحركة
    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.5 +
          sin((x / size.width * 4 * pi) + (animation * 2 * pi)) * 30 +
          sin((x / size.width * 2 * pi) + (animation * 4 * pi)) * 20;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // دائرة متحركة
    final circlePaint = Paint()
      ..color = AppColors.primaryGold.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final circleX = size.width * 0.8 + sin(animation * 2 * pi) * 50;
    final circleY = size.height * 0.3 + cos(animation * 2 * pi) * 30;

    canvas.drawCircle(Offset(circleX, circleY), 100, circlePaint);

    // دائرة أخرى
    final circle2Paint = Paint()
      ..color = AppColors.primaryNavyLight.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final circle2X = size.width * 0.2 + cos(animation * 2 * pi) * 40;
    final circle2Y = size.height * 0.6 + sin(animation * 2 * pi) * 20;

    canvas.drawCircle(Offset(circle2X, circle2Y), 60, circle2Paint);
  }

  @override
  bool shouldRepaint(FluidPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

/// =============================================================================
/// GoldenParticles - الجسيمات الذهبية
/// =============================================================================

class GoldenParticles extends StatefulWidget {
  final int particleCount;
  final double speed;

  const GoldenParticles({
    super.key,
    this.particleCount = 30,
    this.speed = 1.0,
  });

  @override
  State<GoldenParticles> createState() => _GoldenParticlesState();
}

class _GoldenParticlesState extends State<GoldenParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(),
    );
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
            animation: _controller.value,
            speed: widget.speed,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// =============================================================================
/// Particle - جسيم
/// =============================================================================

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory Particle.random() {
    final random = Random();
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 4 + 2,
      speed: random.nextDouble() * 0.5 + 0.5,
      opacity: random.nextDouble() * 0.5 + 0.3,
    );
  }
}

/// =============================================================================
/// ParticlePainter - رسام الجسيمات
/// =============================================================================

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final double speed;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = AppColors.primaryGold.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = ((particle.y + animation * particle.speed * speed) % 1.0) *
          size.height;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      animation != oldDelegate.animation;
}

/// =============================================================================
/// BreathingContainer - حاوية التنفس
/// =============================================================================

class BreathingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BreathingContainer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<BreathingContainer> createState() => _BreathingContainerState();
}

class _BreathingContainerState extends State<BreathingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}