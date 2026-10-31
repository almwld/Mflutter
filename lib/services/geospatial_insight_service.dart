import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GeospatialInsightService extends ChangeNotifier {
  GeospatialInsightService._();
  static final instance = GeospatialInsightService._();
  Position? _position;
  StreamSubscription<Position>? _subscription;
  Position? get position => _position;
  double get altitude => _position?.altitude ?? 0;
  double get latitude => _position?.latitude ?? 0;
  double get longitude => _position?.longitude ?? 0;

  Future<bool> start() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _position = null;
      notifyListeners();
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _position = null;
      notifyListeners();
      return false;
    }
    _position = await Geolocator.getCurrentPosition();
    notifyListeners();
    await _subscription?.cancel();
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((value) {
      _position = value;
      notifyListeners();
    });
    return true;
  }
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _position = null;
    notifyListeners();
  }
  String getTopography() => altitude > 1000 ? 'mountains' : altitude < 50 ? 'coastal' : 'plains';
  double distanceTo(double lat, double lon) => Geolocator.distanceBetween(latitude, longitude, lat, lon);
}
