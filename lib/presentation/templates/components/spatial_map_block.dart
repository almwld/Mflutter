import 'package:flutter/material.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';
import 'base_universal_block.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SpatialMapPainter(points: points),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'إسقاط إحداثي ثنائي الأبعاد للبيانات المقدمة؛ لا يمثل خريطة حية أو مشهدًا ثلاثي الأبعاد.',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SpatialMapPainter extends CustomPainter {
  const _SpatialMapPainter({required this.points});

  final List<Map> points;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = MudabbirDesignTokens.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final pointPaint = Paint()
      ..color = MudabbirDesignTokens.cyan
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
      canvas.drawCircle(
        Offset(
          (point['x'] as num).toDouble() * size.width,
          (point['y'] as num).toDouble() * size.height,
        ),
        3.5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpatialMapPainter oldDelegate) =>
      !identical(oldDelegate.points, points);
}
