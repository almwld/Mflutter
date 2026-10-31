import 'dart:math' as math;

import 'package:astronomia/coord.dart' as coord;
import 'package:astronomia/elliptic.dart' as elliptic;
import 'package:astronomia/globe.dart' as globe;
import 'package:astronomia/moonposition.dart' as moon;
import 'package:astronomia/nutation.dart' as nutation;
import 'package:astronomia/planetposition.dart' as pp;
import 'package:astronomia/parallax.dart' as parallax;
import 'package:astronomia/precess.dart' as precess;
import 'package:astronomia/sidereal.dart' as sidereal;
import 'package:astronomia/solar.dart' as solar;

import '../models/celestial_body.dart';

/// Apparent sky positions using Meeus algorithms and VSOP87 planetary theory.
///
/// The package's solar/lunar/planetary routines provide geocentric equatorial
/// coordinates; this service converts them to the observer's local horizon.
/// Fixed stars are precessed from J2000 to the observation epoch. Lunar
/// topocentric parallax is applied; atmospheric refraction is not applied.
class AstronomyService {
  const AstronomyService._();

  static const double _rad = math.pi / 180;
  static const double _deg = 180 / math.pi;
  static final pp.Planet _earth = pp.Planet(pp.planetEarth);

  static final List<_PlanetSpec> _planets = [
    _PlanetSpec('mercury', 'عطارد', 'Mercury',
        pp.Planet(pp.planetMercury), 0xFFB7B9C2, -0.4),
    _PlanetSpec('venus', 'الزهرة', 'Venus',
        pp.Planet(pp.planetVenus), 0xFFFFE1A3, -4.0),
    _PlanetSpec('mars', 'المريخ', 'Mars',
        pp.Planet(pp.planetMars), 0xFFFF806D, 1.0),
    _PlanetSpec('jupiter', 'المشتري', 'Jupiter',
        pp.Planet(pp.planetJupiter), 0xFFFFC98A, -2.0),
    _PlanetSpec('saturn', 'زحل', 'Saturn',
        pp.Planet(pp.planetSaturn), 0xFFD8C6A5, 0.7),
  ];

  static const List<_StarSpec> _stars = [
    _StarSpec('sirius', 'الشعرى اليمانية', 'Sirius',
        6.752472, -16.7161, -1.46, 0xFFEAF4FF,
        'وَأَنَّهُ هُوَ رَبُّ الشِّعْرَىٰ', 'النجم: 49',
        'سورة النجم، الآية 49. الآية تذكر الشعرى ولا تقدم إحداثيات رصدية لها.'),
    _StarSpec('polaris', 'النجم القطبي', 'Polaris',
        2.530306, 89.2641, 1.98, 0xFFDDEBFF, null, null,
        'نجم قريب من القطب الشمالي السماوي.'),
    _StarSpec('vega', 'النسر الواقع', 'Vega',
        18.615639, 38.7837, 0.03, 0xFFE5F0FF, null, null,
        'نجم ساطع في كوكبة القيثارة.'),
    _StarSpec('arcturus', 'السماك الرامح', 'Arcturus',
        14.261028, 19.1825, -0.05, 0xFFFFD8B2, null, null,
        'نجم ساطع في كوكبة العواء.'),
    _StarSpec('capella', 'العيوق', 'Capella',
        5.278167, 45.9980, 0.08, 0xFFFFE5C4, null, null,
        'نجم ساطع في كوكبة ممسك الأعنة.'),
    _StarSpec('procyon', 'الشعرى الشامية', 'Procyon',
        7.655028, 5.2250, 0.34, 0xFFEAF4FF, null, null,
        'نجم ساطع في كوكبة الكلب الأصغر.'),
    _StarSpec('betelgeuse', 'منكب الجوزاء', 'Betelgeuse',
        5.919528, 7.4071, 0.50, 0xFFFFB28A, null, null,
        'نجم أحمر عملاق في كوكبة الجبار.'),
    _StarSpec('rigel', 'رجل الجبار', 'Rigel',
        5.242306, -8.2056, 0.13, 0xFFBFDFFF, null, null,
        'نجم أزرق فائق العملاق في كوكبة الجبار.'),
    _StarSpec('bellatrix', 'منطقة الجبار', 'Bellatrix',
        5.418861, 6.3497, 1.64, 0xFFD9E8FF, null, null,
        'نجم في كتف كوكبة الجبار.'),
    _StarSpec('saiph', 'سيف الجبار', 'Saiph',
        5.795944, -9.6696, 2.06, 0xFFD5E5FF, null, null,
        'نجم في قدم كوكبة الجبار.'),
    _StarSpec('aldebaran', 'الدبران', 'Aldebaran',
        4.598667, 16.5093, 0.85, 0xFFFFC18A, null, null,
        'نجم برتقالي في كوكبة الثور.'),
    _StarSpec('spica', 'السماك الأعزل', 'Spica',
        13.419889, -11.1614, 0.97, 0xFFDDEBFF, null, null,
        'نجم ساطع في كوكبة العذراء.'),
    _StarSpec('antares', 'قلب العقرب', 'Antares',
        16.490139, -26.4319, 1.06, 0xFFFFA27E, null, null,
        'نجم أحمر عملاق في كوكبة العقرب.'),
  ];

  static List<CelestialBody> calculate({
    required DateTime utc,
    required double latitude,
    required double longitude,
  }) {
    final date = utc.toUtc();
    final jd = date.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
    // Delta-T is below one minute for the current epoch; this approximation
    // keeps the ephemeris input in dynamical time without a network lookup.
    final jde = jd + 69.0 / 86400.0;
    final latitudeRadians = latitude * _rad;
    final greenwichSiderealRadians =
        sidereal.apparent(jd) / 240.0 * _rad;
    final localSiderealDegrees =
        _normalize(greenwichSiderealRadians * _deg + longitude);
    final year = _decimalYear(date);

    final bodies = <CelestialBody>[];

    final sun = solar.apparentEquatorial(jde);
    bodies.add(_fromEquatorial(
      id: 'sun',
      nameAr: 'الشمس',
      nameEn: 'Sun',
      kind: CelestialKind.sun,
      ra: sun.ra,
      dec: sun.dec,
      magnitude: -26.7,
      color: 0xFFFFD27A,
      latitudeRadians: latitudeRadians,
      localSiderealDegrees: localSiderealDegrees,
      note: 'إحداثيات ظاهرية محسوبة بخوارزميات Meeus.',
    ));

    final moonPosition = moon.position(jde);
    final obliquity = nutation.meanObliquity(jde);
    final moonGeocentric = coord.eclToEq(
      moonPosition.lon,
      moonPosition.lat,
      math.sin(obliquity),
      math.cos(obliquity),
    );
    final observerParallax = globe.parallaxConstants(latitudeRadians, 0);
    final moonDistanceAu = moonPosition.delta / 149597870.7;
    final moonHourAngle = localSiderealDegrees * _rad - moonGeocentric.ra;
    final moonEquatorial = parallax.topocentric(
      moonGeocentric.ra,
      moonGeocentric.dec,
      moonDistanceAu,
      observerParallax.rhsSinPhiPrime,
      observerParallax.rhoCosPrime,
      moonHourAngle,
      math.sin(parallax.horizontal(moonDistanceAu)),
    );
    bodies.add(_fromEquatorial(
      id: 'moon',
      nameAr: 'القمر',
      nameEn: 'Moon',
      kind: CelestialKind.moon,
      ra: moonEquatorial.ra,
      dec: moonEquatorial.dec,
      magnitude: -12.0,
      color: 0xFFE4E9F5,
      latitudeRadians: latitudeRadians,
      localSiderealDegrees: localSiderealDegrees,
      verse: 'وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ',
      reference: 'يس: 39',
      note: 'موضع قمري محسوب بخوارزميات Meeus مع تصحيح اختلاف المنظر الطبوغرافي؛ الانكسار الجوي غير مطبق.',
    ));

    for (final spec in _planets) {
      final equatorial = elliptic.position(spec.planet, _earth, jde);
      bodies.add(_fromEquatorial(
        id: spec.id,
        nameAr: spec.nameAr,
        nameEn: spec.nameEn,
        kind: CelestialKind.planet,
        ra: equatorial.ra,
        dec: equatorial.dec,
        magnitude: spec.magnitude,
        color: spec.color,
        latitudeRadians: latitudeRadians,
        localSiderealDegrees: localSiderealDegrees,
        note: 'إحداثيات كوكبية محسوبة باستخدام VSOP87 وMeeus.',
      ));
    }

    for (final star in _stars) {
      final precessed = precess.position(
        star.rightAscensionHours * 15 * _rad,
        star.declination * _rad,
        2000.0,
        year,
        0,
        0,
      );
      bodies.add(_fromEquatorial(
        id: star.id,
        nameAr: star.nameAr,
        nameEn: star.nameEn,
        kind: CelestialKind.star,
        ra: precessed.ra,
        dec: precessed.dec,
        magnitude: star.magnitude,
        color: star.color,
        latitudeRadians: latitudeRadians,
        localSiderealDegrees: localSiderealDegrees,
        verse: star.verse,
        reference: star.reference,
        note: star.note,
      ));
    }

    return List<CelestialBody>.unmodifiable(bodies);
  }

  static CelestialBody _fromEquatorial({
    required String id,
    required String nameAr,
    required String nameEn,
    required CelestialKind kind,
    required double ra,
    required double dec,
    required double magnitude,
    required int color,
    required double latitudeRadians,
    required double localSiderealDegrees,
    String? verse,
    String? reference,
    required String note,
  }) {
    final hourAngle =
        _signedAngle(localSiderealDegrees - ra * _deg) * _rad;
    final sinAltitude = math.sin(latitudeRadians) * math.sin(dec) +
        math.cos(latitudeRadians) * math.cos(dec) * math.cos(hourAngle);
    final altitude = math.asin(
      sinAltitude.clamp(-1.0, 1.0).toDouble(),
    );
    final azimuth = math.atan2(
      -math.sin(hourAngle),
      math.tan(dec) * math.cos(latitudeRadians) -
          math.sin(latitudeRadians) * math.cos(hourAngle),
    );
    return CelestialBody(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      kind: kind,
      azimuth: _normalize(azimuth * _deg),
      altitude: altitude * _deg,
      magnitude: magnitude,
      colorValue: color,
      verse: verse,
      reference: reference,
      note: note,
    );
  }

  static double _decimalYear(DateTime date) {
    final start = DateTime.utc(date.year);
    final next = DateTime.utc(date.year + 1);
    final elapsed = date.difference(start).inMicroseconds.toDouble();
    final yearLength = next.difference(start).inMicroseconds.toDouble();
    return date.year + elapsed / yearLength;
  }

  static double _normalize(double degrees) =>
      ((degrees % 360) + 360) % 360;

  static double _signedAngle(double degrees) {
    final value = _normalize(degrees);
    return value > 180 ? value - 360 : value;
  }
}

class _PlanetSpec {
  final String id;
  final String nameAr;
  final String nameEn;
  final pp.Planet planet;
  final int color;
  final double magnitude;

  const _PlanetSpec(
    this.id,
    this.nameAr,
    this.nameEn,
    this.planet,
    this.color,
    this.magnitude,
  );
}

class _StarSpec {
  final String id;
  final String nameAr;
  final String nameEn;
  final double rightAscensionHours;
  final double declination;
  final double magnitude;
  final int color;
  final String? verse;
  final String? reference;
  final String note;

  const _StarSpec(
    this.id,
    this.nameAr,
    this.nameEn,
    this.rightAscensionHours,
    this.declination,
    this.magnitude,
    this.color,
    this.verse,
    this.reference,
    this.note,
  );
}
