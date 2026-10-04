import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService _instance = SensorService._();
  factory SensorService() => _instance;
  SensorService._();

  double _pitch = 0.0;
  double _roll = 0.0;
  double _yaw = 0.0;
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;

  double get pitch => _pitch;
  double get roll => _roll;
  double get yaw => _yaw;

  void startListening() {
    _gyroSub?.cancel();
    _accelSub?.cancel();

    _gyroSub = gyroscopeEventStream().listen((event) {
      _pitch = event.x.clamp(-1.0, 1.0);
      _roll = event.y.clamp(-1.0, 1.0);
      _yaw = event.z.clamp(-1.0, 1.0);
    });

    _accelSub = accelerometerEventStream().listen((event) {
      // The stream is intentionally consumed only for real sensor activity.
      // No synthetic breathing phase is derived from wall-clock time.
    });
  }

  void stopListening() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
  }

  void dispose() {
    stopListening();
  }
}
