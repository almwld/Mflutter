import 'package:flutter/material.dart';

/// Restrained entrance motion for dynamic canvas blocks.
///
/// Respects the operating-system reduced-motion preference. The animation is
/// paint-only and does not alter block data, layout constraints, or semantics.
class CanvasBlockEntrance extends StatelessWidget {
  const CanvasBlockEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, progress, animatedChild) => Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - progress)),
          child: animatedChild,
        ),
      ),
    );
  }
}
