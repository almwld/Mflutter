import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// =============================================================================
/// FluidBackground - الخلفية السيالة
/// =============================================================================

class FluidBackground extends StatefulWidget {
  final Widget child;

  const FluidBackground({
    super.key,
    required this.child,
  });

  @override
  State<FluidBackground> createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground>
    with SingleTickerProviderStateMixin {
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
        // الخلفية الأساسية
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.surfaceGradient,
          ),
        ),
        // الطبقة السيالة
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: FluidPainter(
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // الجزيئات الذهبية
        const GoldenParticles(),
        // المحتوى
        widget.child,
      ],
    );
  }
}

/// =============================================================================
/// FluidPainter - رسام السائل
/// =============================================================================

class FluidPainter extends CustomPainter {
  final double progress;

  FluidPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primaryNavy.withOpacity(0.1),
          AppColors.primaryNavy.withOpacity(0.3),
          AppColors.primaryNavy.withOpacity(0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      )
      .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // رسم موجات متعددة
    for (int wave = 0; wave < 3; wave++) {
      path.reset();
      final offset = wave * 0.3 + progress * 2;

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height * 0.3 +
            wave * size.height * 0.1 +
            (size.height * 0.15) *
                (0.5 +
                    0.5 *
                        ((x / size.width * 4 + offset) +
                                _sin((x / size.width * 8 + offset)) *
                                    _cos((x / size.width * 12 + offset * 0.7)) *
                                    0.5)
                            .remainder(1.0));
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint..opacity = 0.3 - wave * 0.08);
    }
  }

  double _sin(double x) => _sineApprox(x);
  double _cos(double x) => _sineApprox(x + 1.57);

  double _sineApprox(double x) {
    x = x % 6.28;
    double result = x;
    double term = x;
    for (int i = 1; i <= 5; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant FluidPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// =============================================================================
/// GoldenParticles - الجزيئات الذهبية
/// =============================================================================

class GoldenParticles extends StatefulWidget {
  const GoldenParticles({super.key});

  @override
  State<GoldenParticles> createState() => _GoldenParticlesState();
}

class _GoldenParticlesState extends State<GoldenParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ParticleData> _particles;
  final _random = DateTime.now().hashCode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(30, (index) {
      return ParticleData(
        x: ((index * 37 + _random) % 1000) / 1000,
        y: ((index * 73 + _random) % 1000) / 1000,
        size: 2 + ((index * 13) % 4),
        speed: 0.001 + ((index * 7) % 10) / 10000,
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
          painter: ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: AppColors.primaryGold,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticleData {
  final double x;
  final double y;
  final double size;
  final double speed;

  ParticleData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<ParticleData> particles;
  final double progress;
  final Color color;

  ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(0.3 + 0.4 * ((particle.y + progress) % 1.0))
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = (particle.y - progress * particle.speed * 50) % size.height;

      if (y > 0) {
        canvas.drawCircle(Offset(x, y), particle.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// =============================================================================
/// MagneticIcon - أيقونة مغناطيسية
/// =============================================================================

class MagneticIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MagneticIcon({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.primaryGold,
    required this.onTap,
  });

  @override
  State<MagneticIcon> createState() => _MagneticIconState();
}

class _MagneticIconState extends State<MagneticIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(_glowAnimation.value),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 12 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}