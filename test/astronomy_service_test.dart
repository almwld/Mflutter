import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/models/celestial_body.dart';
import 'package:mudabbir_al_asrar/services/astronomy_service.dart';

void main() {
  group('AstronomyService', () {
    test('returns Sun, Moon, five planets and catalog stars', () {
      final bodies = AstronomyService.calculate(
        utc: DateTime.utc(2026, 10, 31, 20),
        latitude: 15.3694,
        longitude: 44.1910,
      );

      expect(bodies.any((body) => body.kind == CelestialKind.sun), isTrue);
      expect(bodies.any((body) => body.kind == CelestialKind.moon), isTrue);
      expect(
        bodies.where((body) => body.kind == CelestialKind.planet).length,
        5,
      );
      expect(
        bodies.where((body) => body.kind == CelestialKind.star).length,
        greaterThanOrEqualTo(10),
      );
    });

    test('all horizontal coordinates are finite and normalized', () {
      final bodies = AstronomyService.calculate(
        utc: DateTime.utc(2026, 1, 1),
        latitude: 15.3694,
        longitude: 44.1910,
      );

      for (final body in bodies) {
        expect(body.azimuth.isFinite, isTrue, reason: body.id);
        expect(body.altitude.isFinite, isTrue, reason: body.id);
        expect(body.azimuth, inInclusiveRange(0, 360), reason: body.id);
        expect(body.altitude, inInclusiveRange(-90, 90), reason: body.id);
      }
    });

    test('Sirius keeps its verified Quranic reference', () {
      final sirius = AstronomyService.calculate(
        utc: DateTime.utc(2026, 10, 31, 20),
        latitude: 15.3694,
        longitude: 44.1910,
      ).singleWhere((body) => body.id == 'sirius');

      expect(sirius.verse, 'وَأَنَّهُ هُوَ رَبُّ الشِّعْرَىٰ');
      expect(sirius.reference, 'النجم: 49');
    });
  });
}
