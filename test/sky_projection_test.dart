import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mudabbir_al_asrar/services/sky_projection.dart';

void main() {
  const viewport = Size(400, 800);

  test('projects the optical axis to the screen center', () {
    final point = SkyProjection.project(
      azimuth: 10,
      altitude: 25,
      heading: 10,
      pitch: 25,
      roll: 0,
      horizontalFov: 65,
      viewport: viewport,
    );
    expect(point, const Offset(200, 400));
  });

  test('uses wrapped azimuth differences across north', () {
    final point = SkyProjection.project(
      azimuth: 1,
      altitude: 0,
      heading: 359,
      pitch: 0,
      roll: 0,
      horizontalFov: 65,
      viewport: viewport,
    );
    expect(point, isNotNull);
    expect(point!.dx, greaterThan(200));
  });

  test('rejects objects outside horizon and behind the projection plane', () {
    expect(SkyProjection.project(
      azimuth: 0, altitude: -10, heading: 0, pitch: 0, roll: 0,
      horizontalFov: 65, viewport: viewport,
    ), isNull);
    expect(SkyProjection.project(
      azimuth: 100, altitude: 0, heading: 0, pitch: 0, roll: 0,
      horizontalFov: 65, viewport: viewport,
    ), isNull);
  });

  test('rejects invalid field of view and degenerate viewport', () {
    expect(SkyProjection.project(
      azimuth: 0, altitude: 0, heading: 0, pitch: 0, roll: 0,
      horizontalFov: 180, viewport: viewport,
    ), isNull);
    expect(SkyProjection.project(
      azimuth: 0, altitude: 0, heading: 0, pitch: 0, roll: 0,
      horizontalFov: 65, viewport: Size.zero,
    ), isNull);
  });

  test('horizontal FOV controls horizontal displacement', () {
    Offset projectAt(double fov) => SkyProjection.project(
      azimuth: 15, altitude: 0, heading: 0, pitch: 0, roll: 0,
      horizontalFov: fov, viewport: viewport,
    )!;
    expect((projectAt(40).dx - 200).abs(),
        greaterThan((projectAt(90).dx - 200).abs()));
  });
}
