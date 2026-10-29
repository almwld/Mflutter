import 'dart:math' as math;

/// Lightweight, documented solar-position calculations.
/// These equations are suitable for educational estimates, not navigation,
/// telescope pointing, eclipses, or precision ephemeris work.
class SolarCoordinates {
  final double julianDay;
  final double eclipticLongitudeDegrees;
  final double rightAscensionDegrees;
  final double declinationDegrees;
  final double equationOfTimeMinutes;

  const SolarCoordinates({
    required this.julianDay,
    required this.eclipticLongitudeDegrees,
    required this.rightAscensionDegrees,
    required this.declinationDegrees,
    required this.equationOfTimeMinutes,
  });
}

class AstronomyCalculationsService {
  AstronomyCalculationsService._();

  static double julianDayUtc(DateTime dateTime) {
    final utc = dateTime.toUtc();
    var year = utc.year;
    var month = utc.month;
    final day = utc.day +
        (utc.hour + (utc.minute + (utc.second + utc.millisecond / 1000) / 60) / 60) / 24;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() + day + b - 1524.5;
  }

  /// Low-precision apparent solar coordinates, in degrees.
  static SolarCoordinates solarCoordinates(DateTime dateTime) {
    final jd = julianDayUtc(dateTime);
    final t = (jd - 2451545.0) / 36525.0;
    final meanLongitude = _normalizeDegrees(280.46646 + t * (36000.76983 + 0.0003032 * t));
    final meanAnomaly = _toRadians(_normalizeDegrees(357.52911 + t * (35999.05029 - 0.0001537 * t)));
    final eccentricity = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
    final center = math.sin(meanAnomaly) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * meanAnomaly) * (0.019993 - 0.000101 * t) +
        math.sin(3 * meanAnomaly) * 0.000289;
    final omega = _toRadians(125.04 - 1934.136 * t);
    final apparentLongitude = _normalizeDegrees(meanLongitude + center - 0.00569 - 0.00478 * math.sin(omega));
    final meanObliquityArcseconds = 84381.448 - 46.8150 * t - 0.00059 * t * t + 0.001813 * t * t * t;
    final obliquity = _toRadians(meanObliquityArcseconds / 3600 + 0.00256 * math.cos(omega));
    final longitudeRad = _toRadians(apparentLongitude);
    final ra = math.atan2(math.cos(obliquity) * math.sin(longitudeRad), math.cos(longitudeRad));
    final declination = math.asin(math.sin(obliquity) * math.sin(longitudeRad));

    final y = math.pow(math.tan(obliquity / 2), 2).toDouble();
    final l0 = _toRadians(meanLongitude);
    final eq = y * math.sin(2 * l0) -
        2 * eccentricity * math.sin(meanAnomaly) +
        4 * eccentricity * y * math.sin(meanAnomaly) * math.cos(2 * l0) -
        0.5 * y * y * math.sin(4 * l0) -
        1.25 * eccentricity * eccentricity * math.sin(2 * meanAnomaly);
    final equationMinutes = 4 * _toDegrees(eq);

    return SolarCoordinates(
      julianDay: jd,
      eclipticLongitudeDegrees: apparentLongitude,
      rightAscensionDegrees: _normalizeDegrees(_toDegrees(ra)),
      declinationDegrees: _toDegrees(declination),
      equationOfTimeMinutes: equationMinutes,
    );
  }

  static double _normalizeDegrees(double value) => (value % 360 + 360) % 360;
  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
