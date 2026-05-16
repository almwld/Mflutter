import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService _instance = SensorService._();
  factory SensorService() => _instance;
  SensorService._();

  double _pitch = 0.0;
  double _roll = 0.0;
  double _yaw = 0.0;
  double _breathPhase = 0.0; // 0→2π دورة التنفس
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;

  double get pitch => _pitch;
  double get roll => _roll;
  double get yaw => _yaw;
  double get breathPhase => _breathPhase;

  void startListening() {
    _gyroSub?.cancel();
    _accelSub?.cancel();

    _gyroSub = gyroscopeEventStream().listen((event) {
      _pitch = event.x.clamp(-1.0, 1.0);
      _roll = event.y.clamp(-1.0, 1.0);
      _yaw = event.z.clamp(-1.0, 1.0);
    });

    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _breathPhase = (DateTime.now().millisecondsSinceEpoch / 3000 * 2 * pi) % (2 * pi);
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
