import 'dart:math' as math;

import '../models/celestial_body.dart';

/// Low-precision analytical ephemeris based on classical orbital elements.
///
/// Suitable for a mobile sky-finder overlay (typical errors are larger than
/// professional ephemerides, especially for the Moon and outer planets).
/// It is not intended for navigation, occultation timing, or scientific work.
class AstronomyService {
  const AstronomyService._();

  static const double _rad = math.pi / 180.0;
  static const double _deg = 180.0 / math.pi;

  static List<CelestialBody> calculate({
    required DateTime utc,
    required double latitude,
    required double longitude,
  }) {
    final date = utc.toUtc();
    final jd = date.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
    final d = jd - 2451543.5;
    final obliquity = (23.4393 - 3.563e-7 * d) * _rad;

    final earth = _heliocentric(
      _Orbit(0, 0, 282.9404 + 4.70935e-5 * d, 1,
          0.016709 - 1.151e-9 * d, 356.0470 + 0.9856002585 * d),
    );
    final sunEq = _eclipticToEquatorial(
      -earth[0], -earth[1], -earth[2], obliquity,
    );

    final bodies = <CelestialBody>[
      _horizontalBody(
        id: 'sun',
        nameAr: 'الشمس',
        nameEn: 'Sun',
        kind: CelestialKind.sun,
        equatorial: sunEq,
        magnitude: -26.7,
        color: 0xFFFFD27A,
        latitude: latitude,
        longitude: longitude,
        jd: jd,
        note: 'موضع الشمس محسوب تقريبياً من عناصر مدار الأرض.',
      ),
    ];

    final moonEq = _moonEquatorial(d, obliquity);
    bodies.add(_horizontalBody(
      id: 'moon',
      nameAr: 'القمر',
      nameEn: 'Moon',
      kind: CelestialKind.moon,
      equatorial: moonEq,
      magnitude: -12.0,
      color: 0xFFE4E9F5,
      latitude: latitude,
      longitude: longitude,
      jd: jd,
      verse: 'وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ',
      reference: 'يس: 39',
      note: 'موضع قمري تقريبي؛ أطوار القمر لا تُستنتج من شكل الرمز.',
    ));

    final planets = <_PlanetSpec>[
      _PlanetSpec('mercury', 'عطارد', 'Mercury', 48.3313, 7.0047,
          29.1241, 0.387098, 0.205635, 168.6562, 3.24587e-5,
          5.00e-8, 1.01444e-5, 5.59e-10, 4.0923344368, 0xFFB7B9C2, -0.4),
      _PlanetSpec('venus', 'الزهرة', 'Venus', 76.6799, 3.3946,
          54.8910, 0.723330, 0.006773, 48.0052, 2.46590e-5,
          2.75e-8, 1.38374e-5, -1.302e-9, 1.6021302244, 0xFFFFE1A3, -4.0),
      _PlanetSpec('mars', 'المريخ', 'Mars', 49.5574, 1.8497,
          286.5016, 1.523688, 0.093405, 18.6021, 2.11081e-5,
          -1.78e-8, 2.92961e-5, 2.516e-9, 0.5240207766, 0xFFFF806D, 1.0),
      _PlanetSpec('jupiter', 'المشتري', 'Jupiter', 100.4542, 1.3030,
          273.8777, 5.20256, 0.048498, 19.8950, 2.76854e-5,
          -1.557e-7, 1.64505e-5, 4.469e-9, 0.0830853001, 0xFFFFC98A, -2.0),
      _PlanetSpec('saturn', 'زحل', 'Saturn', 113.6634, 2.4886,
          339.3939, 9.55475, 0.055546, 316.9670, 2.38980e-5,
          -1.081e-7, 2.97661e-5, -2.077e-9, 0.0334442282, 0xFFD8C6A5, 0.7),
    ];

    for (final spec in planets) {
      final orbit = _Orbit(
        spec.node + spec.nodeRate * d,
        spec.inclination + spec.inclinationRate * d,
        spec.perihelion + spec.perihelionRate * d,
        spec.axis,
        spec.eccentricity + spec.eccentricityRate * d,
        spec.meanAnomaly + spec.meanAnomalyRate * d,
      );
      final heliocentric = _heliocentric(orbit);
      final geo = <double>[
        heliocentric[0] - earth[0],
        heliocentric[1] - earth[1],
        heliocentric[2] - earth[2],
      ];
      final eq = _eclipticToEquatorial(
        geo[0], geo[1], geo[2], obliquity,
      );
      bodies.add(_horizontalBody(
        id: spec.id,
        nameAr: spec.nameAr,
        nameEn: spec.nameEn,
        kind: CelestialKind.planet,
        equatorial: eq,
        magnitude: spec.magnitude,
        color: spec.color,
        latitude: latitude,
        longitude: longitude,
        jd: jd,
        note: 'إحداثيات تقريبية من عناصر مدارية تحليلية؛ ليست أفيميرس احترافياً.',
      ));
    }

    final stars = <_StarSpec>[
      _StarSpec('sirius', 'الشعرى اليمانية', 'Sirius', 6 + 45.0 / 60 + 8.9 / 3600, -16.7161, -1.46, 0xFFEAF4FF,
          'وَأَنَّهُ هُوَ رَبُّ الشِّعْرَىٰ', 'النجم: 49',
          'سورة النجم، الآية 49. الآية تذكر الشعرى، ولا تقدم إحداثيات رصدية لها.'),
      _StarSpec('polaris', 'النجم القطبي', 'Polaris', 2 + 31.0 / 60 + 49.1 / 3600, 89.2641, 1.98, 0xFFDDEBFF, null, null, 'نجم قريب من القطب الشمالي السماوي.'),
      _StarSpec('vega', 'النسر الواقع', 'Vega', 18 + 36.0 / 60 + 56.3 / 3600, 38.7837, 0.03, 0xFFE5F0FF, null, null, 'نجم ساطع في كوكبة القيثارة.'),
      _StarSpec('arcturus', 'السماك الرامح', 'Arcturus', 14 + 15.0 / 60 + 39.7 / 3600, 19.1825, -0.05, 0xFFFFD8B2, null, null, 'نجم ساطع في كوكبة العواء.'),
      _StarSpec('capella', 'العيوق', 'Capella', 5 + 16.0 / 60 + 41.4 / 3600, 45.9980, 0.08, 0xFFFFE5C4, null, null, 'نجم ساطع في كوكبة ممسك الأعنة.'),
      _StarSpec('procyon', 'الشعرى الشامية', 'Procyon', 7 + 39.0 / 60 + 18.1 / 3600, 5.2250, 0.34, 0xFFEAF4FF, null, null, 'نجم ساطع في كوكبة الكلب الأصغر.'),
      _StarSpec('betelgeuse', 'منكب الجوزاء', 'Betelgeuse', 5 + 55.0 / 60 + 10.3 / 3600, 7.4071, 0.50, 0xFFFFB28A, null, null, 'نجم أحمر عملاق في كوكبة الجبار.'),
      _StarSpec('rigel', 'رجل الجبار', 'Rigel', 5 + 14.0 / 60 + 32.3 / 3600, -8.2056, 0.13, 0xFFBFDFFF, null, null, 'نجم أزرق فائق العملاق في كوكبة الجبار.'),
      _StarSpec('bellatrix', 'منطقة الجبار', 'Bellatrix', 5 + 25.0 / 60 + 7.9 / 3600, 6.3497, 1.64, 0xFFD9E8FF, null, null, 'نجم في كتف كوكبة الجبار.'),
      _StarSpec('saiph', 'سيف الجبار', 'Saiph', 5 + 47.0 / 60 + 45.4 / 3600, -9.6696, 2.06, 0xFFD5E5FF, null, null, 'نجم في قدم كوكبة الجبار.'),
      _StarSpec('aldebaran', 'الدبران', 'Aldebaran', 4 + 35.0 / 60 + 55.2 / 3600, 16.5093, 0.85, 0xFFFFC18A, null, null, 'نجم برتقالي في كوكبة الثور.'),
      _StarSpec('spica', 'السماك الأعزل', 'Spica', 13 + 25.0 / 60 + 11.6 / 3600, -11.1614, 0.97, 0xFFDDEBFF, null, null, 'نجم ساطع في كوكبة العذراء.'),
      _StarSpec('antares', 'قلب العقرب', 'Antares', 16 + 29.0 / 60 + 24.5 / 3600, -26.4319, 1.06, 0xFFFFA27E, null, null, 'نجم أحمر عملاق في كوكبة العقرب.'),
    ];

    for (final star in stars) {
      final ra = star.rightAscensionHours * 15;
      final dec = star.declination;
      final eq = _Equatorial(ra, dec);
      bodies.add(_horizontalBody(
        id: star.id,
        nameAr: star.nameAr,
        nameEn: star.nameEn,
        kind: CelestialKind.star,
        equatorial: eq,
        magnitude: star.magnitude,
        color: star.color,
        latitude: latitude,
        longitude: longitude,
        jd: jd,
        verse: star.verse,
        reference: star.reference,
        note: star.note,
      ));
    }

    return List<CelestialBody>.unmodifiable(bodies);
  }

  static CelestialBody _horizontalBody({
    required String id,
    required String nameAr,
    required String nameEn,
    required CelestialKind kind,
    required _Equatorial equatorial,
    required double magnitude,
    required int color,
    required double latitude,
    required double longitude,
    required double jd,
    String? verse,
    String? reference,
    required String note,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = _normalize(280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0);
    final lst = _normalize(gmst + longitude);
    final hourAngle = _signedAngle(lst - equatorial.ra) * _rad;
    final lat = latitude * _rad;
    final dec = equatorial.dec * _rad;
    final sinAlt = math.sin(lat) * math.sin(dec) +
        math.cos(lat) * math.cos(dec) * math.cos(hourAngle);
    final altitude = math.asin(sinAlt.clamp(-1.0, 1.0).toDouble()) * _deg;
    final azimuth = _normalize(math.atan2(
          -math.sin(hourAngle),
          math.tan(dec) * math.cos(lat) -
              math.sin(lat) * math.cos(hourAngle),
        ) *
        _deg);
    return CelestialBody(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      kind: kind,
      azimuth: azimuth,
      altitude: altitude,
      magnitude: magnitude,
      colorValue: color,
      verse: verse,
      reference: reference,
      note: note,
    );
  }

  static _Equatorial _moonEquatorial(double d, double obliquity) {
    final node = (125.1228 - 0.0529538083 * d) * _rad;
    const inclination = 5.1454 * _rad;
    final perihelion = (318.0634 + 0.1643573223 * d) * _rad;
    const eccentricity = 0.0549;
    final meanAnomaly = _normalize(115.3654 + 13.0649929509 * d) * _rad;
    final eccentricAnomaly = _solveEccentricAnomaly(meanAnomaly, eccentricity);
    final xv = 60.2666 * (math.cos(eccentricAnomaly) - eccentricity);
    final yv = 60.2666 * math.sqrt(1 - eccentricity * eccentricity) *
        math.sin(eccentricAnomaly);
    final trueAnomaly = math.atan2(yv, xv);
    final radius = math.sqrt(xv * xv + yv * yv);
    final argument = trueAnomaly + perihelion;
    final x = radius *
        (math.cos(node) * math.cos(argument) -
            math.sin(node) * math.sin(argument) * math.cos(inclination));
    final y = radius *
        (math.sin(node) * math.cos(argument) +
            math.cos(node) * math.sin(argument) * math.cos(inclination));
    final z = radius * math.sin(argument) * math.sin(inclination);

    var longitude = math.atan2(y, x) * _deg;
    var latitude = math.atan2(z, math.sqrt(x * x + y * y)) * _deg;

    final sunMean = _normalize(356.0470 + 0.9856002585 * d) * _rad;
    final moonMeanLongitude = _normalize(
      218.316 + 13.176396 * d,
    ) * _rad;
    final elongation = (moonMeanLongitude -
            (280.460 + 0.9856474 * d) * _rad);
    final argumentLatitude = (moonMeanLongitude - node);
    final mm = meanAnomaly;
    final ms = sunMean;
    final dd = elongation;
    final ff = argumentLatitude;

    longitude +=
        -1.274 * math.sin(mm - 2 * dd) +
        0.658 * math.sin(2 * dd) -
        0.186 * math.sin(ms) -
        0.059 * math.sin(2 * mm - 2 * dd) -
        0.057 * math.sin(mm - 2 * dd + ms) +
        0.053 * math.sin(mm + 2 * dd) +
        0.046 * math.sin(2 * dd - ms) +
        0.041 * math.sin(mm - ms) -
        0.035 * math.sin(dd) -
        0.031 * math.sin(mm + ms) -
        0.015 * math.sin(2 * ff - 2 * dd) +
        0.011 * math.sin(mm - 4 * dd);
    latitude +=
        -0.173 * math.sin(ff - 2 * dd) -
        0.055 * math.sin(mm - ff - 2 * dd) -
        0.046 * math.sin(mm + ff - 2 * dd) +
        0.033 * math.sin(ff + 2 * dd) +
        0.017 * math.sin(2 * mm + ff);

    final lon = longitude * _rad;
    final lat = latitude * _rad;
    final xe = math.cos(lon) * math.cos(lat);
    final ye = math.sin(lon) * math.cos(lat);
    final ze = math.sin(lat);
    return _eclipticToEquatorial(xe, ye, ze, obliquity);
  }

  static List<double> _heliocentric(_Orbit orbit) {
    final n = orbit.node * _rad;
    final i = orbit.inclination * _rad;
    final w = orbit.perihelion * _rad;
    final m = _normalize(orbit.meanAnomaly) * _rad;
    final e = _solveEccentricAnomaly(m, orbit.eccentricity);
    final xv = orbit.axis * (math.cos(e) - orbit.eccentricity);
    final yv = orbit.axis *
        math.sqrt(1 - orbit.eccentricity * orbit.eccentricity) *
        math.sin(e);
    final v = math.atan2(yv, xv);
    final r = math.sqrt(xv * xv + yv * yv);
    final u = v + w;
    return <double>[
      r * (math.cos(n) * math.cos(u) -
          math.sin(n) * math.sin(u) * math.cos(i)),
      r * (math.sin(n) * math.cos(u) +
          math.cos(n) * math.sin(u) * math.cos(i)),
      r * math.sin(u) * math.sin(i),
    ];
  }

  static _Equatorial _eclipticToEquatorial(
    double x,
    double y,
    double z,
    double obliquity,
  ) {
    final ye = y * math.cos(obliquity) - z * math.sin(obliquity);
    final ze = y * math.sin(obliquity) + z * math.cos(obliquity);
    final ra = _normalize(math.atan2(ye, x) * _deg);
    final dec = math.atan2(ze, math.sqrt(x * x + ye * ye)) * _deg;
    return _Equatorial(ra, dec);
  }

  static double _solveEccentricAnomaly(double mean, double eccentricity) {
    var e = mean + eccentricity * math.sin(mean) *
        (1 + eccentricity * math.cos(mean));
    for (var i = 0; i < 8; i++) {
      final delta = (e - eccentricity * math.sin(e) - mean) /
          (1 - eccentricity * math.cos(e));
      e -= delta;
      if (delta.abs() < 1e-10) break;
    }
    return e;
  }

  static double _normalize(double degrees) =>
      ((degrees % 360) + 360) % 360;

  static double _signedAngle(double degrees) {
    final value = _normalize(degrees);
    return value > 180 ? value - 360 : value;
  }
}

class _Equatorial {
  final double ra;
  final double dec;
  const _Equatorial(this.ra, this.dec);
}

class _Orbit {
  final double node;
  final double inclination;
  final double perihelion;
  final double axis;
  final double eccentricity;
  final double meanAnomaly;
  const _Orbit(this.node, this.inclination, this.perihelion, this.axis,
      this.eccentricity, this.meanAnomaly);
}

class _PlanetSpec {
  final String id;
  final String nameAr;
  final String nameEn;
  final double node;
  final double inclination;
  final double perihelion;
  final double axis;
  final double eccentricity;
  final double meanAnomaly;
  final double nodeRate;
  final double inclinationRate;
  final double perihelionRate;
  final double eccentricityRate;
  final double meanAnomalyRate;
  final int color;
  final double magnitude;

  const _PlanetSpec(
    this.id,
    this.nameAr,
    this.nameEn,
    this.node,
    this.inclination,
    this.perihelion,
    this.axis,
    this.eccentricity,
    this.meanAnomaly,
    this.nodeRate,
    this.inclinationRate,
    this.perihelionRate,
    this.eccentricityRate,
    this.meanAnomalyRate,
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
