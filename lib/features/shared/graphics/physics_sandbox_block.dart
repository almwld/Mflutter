import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'physics/distance_constraint.dart';
import 'physics/soft_body.dart';
import 'physics/simulation/physics_world.dart';

/// Small interactive showcase backed by the same 3D particle solver used by
/// application-created simulations. Coordinates are projected onto the canvas.
class PhysicsSandboxBlockWidget extends StatefulWidget {
  const PhysicsSandboxBlockWidget({
    super.key,
    this.height = 300,
    this.backgroundColor = const Color(0xFF0B1220),
    this.accentColor = const Color(0xFF38BDF8),
  });

  final double height;
  final Color backgroundColor;
  final Color accentColor;

  @override
  State<PhysicsSandboxBlockWidget> createState() =>
      _PhysicsSandboxBlockWidgetState();
}

class _PhysicsSandboxBlockWidgetState extends State<PhysicsSandboxBlockWidget>
    with SingleTickerProviderStateMixin {
  static const int _segments = 24;
  late final PhysicsWorld _world;
  late final SoftBody _left;
  late final SoftBody _right;
  late final AnimationController _clock;
  final Stopwatch _stopwatch = Stopwatch();
  int _lastMicros = 0;

  @override
  void initState() {
    super.initState();
    _world = PhysicsWorld(
      fixedTimeStep: 1 / 120,
      maxSubSteps: 8,
      constraintIterations: 8,
      gravityY: 0,
      restitution: .18,
      spatialCellSize: .08,
    );
    _left = _createRing(.32, .5, .24);
    _right = _createRing(.68, .5, -.24);
    _world
      ..addBody(_left)
      ..addBody(_right);
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
    _stopwatch.start();
    _clock.repeat();
  }

  SoftBody _createRing(double centerX, double centerY, double velocityX) {
    final positions = Float64List(_segments * 3);
    final velocities = Float64List(_segments * 3);
    final inverseMasses = Float64List(_segments)..fillRange(0, _segments, 1);
    final radii = Float64List(_segments)..fillRange(0, _segments, .022);
    final constraints = <DistanceConstraint>[];
    const radius = .12;
    for (var i = 0; i < _segments; i++) {
      final angle = (2 * math.pi * i / _segments) - math.pi / 2;
      final offset = i * 3;
      positions[offset] = centerX + math.cos(angle) * radius;
      positions[offset + 1] = centerY + math.sin(angle) * radius;
      velocities[offset] = velocityX;
      final next = (i + 1) % _segments;
      final nextAngle = (2 * math.pi * next / _segments) - math.pi / 2;
      final dx = math.cos(angle) - math.cos(nextAngle);
      final dy = math.sin(angle) - math.sin(nextAngle);
      constraints.add(DistanceConstraint(
        a: i,
        b: next,
        restLength: math.sqrt(dx * dx + dy * dy) * radius,
        stiffness: .92,
      ));
      if (i < _segments ~/ 2) {
        constraints.add(DistanceConstraint(
          a: i,
          b: i + _segments ~/ 2,
          restLength: radius * 2,
          stiffness: .72,
        ));
      }
    }
    return SoftBody(
      name: centerX < .5 ? 'soft-body-a' : 'soft-body-b',
      positions: positions,
      velocities: velocities,
      inverseMasses: inverseMasses,
      radii: radii,
      constraints: constraints,
      linearDamping: .18,
    );
  }

  void _tick() {
    final now = _stopwatch.elapsedMicroseconds;
    final delta = (now - _lastMicros) / 1000000;
    _lastMicros = now;
    if (delta > 0) _world.advance(delta.clamp(0.0, .05).toDouble());
  }

  void _applyPointer(Offset point, Size size) {
    if (size.isEmpty) return;
    final x = (point.dx / size.width).clamp(0.0, 1.0).toDouble();
    final y = (1 - point.dy / size.height).clamp(0.0, 1.0).toDouble();
    for (final body in _world.bodies) {
      for (var i = 0; i < body.particleCount; i++) {
        final offset = i * 3;
        final dx = body.positions[offset] - x;
        final dy = body.positions[offset + 1] - y;
        final distance2 = dx * dx + dy * dy;
        if (distance2 > .16 * .16 || distance2 < 1e-8) continue;
        final strength = (1 - math.sqrt(distance2) / .16) * .65;
        body.velocities[offset] += dx * strength;
        body.velocities[offset + 1] += dy * strength;
      }
    }
  }

  @override
  void dispose() {
    _clock
      ..removeListener(_tick)
      ..dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.clamp(160, 700).toDouble(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  _applyPointer(details.localPosition, size),
              child: CustomPaint(
                painter: _PhysicsSandboxPainter(
                  clock: _clock,
                  bodies: <SoftBody>[_left, _right],
                  backgroundColor: widget.backgroundColor,
                  accentColor: widget.accentColor,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhysicsSandboxPainter extends CustomPainter {
  _PhysicsSandboxPainter({
    required Animation<double> clock,
    required this.bodies,
    required this.backgroundColor,
    required this.accentColor,
  }) : super(repaint: clock) {
    _label = TextPainter(
      text: const TextSpan(
        text: 'SOFT BODY  •  CCD  •  PBD',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _background = Paint()..color = backgroundColor;
    _fillA = Paint()..color = accentColor.withOpacity(.16);
    _fillB = Paint()..color = const Color(0xFF818CF8).withOpacity(.14);
    _strokeA = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _strokeB = Paint()
      ..color = const Color(0xFF818CF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _particle = Paint()..color = const Color(0xFFE2E8F0);
  }

  final List<SoftBody> bodies;
  final Color backgroundColor;
  final Color accentColor;
  late final Paint _background;
  late final Paint _fillA;
  late final Paint _fillB;
  late final Paint _strokeA;
  late final Paint _strokeB;
  late final Paint _particle;
  late final TextPainter _label;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _background);
    for (var bodyIndex = 0; bodyIndex < bodies.length; bodyIndex++) {
      final body = bodies[bodyIndex];
      if (body.particleCount < 3) continue;
      final path = Path();
      for (var i = 0; i < body.particleCount; i++) {
        final offset = i * 3;
        final point = Offset(
          body.positions[offset] * size.width,
          (1 - body.positions[offset + 1]) * size.height,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, bodyIndex == 0 ? _fillA : _fillB);
      canvas.drawPath(path, bodyIndex == 0 ? _strokeA : _strokeB);
      for (var i = 0; i < body.particleCount; i++) {
        final offset = i * 3;
        canvas.drawCircle(
          Offset(
            body.positions[offset] * size.width,
            (1 - body.positions[offset + 1]) * size.height,
          ),
          2.2,
          _particle,
        );
      }
    }
    _label.paint(canvas, Offset(14, size.height - _label.height - 12));
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  bool shouldRepaint(covariant _PhysicsSandboxPainter oldDelegate) =>
      oldDelegate.bodies != bodies ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.accentColor != accentColor;
}
