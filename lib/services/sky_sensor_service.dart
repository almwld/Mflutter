import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SkyOrientation {
  final double heading;
  final double pitch;
  final double roll;
  final bool hasHeading;
  final bool hasTilt;

  const SkyOrientation({
    required this.heading,
    required this.pitch,
    required this.roll,
    required this.hasHeading,
    required this.hasTilt,
  });

  static const unavailable = SkyOrientation(
    heading: 0,
    pitch: 0,
    roll: 0,
    hasHeading: false,
    hasTilt: false,
  );
}

/// Combines the platform compass heading with accelerometer gravity and
/// gyroscope integration. Heading is magnetic on Android unless the platform
/// supplies a true heading; magnetic declination is not silently guessed.
class SkySensorService {
  final StreamController<SkyOrientation> _controller =
      StreamController<SkyOrientation>.broadcast();

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  double? _heading;
  double? _pitch;
  double? _roll;
  double _accelPitch = 0;
  double _accelRoll = 0;
  DateTime? _lastGyroAt;
  bool _hasTilt = false;

  Stream<SkyOrientation> get stream => _controller.stream;

  void start() {
    _compassSubscription ??= FlutterCompass.events?.listen(
      (event) {
        final value = event.heading;
        if (value == null || !value.isFinite) return;
        _heading = _smoothAngle(_heading, value, .22);
        _emit();
      },
      onError: (_) {},
    );

    _accelerometerSubscription ??= accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      _onAccelerometer,
      onError: (_) {},
    );

    _gyroscopeSubscription ??= gyroscopeEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      _onGyroscope,
      onError: (_) {},
    );
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if (magnitude < 6 || magnitude > 13) return;

    // Device coordinates are converted to a portrait-screen frame so a phone
    // held upright has a neutral pitch and roll near zero.
    final x = event.x / magnitude;
    final y = -event.y / magnitude;
    final z = event.z / magnitude;
    _accelPitch = math.atan2(-z, math.sqrt(x * x + y * y));
    _accelRoll = math.atan2(x, y);

    _pitch ??= _accelPitch;
    _roll ??= _accelRoll;
    _pitch = _blend(_pitch!, _accelPitch, .08);
    _roll = _blend(_roll!, _accelRoll, .08);
    _hasTilt = true;
    _emit();
  }

  void _onGyroscope(GyroscopeEvent event) {
    final now = DateTime.now();
    final previous = _lastGyroAt;
    _lastGyroAt = now;
    if (previous == null || _pitch == null || _roll == null) return;
    final dt = now.difference(previous).inMicroseconds / 1000000.0;
    if (dt <= 0 || dt > .15) return;

    _pitch = _blend(_pitch! + event.y * dt, _accelPitch, .025);
    _roll = _blend(_roll! + event.x * dt, _accelRoll, .025);
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(SkyOrientation(
      heading: _heading ?? 0,
      pitch: (_pitch ?? 0) * 180 / math.pi,
      roll: (_roll ?? 0) * 180 / math.pi,
      hasHeading: _heading != null,
      hasTilt: _hasTilt,
    ));
  }

  double _smoothAngle(double? previous, double next, double amount) {
    if (previous == null) return (next + 360) % 360;
    final delta = ((next - previous + 540) % 360) - 180;
    return (previous + delta * amount + 360) % 360;
  }

  double _blend(double previous, double next, double amount) =>
      previous + (next - previous) * amount;

  Future<void> dispose() async {
    await _compassSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    await _controller.close();
  }
}
