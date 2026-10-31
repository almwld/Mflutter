import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rasterizes shaped Flutter text into a deterministic cloud of points.
///
/// TextPainter performs Arabic shaping, ligatures and bidi layout before the
/// glyphs are sampled. The Quran text itself must always be supplied by the
/// caller from the canonical local Quran corpus; this class only visualizes it.
class DotTextEngine {
  const DotTextEngine._();

  /// Returns glyph sample points in the same coordinate space as [width] and
  /// [height]. [maxPoints] bounds memory and per-frame rendering cost.
  static Future<List<Offset>> rasterize({
    required String text,
    required double width,
    required double height,
    required TextStyle style,
    TextDirection textDirection = TextDirection.rtl,
    TextAlign textAlign = TextAlign.center,
    double sampleStep = 3,
    int maxPoints = 2400,
    double alphaThreshold = 24,
  }) async {
    if (text.trim().isEmpty ||
        !width.isFinite ||
        !height.isFinite ||
        width <= 0 ||
        height <= 0 ||
        sampleStep < 1 ||
        maxPoints < 1) {
      return const <Offset>[];
    }

    final logicalWidth = width.ceil();
    final logicalHeight = height.ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: null,
    )..layout(maxWidth: width);

    final offset = Offset(
      math.max(0, (width - painter.width) / 2),
      math.max(0, (height - painter.height) / 2),
    );
    painter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(logicalWidth, logicalHeight);
    picture.dispose();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return const <Offset>[];
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final candidates = <Offset>[];
      final step = sampleStep.round().clamp(1, 64);
      for (var y = 0; y < logicalHeight; y += step) {
        for (var x = 0; x < logicalWidth; x += step) {
          final alpha = bytes[(y * logicalWidth + x) * 4 + 3];
          if (alpha >= alphaThreshold) {
            candidates.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }
      if (candidates.length <= maxPoints) {
        return List<Offset>.unmodifiable(candidates);
      }

      // Evenly thin the raster samples; preserves the glyph silhouette while
      // keeping a predictable upper bound on particle count.
      final result = <Offset>[];
      final stride = candidates.length / maxPoints;
      for (var i = 0; i < maxPoints; i++) {
        result.add(candidates[(i * stride).floor()]);
      }
      return List<Offset>.unmodifiable(result);
    } finally {
      image.dispose();
    }
  }
}
