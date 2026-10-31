import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';
import 'base_universal_block.dart';
import 'block_event_bus.dart';
import 'block_event_scope.dart';

/// Lightweight 2D coordinate projection. Coordinates must already be normalized
/// and validated by TemplateBlockSchema; this is not a 3D or live map engine.
class SpatialMapBlock extends BaseUniversalBlock {
  const SpatialMapBlock({
    super.key,
    required super.title,
    required super.data,
    super.styleHints,
  });

  @override
  Widget buildBlockContent(BuildContext context) {
    final raw = data['points'] ?? data['stars'] ?? data['particles'];
    final points = raw is List
        ? raw.whereType<Map>().where((point) =>
            point['x'] is num &&
            point['y'] is num &&
            (point['x'] as num).isFinite &&
            (point['y'] as num).isFinite &&
            (point['x'] as num) >= 0 &&
            (point['x'] as num) <= 1 &&
            (point['y'] as num) >= 0 &&
            (point['y'] as num) <= 1).take(250).toList(growable: false)
        : const <Map>[];
    return _InteractiveSpatialContent(
      points: points,
      blockId: data['_canvas_block_id'] is String
          ? data['_canvas_block_id'] as String
          : '',
    );
  }
}

class _InteractiveSpatialContent extends StatefulWidget {
  const _InteractiveSpatialContent({
    required this.points,
    required this.blockId,
  });

  final List<Map> points;
  final String blockId;

  @override
  State<_InteractiveSpatialContent> createState() =>
      _InteractiveSpatialContentState();
}

class _InteractiveSpatialContentState extends State<_InteractiveSpatialContent> {
  BlockEventBus? _bus;
  StreamSubscription<BlockEvent>? _subscription;
  String? _selectedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextBus = BlockEventScope.maybeOf(context);
    if (identical(nextBus, _bus)) return;
    unawaited(_subscription?.cancel());
    _bus = nextBus;
    _subscription = nextBus?.events.listen((event) {
      if (event.type != 'selection_changed' ||
          event.targetBlockId != widget.blockId ||
          event.payload['selection_id'] is! String) return;
      if (!mounted) return;
      setState(() => _selectedId = event.payload['selection_id'] as String);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 220,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _SpatialMapPainter(
              points: widget.points,
              selectedId: _selectedId,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        _selectedId == null
            ? 'إسقاط إحداثي ثنائي الأبعاد للبيانات المقدمة؛ لا يمثل خريطة حية أو مشهدًا ثلاثي الأبعاد.'
            : 'تم تحديد العنصر: $_selectedId',
        textDirection: TextDirection.rtl,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _SpatialMapPainter extends CustomPainter {
  const _SpatialMapPainter({
    required this.points,
    required this.selectedId,
  });

  final List<Map> points;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = MudabbirDesignTokens.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final pointPaint = Paint()
      ..color = MudabbirDesignTokens.cyan
      ..style = PaintingStyle.fill;
    final selectedPaint = Paint()
      ..color = MudabbirDesignTokens.goldBright
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      border,
    );

    // A restrained reference grid; no blur, shader, or per-frame allocation.
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), border);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), border);
    }
    for (final point in points) {
      final pointId = point['id'] ?? point['node_id'] ?? point['label'];
      final selected = selectedId != null && pointId?.toString() == selectedId;
      canvas.drawCircle(
        Offset(
          (point['x'] as num).toDouble() * size.width,
          (point['y'] as num).toDouble() * size.height,
        ),
        selected ? 6.5 : 3.5,
        selected ? selectedPaint : pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpatialMapPainter oldDelegate) =>
      !identical(oldDelegate.points, points) || oldDelegate.selectedId != selectedId;
}
