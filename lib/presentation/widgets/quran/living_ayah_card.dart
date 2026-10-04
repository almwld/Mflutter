import 'package:flutter/material.dart';
import 'living_ayah_painter.dart';

/// تأثير تفاعلي خفيف مستقل عن محرك QCF.
class LivingAyahCard extends StatefulWidget {
  const LivingAyahCard({
    super.key,
    required this.child,
    this.isGreatVerse = false,
    this.active = true,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final bool isGreatVerse;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<LivingAyahCard> createState() => _LivingAyahCardState();
}

class _LivingAyahCardState extends State<LivingAyahCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isGreatVerse ? 1800 : 2400),
    )..repeat();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active || _pressed;
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap?.call();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _glow]),
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: CustomPaint(
                painter: LivingAyahPainter(
                  pulse: _pulse.value,
                  glow: widget.isGreatVerse
                      ? .6 + _glow.value * .4
                      : (active ? .85 : .18),
                  isGreatVerse: widget.isGreatVerse,
                  isActive: active,
                ),
              ),
            ),
            child!,
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
