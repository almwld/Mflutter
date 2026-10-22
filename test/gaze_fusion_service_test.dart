import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/services/gaze_fusion_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('GazeFusion fits and restores a nine-point calibration', () async {
    final service = GazeFusionService.instance;
    await service.clear();
    expect(service.isCalibrated, isFalse);

    final samples = <GazeCalibrationSample>[];
    for (final row in [(80.0, .18), (0.0, .5), (-80.0, .82)]) {
      for (final col in [(-100.0, .15), (0.0, .5), (100.0, .85)]) {
        samples.add(GazeCalibrationSample(
          yawDegrees: col.$1,
          pitchDegrees: row.$1,
          targetX: col.$2,
          targetY: row.$2,
        ));
      }
    }
    await service.fit(samples: samples);
    expect(service.isCalibrated, isTrue);

    final center = service.map(
      yawDegrees: 0,
      pitchDegrees: 0,
      width: 1000,
      height: 800,
    );
    expect(center.x, closeTo(500, 2));
    expect(center.y, closeTo(400, 2));

    final restored = GazeFusionService.instance;
    await restored.load();
    expect(restored.isCalibrated, isTrue);
    await restored.clear();
    expect(restored.isCalibrated, isFalse);
  });

  test('dwell controller activates only after stable confident gaze', () {
    final dwell = GazeDwellController(
      dwellDuration: const Duration(milliseconds: 850),
      activationRadius: 20,
      cooldown: const Duration(milliseconds: 900),
    );
    final start = DateTime(2026, 10, 22, 1);
    expect(
      dwell.update(x: 100, y: 100, confidence: .9, now: start).intent,
      GazeIntent.none,
    );
    expect(
      dwell.update(
        x: 105,
        y: 102,
        confidence: .9,
        now: start.add(const Duration(milliseconds: 900)),
      ).intent,
      GazeIntent.dwellActivated,
    );
    expect(
      dwell.update(
        x: 103,
        y: 100,
        confidence: .2,
        now: start.add(const Duration(seconds: 2)),
      ).intent,
      GazeIntent.none,
    );
  });
}
