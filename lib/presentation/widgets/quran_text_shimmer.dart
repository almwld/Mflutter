import 'package:flutter/material.dart';

/// Applies a restrained moving highlight to Quran text without changing its
/// characters, shaping, font, direction, or layout.
///
/// The animation is local to the rendered text: it does not use a camera,
/// eye/face detection, image tracking, network requests, or generated text.
class QuranTextShimmer extends StatefulWidget {
  const QuranTextShimmer({
    super.key,
    required this.child,
    required this.baseColor,
    this.highlightColor = Colors.white,
    this.duration = const Duration(milliseconds: 6200),
    this.enabled = true,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final bool enabled;

  @override
  State<QuranTextShimmer> createState() => _QuranTextShimmerState();
}

class _QuranTextShimmerState extends State<QuranTextShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant QuranTextShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.enabled || reduceMotion || !TickerMode.of(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false)) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final center = 0.08 + (_controller.value * 0.84);
          final start = (center - 0.12).clamp(0.0, 1.0).toDouble();
          final end = (center + 0.12).clamp(0.0, 1.0).toDouble();
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor.withOpacity(0.92),
                widget.baseColor,
                widget.baseColor,
              ],
              stops: [0.0, start, center, end, 1.0],
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}
