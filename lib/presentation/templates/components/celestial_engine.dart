import 'dart:math' as math;

/// Deterministic local astronomy kernel using approximate J2000 bright-star coordinates.
abstract final class CelestialEngine {
  static const List<CelestialStar> brightStars = <CelestialStar>[
    CelestialStar(id: 'sirius', name: 'الشعرى اليمانية (Sirius)', rightAscensionHours: 6.7525, declinationDegrees: -16.7161, magnitude: -1.46),
    CelestialStar(id: 'canopus', name: 'سهيل (Canopus)', rightAscensionHours: 6.3992, declinationDegrees: -52.6957, magnitude: -0.74),
    CelestialStar(id: 'arcturus', name: 'السماك الرامح (Arcturus)', rightAscensionHours: 14.2610, declinationDegrees: 19.1825, magnitude: -0.05),
    CelestialStar(id: 'vega', name: 'النسر الواقع (Vega)', rightAscensionHours: 18.6156, declinationDegrees: 38.7837, magnitude: 0.03),
    CelestialStar(id: 'capella', name: 'Capella', rightAscensionHours: 5.2782, declinationDegrees: 45.9980, magnitude: 0.08),
    CelestialStar(id: 'rigel', name: 'رجل الجبار (Rigel)', rightAscensionHours: 5.2423, declinationDegrees: -8.2016, magnitude: 0.13),
    CelestialStar(id: 'procyon', name: 'الشعرى الشامية (Procyon)', rightAscensionHours: 7.6550, declinationDegrees: 5.2250, magnitude: 0.34),
    CelestialStar(id: 'betelgeuse', name: 'منكب الجوزاء (Betelgeuse)', rightAscensionHours: 5.9195, declinationDegrees: 7.4071, magnitude: 0.42),
    CelestialStar(id: 'altair', name: 'النسر الطائر (Altair)', rightAscensionHours: 19.8464, declinationDegrees: 8.8683, magnitude: 0.77),
    CelestialStar(id: 'polaris', name: 'الجدي (Polaris)', rightAscensionHours: 2.5303, declinationDegrees: 89.2641, magnitude: 1.98),
  ];

  static double julianDate(DateTime utc) =>
      utc.toUtc().millisecondsSinceEpoch / 86400000.0 + 2440587.5;

  static double greenwichSiderealDegrees(DateTime utc) {
    final d = julianDate(utc) - 2451545.0;
    return _wrapDegrees(280.46061837 + 360.98564736629 * d);
  }

  static double localSiderealDegrees(DateTime utc, double longitudeDegrees) =>
      _wrapDegrees(greenwichSiderealDegrees(utc) + longitudeDegrees);

  static HorizontalCoordinates toHorizontal({
    required CelestialStar star,
    required DateTime utc,
    required double latitudeDegrees,
    required double longitudeDegrees,
  }) {
    final lst = localSiderealDegrees(utc, longitudeDegrees) * math.pi / 180.0;
    final ra = star.rightAscensionHours * 15.0 * math.pi / 180.0;
    final dec = star.declinationDegrees * math.pi / 180.0;
    final lat = latitudeDegrees * math.pi / 180.0;
    final hourAngle = _wrapRadiansSigned(lst - ra);
    final sinAltitude = math.sin(dec) * math.sin(lat) +
        math.cos(dec) * math.cos(lat) * math.cos(hourAngle);
    final altitude = math.asin(sinAltitude.clamp(-1.0, 1.0));
    final azimuth = math.atan2(
      -math.sin(hourAngle) * math.cos(dec),
      math.sin(dec) * math.cos(lat) -
          math.cos(dec) * math.sin(lat) * math.cos(hourAngle),
    );
    return HorizontalCoordinates(
      altitudeDegrees: altitude * 180.0 / math.pi,
      azimuthDegrees: _wrapDegrees(azimuth * 180.0 / math.pi),
    );
  }

  static double _wrapDegrees(double value) {
    final result = value % 360.0;
    return result < 0 ? result + 360.0 : result;
  }

  static double _wrapRadiansSigned(double value) {
    final fullTurn = 2 * math.pi;
    final wrapped = (value + math.pi) % fullTurn;
    return (wrapped < 0 ? wrapped + fullTurn : wrapped) - math.pi;
  }
}

class CelestialStar {
  const CelestialStar({
    required this.id,
    required this.name,
    required this.rightAscensionHours,
    required this.declinationDegrees,
    required this.magnitude,
  });
  final String id;
  final String name;
  final double rightAscensionHours;
  final double declinationDegrees;
  final double magnitude;
}

class HorizontalCoordinates {
  const HorizontalCoordinates({
    required this.altitudeDegrees,
    required this.azimuthDegrees,
  });
  final double altitudeDegrees;
  final double azimuthDegrees;
}
