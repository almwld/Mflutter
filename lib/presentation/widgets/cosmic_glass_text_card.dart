import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable glass-style text card with a short, accessible entrance animation.
class CosmicGlassTextCard extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  const CosmicGlassTextCard({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsets.all(24),
    this.blurSigma = 16,
  }) : assert(blurSigma >= 0);

  @override
  State<CosmicGlassTextCard> createState() => _CosmicGlassTextCardState();
}

class _CosmicGlassTextCardState extends State<CosmicGlassTextCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller
        ..stop()
        ..value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: widget.textStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                  ),
                  builder: (context, child) => Opacity(
                    opacity: reduceMotion ? 1 : _fadeAnimation.value,
                    child: Transform.scale(
                      scale: reduceMotion ? 1 : _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
