import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../presentation/templates/components/block_event_bus.dart';
import '../../../presentation/templates/components/block_event_scope.dart';

/// Animated particle matrix for dense, data-driven canvas blocks.
///
/// Particle coordinates and phase values are generated once. Each frame only
/// updates a reusable Float32List consumed by Canvas.drawRawPoints.
class ParticleMatrixBlockWidget extends StatefulWidget {
  const ParticleMatrixBlockWidget({
    super.key,
    this.count = 2400,
    this.columns = 80,
    this.activeRow,
    this.activeNodes = const <int>[],
    this.speed = 1,
    this.height = 260,
    this.backgroundColor = const Color(0xFF0F172A),
    this.accentColor = const Color(0xFF38BDF8),
    this.blockId = 'particle-matrix',
    this.targetBlockId,
    this.nodeIds = const <String>[],
  });

  final int count;
  final int columns;
  final int? activeRow;
  final List<int> activeNodes;
  final double speed;
  final double height;
  final Color backgroundColor;
  final Color accentColor;
  final String blockId;
  final String? targetBlockId;
  final List<String> nodeIds;

  @override
  State<ParticleMatrixBlockWidget> createState() =>
      _ParticleMatrixBlockWidgetState();
}

class _ParticleMatrixBlockWidgetState extends State<ParticleMatrixBlockWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  late Float32List _baseX;
  late Float32List _baseY;
  late Float32List _phase;
  late Float32List _positions;
  late List<int> _activeNodes;
  int? _activeRow;
  BlockEventBus? _bus;
  StreamSubscription<BlockEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _activeRow = widget.activeRow;
    _prepareParticles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextBus = BlockEventScope.maybeOf(context);
    if (identical(nextBus, _bus)) return;
    unawaited(_subscription?.cancel());
    _bus = nextBus;
    _subscription = nextBus?.events.listen((event) {
      if (event.type != 'selection_changed' || event.targetBlockId != widget.blockId) return;
      final selectionId = event.payload['selection_id'];
      if (selectionId is! String) return;
      final index = widget.nodeIds.indexOf(selectionId);
      if (index < 0 || index >= _baseX.length || !mounted) return;
      final columns = widget.columns.clamp(1, _baseX.length).toInt();
      setState(() {
        _activeNodes = <int>[index];
        _activeRow = index ~/ columns;
      });
    });
  }

  @override
  void didUpdateWidget(covariant ParticleMatrixBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count ||
        oldWidget.columns != widget.columns) {
      _prepareParticles();
    }
    if (oldWidget.activeRow != widget.activeRow) _activeRow = widget.activeRow;
    if (oldWidget.activeNodes != widget.activeNodes) {
      _activeNodes = List<int>.unmodifiable(
        widget.activeNodes.where((index) => index >= 0 && index < widget.count),
      );
    }
  }

  void _prepareParticles() {
    final count = widget.count.clamp(1, 8000).toInt();
    final columns = widget.columns.clamp(1, count).toInt();
    _baseX = Float32List(count);
    _baseY = Float32List(count);
    _phase = Float32List(count);
    _positions = Float32List(count * 2);
    final rows = (count / columns).ceil();
    final random = math.Random(0x4D554441);
    for (var i = 0; i < count; i++) {
      final column = i % columns;
      final row = i ~/ columns;
      _baseX[i] = columns == 1 ? .5 : column / (columns - 1);
      _baseY[i] = rows == 1 ? .5 : row / (rows - 1);
      _phase[i] = random.nextDouble() * math.pi * 2;
    }
    _activeNodes = List<int>.unmodifiable(
      widget.activeNodes.where((index) => index >= 0 && index < count),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.clamp(80, 900).toDouble(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(builder: (context, constraints) {
          final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTap(details, canvasSize),
            child: CustomPaint(
          painter: _ParticleMatrixPainter(
            clock: _clock,
            baseX: _baseX,
            baseY: _baseY,
            phase: _phase,
            positions: _positions,
            columns: widget.columns.clamp(1, widget.count.clamp(1, 8000)).toInt(),
            activeRow: _activeRow,
            activeNodes: _activeNodes,
            backgroundColor: widget.backgroundColor,
            accentColor: widget.accentColor,
            speed: widget.speed.clamp(.1, 3).toDouble(),
          ),
          child: const SizedBox.expand(),
            ),
          );
        }),
      ),
    );
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (size.isEmpty) return;
    final x = (details.localPosition.dx / size.width).clamp(0.0, 1.0);
    final y = (details.localPosition.dy / size.height).clamp(0.0, 1.0);
    var best = -1;
    var bestDistance = double.infinity;
    for (var i = 0; i < _baseX.length; i++) {
      final dx = _baseX[i] - x;
      final dy = _baseY[i] - y;
      final distance = dx * dx + dy * dy;
      if (distance < bestDistance) { bestDistance = distance; best = i; }
    }
    if (best < 0) return;
    final columns = widget.columns.clamp(1, _baseX.length).toInt();
    final nodeId = best < widget.nodeIds.length ? widget.nodeIds[best] : 'particle-$best';
    setState(() {
      _activeNodes = <int>[best];
      _activeRow = best ~/ columns;
    });
    _bus?.publish(BlockEvent(
      type: 'selection_changed',
      sourceBlockId: widget.blockId,
      targetBlockId: widget.targetBlockId,
      payload: <String, Object?>{
        'selection_id': nodeId,
        'node_index': best,
        'row_index': best ~/ columns,
      },
    ));
  }
}

class _ParticleMatrixPainter extends CustomPainter {
  _ParticleMatrixPainter({
    required this.clock,
    required this.baseX,
    required this.baseY,
    required this.phase,
    required this.positions,
    required this.columns,
    required this.activeRow,
    required this.activeNodes,
    required this.backgroundColor,
    required this.accentColor,
    required this.speed,
  }) : super(repaint: clock) {
    _pointPaint = Paint()
      ..color = accentColor.withOpacity(.58)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _activePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    _glowPaint = Paint()
      ..color = accentColor.withOpacity(.16)
      ..style = PaintingStyle.fill;
    _backgroundPaint = Paint()..color = backgroundColor;
  }

  final Animation<double> clock;
  final Float32List baseX;
  final Float32List baseY;
  final Float32List phase;
  final Float32List positions;
  final int columns;
  final int? activeRow;
  final List<int> activeNodes;
  final Color backgroundColor;
  final Color accentColor;
  final double speed;
  late final Paint _pointPaint;
  late final Paint _activePaint;
  late final Paint _glowPaint;
  late final Paint _backgroundPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _backgroundPaint);
    final t = clock.value * math.pi * 2 * speed;
    final width = size.width;
    final height = size.height;
    for (var i = 0, p = 0; i < baseX.length; i++, p += 2) {
      final wave = math.sin(t + phase[i] + baseX[i] * 4.2) * 1.7;
      positions[p] = baseX[i] * width;
      positions[p + 1] = baseY[i] * height + wave;
    }
    canvas.drawRawPoints(PointMode.points, positions, _pointPaint);

    final row = activeRow;
    if (row != null && row >= 0) {
      final start = row * columns;
      final end = math.min(start + columns, baseX.length);
      for (var i = start; i < end; i++) {
        final x = positions[i * 2];
        final y = positions[i * 2 + 1];
        canvas.drawCircle(Offset(x, y), 5.2, _glowPaint);
        canvas.drawCircle(Offset(x, y), 2.5, _activePaint);
      }
    }
    for (final index in activeNodes) {
      if (index < 0 || index >= baseX.length) continue;
      final x = positions[index * 2];
      final y = positions[index * 2 + 1];
      canvas.drawCircle(Offset(x, y), 8, _glowPaint);
      canvas.drawCircle(Offset(x, y), 3.4, _activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleMatrixPainter oldDelegate) =>
      oldDelegate.baseX != baseX ||
      oldDelegate.activeRow != activeRow ||
      oldDelegate.activeNodes != activeNodes ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.speed != speed;
}
