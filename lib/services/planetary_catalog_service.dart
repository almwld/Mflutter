/// Approximate reference data for the eight Solar System planets.
/// Values are rounded reference values; they are not live ephemerides.
/// Sources: NASA Solar System Exploration planet fact sheets.
/// https://science.nasa.gov/solar-system/planets/
class PlanetaryBody {
  final String id;
  final String nameAr;
  final String nameEn;
  final String classification;
  final double meanDistanceAu;
  final double orbitalEccentricity;
  final double orbitalPeriodDays;
  final int meanDiameterKm;
  final String descriptionAr;

  const PlanetaryBody({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.classification,
    required this.meanDistanceAu,
    required this.orbitalEccentricity,
    required this.orbitalPeriodDays,
    required this.meanDiameterKm,
    required this.descriptionAr,
  });
}

class PlanetaryCatalogService {
  PlanetaryCatalogService._();

  static const String sourceName = 'NASA Solar System Exploration';
  static const String sourceUrl = 'https://science.nasa.gov/solar-system/planets/';

  static const List<PlanetaryBody> planets = <PlanetaryBody>[
    PlanetaryBody(id: 'mercury', nameAr: 'عطارد', nameEn: 'Mercury', classification: 'terrestrial', meanDistanceAu: 0.3871, orbitalEccentricity: 0.2056, orbitalPeriodDays: 87.969, meanDiameterKm: 4879, descriptionAr: 'أقرب الكواكب إلى الشمس، وله مدار ذو استطالة مرتفعة نسبيًا.'),
    PlanetaryBody(id: 'venus', nameAr: 'الزهرة', nameEn: 'Venus', classification: 'terrestrial', meanDistanceAu: 0.7233, orbitalEccentricity: 0.0068, orbitalPeriodDays: 224.701, meanDiameterKm: 12104, descriptionAr: 'كوكب صخري ذو غلاف جوي كثيف غني بثاني أكسيد الكربون.'),
    PlanetaryBody(id: 'earth', nameAr: 'الأرض', nameEn: 'Earth', classification: 'terrestrial', meanDistanceAu: 1.0, orbitalEccentricity: 0.0167, orbitalPeriodDays: 365.256, meanDiameterKm: 12742, descriptionAr: 'كوكب صخري معروف بوجود ماء سائل مستقر على سطحه وحياة مؤكدة.'),
    PlanetaryBody(id: 'mars', nameAr: 'المريخ', nameEn: 'Mars', classification: 'terrestrial', meanDistanceAu: 1.5237, orbitalEccentricity: 0.0934, orbitalPeriodDays: 686.980, meanDiameterKm: 6779, descriptionAr: 'كوكب صخري بارد نسبيًا، وتظهر على سطحه آثار جيولوجية لوجود ماء قديم.'),
    PlanetaryBody(id: 'jupiter', nameAr: 'المشتري', nameEn: 'Jupiter', classification: 'gas_giant', meanDistanceAu: 5.2028, orbitalEccentricity: 0.0489, orbitalPeriodDays: 4332.59, meanDiameterKm: 139820, descriptionAr: 'أكبر كواكب النظام الشمسي، ويتكون أساسًا من الهيدروجين والهيليوم.'),
    PlanetaryBody(id: 'saturn', nameAr: 'زحل', nameEn: 'Saturn', classification: 'gas_giant', meanDistanceAu: 9.5388, orbitalEccentricity: 0.0565, orbitalPeriodDays: 10759.22, meanDiameterKm: 116460, descriptionAr: 'عملاق غازي مشهور بنظام حلقاته الواسع المكوّن أساسًا من الجليد والصخور.'),
    PlanetaryBody(id: 'uranus', nameAr: 'أورانوس', nameEn: 'Uranus', classification: 'ice_giant', meanDistanceAu: 19.191, orbitalEccentricity: 0.0472, orbitalPeriodDays: 30688.5, meanDiameterKm: 50724, descriptionAr: 'عملاق جليدي يميل محور دورانه بشدة مقارنة بمعظم الكواكب.'),
    PlanetaryBody(id: 'neptune', nameAr: 'نبتون', nameEn: 'Neptune', classification: 'ice_giant', meanDistanceAu: 30.07, orbitalEccentricity: 0.0086, orbitalPeriodDays: 60182, meanDiameterKm: 49244, descriptionAr: 'أبعد كواكب النظام الشمسي الثمانية عن الشمس، وتتميز أجواؤه برياح شديدة.'),
  ];

  static PlanetaryBody? byId(String id) {
    final normalized = id.trim().toLowerCase();
    for (final planet in planets) {
      if (planet.id == normalized) return planet;
    }
    return null;
  }

  static List<PlanetaryBody> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return planets;
    return planets.where((planet) =>
      planet.nameAr.contains(normalized) ||
      planet.nameEn.toLowerCase().contains(normalized) ||
      planet.id.contains(normalized)
    ).toList(growable: false);
  }
}
