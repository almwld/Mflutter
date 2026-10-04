import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeospatialInsightService {
  GeospatialInsightService._();
  static final instance = GeospatialInsightService._();
  Position? _position;
  StreamSubscription<Position>? _subscription;
  Position? get position => _position;
  double get altitude => _position?.altitude ?? 0;
  double get latitude => _position?.latitude ?? 0;
  double get longitude => _position?.longitude ?? 0;

  Future<bool> start() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return false;
    _position = await Geolocator.getCurrentPosition();
    await _subscription?.cancel();
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((value) => _position = value);
    return true;
  }
  Future<void> stop() async { await _subscription?.cancel(); _subscription = null; }
  String getTopography() => altitude > 1000 ? 'mountains' : altitude < 50 ? 'coastal' : 'plains';
  double distanceTo(double lat, double lon) => Geolocator.distanceBetween(latitude, longitude, lat, lon);
}
