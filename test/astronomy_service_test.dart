import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/models/celestial_body.dart';
import 'package:mudabbir_al_asrar/services/astronomy_service.dart';

void main() {
  late List<CelestialBody> bodies;

  setUpAll(() {
    // Run the VSOP87 ephemeris once; all assertions share the same snapshot.
    bodies = AstronomyService.calculate(
      utc: DateTime.utc(2026, 10, 31, 20),
      latitude: 15.3694,
      longitude: 44.1910,
    );
  });

  group('AstronomyService', () {
    test('returns Sun, Moon, five planets and expanded catalog stars', () {
      expect(bodies.any((body) => body.kind == CelestialKind.sun), isTrue);
      expect(bodies.any((body) => body.kind == CelestialKind.moon), isTrue);
      expect(
        bodies.where((body) => body.kind == CelestialKind.planet).length,
        5,
      );
      expect(
        bodies.where((body) => body.kind == CelestialKind.star).length,
        greaterThanOrEqualTo(50),
      );
    });

    test('all horizontal coordinates are finite and normalized', () {
      for (final body in bodies) {
        expect(body.azimuth.isFinite, isTrue, reason: body.id);
        expect(body.altitude.isFinite, isTrue, reason: body.id);
        expect(body.azimuth, inInclusiveRange(0, 360), reason: body.id);
        expect(body.altitude, inInclusiveRange(-90, 90), reason: body.id);
      }
    });

    test('exposes solar-system distances and lunar phase metadata', () {
      final sun = bodies.singleWhere((body) => body.id == 'sun');
      final moon = bodies.singleWhere((body) => body.id == 'moon');
      final sirius = bodies.singleWhere((body) => body.id == 'sirius');
      final venus = bodies.singleWhere((body) => body.id == 'venus');

      expect(sun.distanceAu, isNotNull);
      expect(sun.distanceAu!, inInclusiveRange(0.9, 1.1));
      expect(moon.distanceAu, inInclusiveRange(0.002, 0.003));
      expect(moon.illuminatedFraction, inInclusiveRange(0, 1));
      expect(moon.phaseAngleDegrees, inInclusiveRange(0, 180));
      expect(moon.phaseName, isNotEmpty);
      expect(venus.distanceAu, greaterThan(0));
      expect(sirius.distanceLightYears, closeTo(8.6, 0.1));
    });

    test('Sirius keeps its verified Quranic reference', () {
      final sirius = bodies.singleWhere((body) => body.id == 'sirius');
      expect(sirius.verse, 'وَأَنَّهُ هُوَ رَبُّ الشِّعْرَىٰ');
      expect(sirius.reference, 'النجم: 49');
    });

    test('expanded catalog includes southern and northern anchors', () {
      final ids = bodies.map((body) => body.id).toSet();
      expect(ids, containsAll([
        'polaris', 'deneb', 'altair', 'canopus', 'achernar',
        'acrux', 'fomalhaut', 'alnilam', 'mizar', 'antares',
      ]));
    });
  });
}
