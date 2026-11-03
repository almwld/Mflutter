import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'quran_dot_matrix_engine.dart';

/// Reusable real-time renderer for the Quran Dot Matrix engine.
/// It is a live Flutter painter, not a video or a pre-recorded timeline.
class QuranDotMatrixView extends StatefulWidget {
  const QuranDotMatrixView({
    super.key,
    required this.engine,
    this.baseColor = const Color(0xFF9AA9C8),
    this.activeColor = const Color(0xFFF2DC98),
    this.backgroundColor = const Color(0xFF080F25),
    this.showLoadingIndicator = true,
    this.dotRadius = 1.55,
  });

  final QuranDotMatrixEngine engine;
  final Color baseColor;
  final Color activeColor;
  final Color backgroundColor;
  final bool showLoadingIndicator;
  final double dotRadius;

  @override
  State<QuranDotMatrixView> createState() => _QuranDotMatrixViewState();
}

class _QuranDotMatrixViewState extends State<QuranDotMatrixView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    widget.engine.addListener(_onEngineChanged);
    if (!widget.engine.isReady) {
      widget.engine.load();
    }
  }

  @override
  void didUpdateWidget(covariant QuranDotMatrixView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.engine != widget.engine) {
      oldWidget.engine.removeListener(_onEngineChanged);
      widget.engine.addListener(_onEngineChanged);
      if (!widget.engine.isReady) widget.engine.load();
    }
  }

  void _onEngineChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.engine.removeListener(_onEngineChanged);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (engine.isReady)
            RepaintBoundary(
              child: CustomPaint(
                painter: _QuranDotMatrixPainter(
                  engine: engine,
                  animation: _pulse,
                  baseColor: widget.baseColor,
                  activeColor: widget.activeColor,
                  dotRadius: widget.dotRadius,
                ),
              ),
            ),
          if (engine.isLoading && widget.showLoadingIndicator)
            const Center(child: CircularProgressIndicator.adaptive()),
          if (engine.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'تعذّر تحميل بيانات القرآن: ${engine.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuranDotMatrixPainter extends CustomPainter {
  _QuranDotMatrixPainter({
    required this.engine,
    required this.animation,
    required this.baseColor,
    required this.activeColor,
    required this.dotRadius,
  }) : super(repaint: animation);

  final QuranDotMatrixEngine engine;
  final Animation<double> animation;
  final Color baseColor;
  final Color activeColor;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final dots = engine.dots;
    if (dots.isEmpty || size.isEmpty) return;

    final columns = engine.columns;
    final rows = engine.rowCount;
    const horizontalInset = 0.055;
    const verticalInset = 0.09;
    final availableWidth = size.width * (1 - horizontalInset * 2);
    final availableHeight = size.height * (1 - verticalInset * 2);
    final cell = math.min(
      availableWidth / columns,
      availableHeight / rows,
    );
    final gridWidth = cell * columns;
    final gridHeight = cell * rows;
    final originX = (size.width - gridWidth) / 2;
    final originY = (size.height - gridHeight) / 2;
    final active = engine.activeIndices;
    final pulse = 0.5 + 0.5 * math.sin(animation.value * math.pi * 2);
    final basePaint = Paint()..color = baseColor;
    final activePaint = Paint()..color = activeColor;
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.17 + pulse * 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.2);

    for (final dot in dots) {
      final row = dot.index ~/ columns;
      final logicalColumn = dot.index % columns;
      // Arabic reading order: the first ayah starts at the right edge.
      final column = columns - 1 - logicalColumn;
      final center = Offset(
        originX + (column + 0.5) * cell,
        originY + (row + 0.5) * cell,
      );
      if (active.contains(dot.index)) {
        canvas.drawCircle(center, dotRadius * 2.25, glowPaint);
        canvas.drawCircle(center, dotRadius * (1.2 + pulse * 0.35), activePaint);
      } else {
        canvas.drawCircle(center, dotRadius * 0.72, basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QuranDotMatrixPainter oldDelegate) =>
      oldDelegate.engine != engine ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.dotRadius != dotRadius;
}
