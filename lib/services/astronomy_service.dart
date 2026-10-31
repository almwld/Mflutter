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

    _StarSpec('deneb', 'ذنب الدجاجة', 'Deneb', 20.690532, 45.2803, 1.25, 0xFFEAF2FF, null, null, 'نجم ساطع في كوكبة الدجاجة.'),
    _StarSpec('altair', 'النسر الطائر', 'Altair', 19.846389, 8.8683, 0.77, 0xFFEAF2FF, null, null, 'النجم الرئيسي في كوكبة العقاب.'),
    _StarSpec('albireo', 'منقار الدجاجة', 'Albireo', 19.512028, 27.9597, 3.08, 0xFFFFD6A0, null, null, 'نجم مزدوج شهير في كوكبة الدجاجة.'),
    _StarSpec('dubhe', 'الدبة', 'Dubhe', 11.062130, 61.7508, 1.79, 0xFFFFE5C4, null, null, 'نجم في كوكبة الدب الأكبر.'),
    _StarSpec('merak', 'المراق', 'Merak', 11.030694, 56.3824, 2.37, 0xFFEAF2FF, null, null, 'نجم من نجوم الدب الأكبر والدليل إلى القطب تقريباً.'),
    _StarSpec('phecda', 'فخذ الدب', 'Phecda', 11.897167, 53.6948, 2.44, 0xFFEAF2FF, null, null, 'نجم في وعاء الدب الأكبر.'),
    _StarSpec('megrez', 'المغرز', 'Megrez', 12.257111, 57.0326, 3.31, 0xFFEAF2FF, null, null, 'نجم يصل وعاء الدب الأكبر بمقبضه.'),
    _StarSpec('alioth', 'عليوث', 'Alioth', 12.900472, 55.9598, 1.76, 0xFFEAF2FF, null, null, 'ألمع نجوم مجموعة بنات نعش الكبرى.'),
    _StarSpec('mizar', 'المئزر', 'Mizar', 13.398778, 54.9254, 2.23, 0xFFEAF2FF, null, null, 'نجم مزدوج بصري في مقبض الدب الأكبر.'),
    _StarSpec('alkaid', 'القائد', 'Alkaid', 13.792333, 49.3133, 1.86, 0xFFEAF2FF, null, null, 'طرف مقبض الدب الأكبر.'),
    _StarSpec('schedar', 'صدر ذات الكرسي', 'Schedar', 0.675111, 56.5373, 2.24, 0xFFFFE5C4, null, null, 'ألمع نجوم كوكبة ذات الكرسي.'),
    _StarSpec('caph', 'الكف', 'Caph', 0.152806, 59.1502, 2.27, 0xFFEAF2FF, null, null, 'نجم في كوكبة ذات الكرسي.'),
    _StarSpec('gamma_cas', 'غاما ذات الكرسي', 'Gamma Cassiopeiae', 0.945139, 60.7167, 2.47, 0xFFBFDFFF, null, null, 'نجم متغير في كوكبة ذات الكرسي.'),
    _StarSpec('ruchbah', 'روخبة', 'Ruchbah', 1.430278, 60.2353, 2.68, 0xFFEAF2FF, null, null, 'نجم في كوكبة ذات الكرسي.'),
    _StarSpec('segin', 'سيغن', 'Segin', 1.906583, 63.6701, 3.37, 0xFFEAF2FF, null, null, 'نجم في الطرف الشرقي لذات الكرسي.'),
    _StarSpec('castor', 'رأس التوأم المقدم', 'Castor', 7.576667, 31.8883, 1.58, 0xFFEAF2FF, null, null, 'نظام نجمي متعدد في كوكبة التوأمين.'),
    _StarSpec('pollux', 'رأس التوأم المؤخر', 'Pollux', 7.755278, 28.0262, 1.14, 0xFFFFD6A0, null, null, 'ألمع نجوم كوكبة التوأمين.'),
    _StarSpec('regulus', 'قلب الأسد', 'Regulus', 10.139528, 11.9672, 1.35, 0xFFEAF2FF, null, null, 'ألمع نجوم كوكبة الأسد.'),
    _StarSpec('denebola', 'ذنب الأسد', 'Denebola', 11.817667, 14.5721, 2.14, 0xFFEAF2FF, null, null, 'نجم في ذيل كوكبة الأسد.'),
    _StarSpec('algieba', 'الجبهة', 'Algieba', 10.332861, 19.8415, 2.08, 0xFFFFD6A0, null, null, 'نجم مزدوج في كوكبة الأسد.'),
    _StarSpec('hamal', 'حمل', 'Hamal', 2.119556, 23.4624, 2.00, 0xFFFFD6A0, null, null, 'ألمع نجوم كوكبة الحمل.'),
    _StarSpec('almach', 'العناق', 'Almach', 2.064972, 42.3297, 2.10, 0xFFFFD6A0, null, null, 'نجم مزدوج في كوكبة المرأة المسلسلة.'),
    _StarSpec('mirach', 'مراق', 'Mirach', 1.162194, 35.6206, 2.05, 0xFFFFC18A, null, null, 'نجم أحمر في كوكبة المرأة المسلسلة.'),
    _StarSpec('alpheratz', 'سرة الفرس', 'Alpheratz', 0.139806, 29.0904, 2.06, 0xFFEAF2FF, null, null, 'نجم مشترك حدودياً بين الفرس والمرأة المسلسلة.'),
    _StarSpec('algol', 'رأس الغول', 'Algol', 3.136147, 40.9556, 2.12, 0xFFEAF2FF, null, null, 'نجم ثنائي كسوفي متغير في كوكبة برشاوس.'),
    _StarSpec('mirfak', 'المرفق', 'Mirfak', 3.405389, 49.8612, 1.79, 0xFFFFE5C4, null, null, 'ألمع نجوم كوكبة برشاوس.'),
    _StarSpec('elnath', 'النطح', 'Elnath', 5.438194, 28.6075, 1.65, 0xFFEAF2FF, null, null, 'نجم عند طرف قرن الثور.'),
    _StarSpec('maia', 'مايا', 'Maia', 3.763778, 24.3678, 3.87, 0xFFEAF2FF, null, null, 'أحد نجوم الثريا في كوكبة الثور.'),
    _StarSpec('electra', 'إلكترا', 'Electra', 3.747944, 24.1133, 3.70, 0xFFEAF2FF, null, null, 'أحد نجوم الثريا.'),
    _StarSpec('mimosa', 'ميموزا', 'Mimosa', 12.795333, -59.6888, 1.25, 0xFFBFDFFF, null, null, 'نجم ساطع في كوكبة الصليب الجنوبي.'),
    _StarSpec('acrux', 'ألفا الصليب', 'Acrux', 12.443306, -63.0991, 0.76, 0xFFBFDFFF, null, null, 'ألمع نجوم كوكبة الصليب الجنوبي.'),
    _StarSpec('gacrux', 'غاما الصليب', 'Gacrux', 12.519444, -57.1132, 1.63, 0xFFFFB28A, null, null, 'نجم أحمر في أعلى الصليب الجنوبي.'),
    _StarSpec('canopus', 'سهيل', 'Canopus', 6.399194, -52.6957, -0.74, 0xFFEAF2FF, null, null, 'ثاني ألمع نجم في السماء الليلية.'),
    _StarSpec('adhara', 'العذارى', 'Adhara', 6.977097, -28.9721, 1.50, 0xFFBFDFFF, null, null, 'نجم ساطع في كوكبة الكلب الأكبر.'),
    _StarSpec('wezen', 'الوزن', 'Wezen', 7.139861, -26.3932, 1.83, 0xFFFFE5C4, null, null, 'نجم في كوكبة الكلب الأكبر.'),
    _StarSpec('aludra', 'العذرة', 'Aludra', 7.401583, -29.3031, 2.45, 0xFFBFDFFF, null, null, 'نجم أزرق فائق العملاق في الكلب الأكبر.'),
    _StarSpec('fomalhaut', 'فم الحوت', 'Fomalhaut', 22.960833, -29.6222, 1.16, 0xFFEAF2FF, null, null, 'ألمع نجوم كوكبة الحوت الجنوبي.'),
    _StarSpec('achernar', 'آخر النهر', 'Achernar', 1.628556, -57.2367, 0.46, 0xFFBFDFFF, null, null, 'نجم ساطع عند نهاية كوكبة النهر.'),
    _StarSpec('shaula', 'الشولة', 'Shaula', 17.560139, -37.1038, 1.62, 0xFFBFDFFF, null, null, 'نجم في ذيل كوكبة العقرب.'),
    _StarSpec('sargas', 'السُّرّة', 'Sargas', 17.621972, -42.9978, 1.86, 0xFFFFE5C4, null, null, 'نجم ساطع في كوكبة العقرب.'),
    _StarSpec('kaus_australis', 'القوس الجنوبي', 'Kaus Australis', 18.402889, -34.3846, 1.79, 0xFFEAF2FF, null, null, 'ألمع نجوم كوكبة القوس.'),
    _StarSpec('rasalhague', 'رأس الحواء', 'Rasalhague', 17.582222, 12.5600, 2.08, 0xFFEAF2FF, null, null, 'ألمع نجوم كوكبة الحواء.'),
    _StarSpec('alphecca', 'السماك الرامح الشمالي', 'Alphecca', 15.578139, 26.7147, 2.23, 0xFFEAF2FF, null, null, 'ألمع نجوم كوكبة الإكليل الشمالي.'),
    _StarSpec('muphrid', 'مفرد', 'Muphrid', 13.911417, 18.3977, 2.68, 0xFFFFE5C4, null, null, 'نجم قريب ظاهرياً من السماك الرامح.'),
    _StarSpec('alnair', 'النير', 'Alnair', 22.137222, -46.9609, 1.74, 0xFFBFDFFF, null, null, 'ألمع نجوم كوكبة الكركي.'),
    _StarSpec('gienah', 'جناح الغراب', 'Gienah', 12.263444, -17.5419, 2.59, 0xFFBFDFFF, null, null, 'نجم في كوكبة الغراب.'),
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
