import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/core/graphics/dot_text_engine.dart';

void main() {
  group('DotTextEngine', () {
    test('returns no points for empty text', () async {
      final points = await DotTextEngine.rasterize(
        text: '   ',
        width: 240,
        height: 100,
        style: const TextStyle(fontSize: 28),
      );
      expect(points, isEmpty);
    });

    test('rasterizes shaped Arabic text into bounded points', () async {
      final points = await DotTextEngine.rasterize(
        text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        width: 420,
        height: 120,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 36,
          color: Colors.white,
        ),
        maxPoints: 320,
      );
      expect(points, isNotEmpty);
      expect(points.length, lessThanOrEqualTo(320));
      expect(points.every((point) =>
          point.dx >= 0 && point.dx < 420 &&
          point.dy >= 0 && point.dy < 120), isTrue);
    });

    test('rejects invalid dimensions', () async {
      final points = await DotTextEngine.rasterize(
        text: 'نص',
        width: 0,
        height: 100,
        style: const TextStyle(fontSize: 20),
      );
      expect(points, isEmpty);
    });
  });
}
