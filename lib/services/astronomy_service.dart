import 'dart:math' as math;

import 'package:astronomia/apparent.dart' as apparent;
import 'package:astronomia/coord.dart' as coord;
import 'package:astronomia/globe.dart' as globe;
import 'package:astronomia/moonposition.dart' as moon;
import 'package:astronomia/nutation.dart' as nut;
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

  // Distances are rounded reference values for bright catalog stars. Unknown
  // or variable-quality entries intentionally remain null rather than guessed.
  static const Map<String, double> _starDistancesLightYears = {
    'sirius': 8.6, 'polaris': 447, 'vega': 25.0, 'arcturus': 36.7,
    'capella': 42.9, 'procyon': 11.46, 'betelgeuse': 548, 'rigel': 860,
    'bellatrix': 250, 'saiph': 650, 'aldebaran': 65.2, 'spica': 250,
    'antares': 550, 'deneb': 2615, 'altair': 16.7, 'albireo': 430,
    'dubhe': 123, 'merak': 79.7, 'phecda': 83.2, 'megrez': 80.5,
    'alioth': 83.2, 'mizar': 78.2, 'alkaid': 103, 'schedar': 228,
    'caph': 54.7, 'gamma_cas': 550, 'ruchbah': 99, 'segin': 440,
    'castor': 51.6, 'pollux': 33.8, 'regulus': 79.3, 'denebola': 36.2,
    'algieba': 130, 'hamal': 65.9, 'almach': 350, 'mirach': 197,
    'alpheratz': 97, 'algol': 93.4, 'mirfak': 510, 'elnath': 134,
    'maia': 344, 'electra': 400, 'mimosa': 280, 'acrux': 320,
    'gacrux': 88.6, 'canopus': 310, 'adhara': 430, 'wezen': 1600,
    'aludra': 2000, 'fomalhaut': 25.1, 'achernar': 139, 'shaula': 570,
    'sargas': 270, 'kaus_australis': 145, 'rasalhague': 48.6,
    'alphecca': 75, 'muphrid': 37.2, 'alnair': 101, 'gienah': 154,
    'alnilam': 2000, 'mintaka': 1200, 'alnitak': 1260, 'sadr': 1800,
    'sheliak': 960, 'sulafat': 620, 'tarazed': 395, 'alshain': 45.9,
  };

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

    _StarSpec('alnilam', 'النظام', 'Alnilam', 5.603556, -1.2019, 1.69, 0xFFBFDFFF, null, null, 'النجم الأوسط في حزام الجبار.'),
    _StarSpec('mintaka', 'منطقة', 'Mintaka', 5.533444, -0.2991, 2.23, 0xFFBFDFFF, null, null, 'النجم الغربي في حزام الجبار.'),
    _StarSpec('alnitak', 'النطاق', 'Alnitak', 5.679306, -1.9426, 1.77, 0xFFBFDFFF, null, null, 'النجم الشرقي في حزام الجبار.'),
    _StarSpec('sadr', 'صدر الدجاجة', 'Sadr', 20.370472, 40.2567, 2.23, 0xFFFFE5C4, null, null, 'نجم في مركز صليب الشمال ضمن كوكبة الدجاجة.'),
    _StarSpec('sheliak', 'شلياق', 'Sheliak', 18.834667, 33.3627, 3.52, 0xFFEAF2FF, null, null, 'نجم متغير في كوكبة القيثارة.'),
    _StarSpec('sulafat', 'السلافات', 'Sulafat', 18.982389, 32.6896, 3.25, 0xFFEAF2FF, null, null, 'نجم في كوكبة القيثارة.'),
    _StarSpec('tarazed', 'الطائر', 'Tarazed', 19.770994, 10.6133, 2.72, 0xFFFFD6A0, null, null, 'نجم في كوكبة العقاب قرب النسر الطائر.'),
    _StarSpec('alshain', 'الشاهين', 'Alshain', 19.921028, 6.4068, 3.71, 0xFFFFE5C4, null, null, 'نجم في كوكبة العقاب.'),
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
    final earthPosition = _earth.position(jde);

    final sun = solar.apparentEquatorial(jde);
    bodies.add(_fromEquatorial(
      id: 'sun',
      nameAr: 'الشمس',
      nameEn: 'Sun',
      kind: CelestialKind.sun,
      ra: sun.ra,
      dec: sun.dec,
      magnitude: -26.7,
      distanceAu: earthPosition.range,
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
      distanceAu: moonDistanceAu,
      illuminatedFraction: _moonIllumination(sun.ra, sun.dec, moonGeocentric.ra, moonGeocentric.dec),
      phaseAngleDegrees: _moonPhaseAngle(sun.ra, sun.dec, moonGeocentric.ra, moonGeocentric.dec),
      phaseName: _moonPhaseName(sun.ra, moonGeocentric.ra, _moonIllumination(sun.ra, sun.dec, moonGeocentric.ra, moonGeocentric.dec)),
      color: 0xFFE4E9F5,
      latitudeRadians: latitudeRadians,
      localSiderealDegrees: localSiderealDegrees,
      verse: 'وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ',
      reference: 'يس: 39',
      note: 'موضع قمري محسوب بخوارزميات Meeus مع تصحيح اختلاف المنظر الطبوغرافي؛ الانكسار الجوي غير مطبق.',
    ));

    // Reuse the same Earth VSOP87 vector for all geocentric planet positions.
    for (final spec in _planets) {
      final equatorial = _planetEquatorial(spec.planet, earthPosition, jde);
      bodies.add(_fromEquatorial(
        id: spec.id,
        nameAr: spec.nameAr,
        nameEn: spec.nameEn,
        kind: CelestialKind.planet,
        ra: equatorial.ra,
        dec: equatorial.dec,
        magnitude: spec.magnitude,
        distanceAu: equatorial.distanceAu,
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
        distanceLightYears: _starDistancesLightYears[star.id],
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

  static ({double ra, double dec, double distanceAu}) _planetEquatorial(
    pp.Planet planet,
    ({double lon, double lat, double range}) earth,
    double jde,
  ) {
    final sinEarthLat = math.sin(earth.lat);
    final cosEarthLat = math.cos(earth.lat);
    final sinEarthLon = math.sin(earth.lon);
    final cosEarthLon = math.cos(earth.lon);

    ({double x, double y, double z}) geocentric(double lightDays) {
      final position = planet.position(jde - lightDays);
      final sinLat = math.sin(position.lat);
      final cosLat = math.cos(position.lat);
      final sinLon = math.sin(position.lon);
      final cosLon = math.cos(position.lon);
      return (
        x: position.range * cosLat * cosLon -
            earth.range * cosEarthLat * cosEarthLon,
        y: position.range * cosLat * sinLon -
            earth.range * cosEarthLat * sinEarthLon,
        z: position.range * sinLat - earth.range * sinEarthLat,
      );
    }

    final first = geocentric(0);
    final distance = math.sqrt(
      first.x * first.x + first.y * first.y + first.z * first.z,
    );
    // Meeus light-time in days for a distance expressed in astronomical units.
    final corrected = geocentric(0.0057755183 * distance);
    var longitude = math.atan2(corrected.y, corrected.x);
    var latitude = math.atan2(
      corrected.z,
      math.sqrt(corrected.x * corrected.x + corrected.y * corrected.y),
    );

    final aberration = apparent.eclipticAberration(longitude, latitude, jde);
    longitude += aberration.dLon;
    latitude += aberration.dLat;
    final fk5 = pp.toFK5(longitude, latitude, jde);
    longitude = fk5.lon;
    latitude = fk5.lat;

    final nutation = nut.nutation(jde);
    longitude += nutation.dPsi;
    final obliquity = nut.meanObliquity(jde) + nutation.dEps;
    final equatorial = coord.eclToEq(
      longitude,
      latitude,
      math.sin(obliquity),
      math.cos(obliquity),
    );
    final distanceAu = math.sqrt(
      corrected.x * corrected.x + corrected.y * corrected.y + corrected.z * corrected.z,
    );
    return (ra: equatorial.ra, dec: equatorial.dec, distanceAu: distanceAu);
  }

  static double _moonPhaseAngle(double sunRa, double sunDec, double moonRa, double moonDec) {
    final cosine = math.sin(sunDec) * math.sin(moonDec) +
        math.cos(sunDec) * math.cos(moonDec) * math.cos(sunRa - moonRa);
    final elongation = math.acos(cosine.clamp(-1.0, 1.0).toDouble()) * _deg;
    return 180 - elongation;
  }

  static double _moonIllumination(double sunRa, double sunDec, double moonRa, double moonDec) {
    final phaseAngle = _moonPhaseAngle(sunRa, sunDec, moonRa, moonDec) * _rad;
    return ((1 + math.cos(phaseAngle)) / 2).clamp(0.0, 1.0).toDouble();
  }

  static String _moonPhaseName(double sunRa, double moonRa, double illumination) {
    final waxing = _normalize((moonRa - sunRa) * _deg) < 180;
    if (illumination < 0.03) return 'محاق';
    if (illumination > 0.97) return 'بدر';
    if (illumination >= 0.45 && illumination <= 0.55) {
      return waxing ? 'التربيع الأول' : 'التربيع الأخير';
    }
    if (illumination < 0.5) return waxing ? 'هلال متزايد' : 'هلال متناقص';
    return waxing ? 'أحدب متزايد' : 'أحدب متناقص';
  }

  static CelestialBody _fromEquatorial({
    required String id,
    required String nameAr,
    required String nameEn,
    required CelestialKind kind,
    required double ra,
    required double dec,
    required double magnitude,
    double? distanceAu,
    double? distanceLightYears,
    double? illuminatedFraction,
    double? phaseAngleDegrees,
    String? phaseName,
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
      distanceAu: distanceAu,
      distanceLightYears: distanceLightYears,
      illuminatedFraction: illuminatedFraction,
      phaseAngleDegrees: phaseAngleDegrees,
      phaseName: phaseName,
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
