import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/occult_models.dart';

/// Local-first knowledge loader. No network access is required at runtime.
/// Entries bundled below are clearly marked as starter/reference summaries;
/// an optional JSON asset can add structured records without changing the UI.
class OccultDataService {
  OccultDataService._();

  static const String assetPath = 'assets/all_knowledge.json';

  static const List<OccultEntry> _starterEntries = <OccultEntry>[
    OccultEntry(
      id: 'tarot-fool',
      name: 'المهرج — The Fool',
      category: 'tarot',
      description: 'مدخل تعريفي لرمز البداية والتجربة الجديدة في بعض مدارس التاروت.',
      properties: <String, dynamic>{'number': 0, 'element': 'يختلف حسب المدرسة'},
      source: 'Starter reference — not a prediction',
    ),
    OccultEntry(
      id: 'rune-fehu',
      name: 'فيهو — Fehu',
      category: 'runes',
      description: 'رمز من الأبجدية الرونية ارتبط تاريخياً بالماشية والثروة في المصادر الجرمانية القديمة.',
      properties: <String, dynamic>{'system': 'Elder Futhark'},
      source: 'Historical / cultural reference',
    ),
    OccultEntry(
      id: 'crystal-amethyst',
      name: 'الجمشت — Amethyst',
      category: 'crystals',
      description: 'نوع من الكوارتز البنفسجي؛ أما الادعاءات العلاجية أو الروحية المنسوبة إليه فليست حقائق علمية مثبتة.',
      properties: <String, dynamic>{'mineral': 'Quartz', 'Mohs hardness': 7},
      source: 'Mineralogical reference',
    ),
    OccultEntry(
      id: 'emerald-tablet',
      name: 'لوح الزمرد — Emerald Tablet',
      category: 'hermeticism',
      description: 'نص قصير مشهور في تاريخ الهرمسية والخيمياء، وصل عبر تقاليد مخطوطية متعددة.',
      properties: <String, dynamic>{'field': 'History of esotericism'},
      source: 'Historical text reference',
    ),
    OccultEntry(
      id: 'astronomy-au',
      name: 'الوحدة الفلكية',
      category: 'astronomy',
      description: 'وحدة طول تساوي تقريبًا متوسط المسافة بين الأرض والشمس، وتستخدم لوصف المسافات داخل النظام الشمسي.',
      properties: <String, dynamic>{'symbol': 'AU', 'approximateKm': 149600000},
      source: 'Astronomical measurement reference',
    ),
    OccultEntry(
      id: 'astronomy-kepler',
      name: 'قوانين كبلر لحركة الكواكب',
      category: 'astronomy',
      description: 'تصف قوانين كبلر المدارات الإهليلجية ومساحات الحركة وعلاقة الفترة المدارية بحجم المدار؛ وهي وصف رياضي للحركة وليس تفسيرًا تنجيميًا.',
      properties: <String, dynamic>{'periodRule': 'P² ∝ a³', 'model': 'Two-body approximation'},
      source: 'Classical celestial mechanics',
    ),
    OccultEntry(
      id: 'planet-earth',
      name: 'الأرض',
      category: 'planets',
      description: 'كوكب صخري ثالث من الشمس، ومتوسط بعده المداري يقارب وحدة فلكية واحدة. قيم المدار والمسافات هنا متوسطات وليست مواقع آنية.',
      properties: <String, dynamic>{'type': 'Terrestrial planet', 'orbitalPeriodDays': 365.256, 'meanDistanceAU': 1.0},
      source: 'Solar System reference data',
    ),
    OccultEntry(
      id: 'planet-mars',
      name: 'المريخ',
      category: 'planets',
      description: 'كوكب صخري رابع من الشمس، ويبلغ متوسط فترته المدارية نحو 687 يومًا أرضيًا.',
      properties: <String, dynamic>{'type': 'Terrestrial planet', 'orbitalPeriodDays': 687, 'meanDistanceAU': 1.524},
      source: 'Solar System reference data',
    ),
    OccultEntry(
      id: 'zodiac-history',
      name: 'الأبراج الاثنا عشر في التاريخ',
      category: 'zodiac',
      description: 'تقسيمات رمزية استُخدمت في تقاليد التنجيم، ومنها النظام الاستوائي الغربي. هذا تصنيف تاريخي ثقافي؛ لا تدعم الأدلة العلمية استخدام الأبراج للتنبؤ بالشخصية أو الأحداث.',
      properties: <String, dynamic>{'system': 'Western tropical zodiac', 'count': 12},
      source: 'History of astrology; not a scientific prediction method',
    ),
    OccultEntry(
      id: 'lunar-phases',
      name: 'أطوار القمر',
      category: 'astronomy',
      description: 'تتغير الأطوار المرئية بحسب هندسة مواضع الشمس والأرض والقمر؛ ومتوسط الشهر الاقتراني نحو 29.53 يومًا.',
      properties: <String, dynamic>{'synodicMonthDays': 29.530588853, 'phases': 8},
      source: 'Lunar cycle reference',
    ),
    OccultEntry(
      id: 'astronomy-seasons',
      name: 'الفصول الأربعة',
      category: 'astronomy',
      description: 'تنشأ الفصول أساسًا من ميل محور الأرض أثناء دورانها حول الشمس، لا من كون الأرض أقرب إلى الشمس في الصيف بكل مكان.',
      properties: <String, dynamic>{'axialTiltDegrees': 23.44, 'cause': 'Earth axial tilt'},
      source: 'Earth science reference',
    ),
    OccultEntry(
      id: 'astronomy-eclipses',
      name: 'كسوف الشمس وخسوف القمر',
      category: 'astronomy',
      description: 'يحدث الكسوف الشمسي عندما يمر القمر بين الأرض والشمس، ويحدث الخسوف القمري عندما يدخل القمر في ظل الأرض. لا يقع الحدثان كل شهر بسبب ميل مدار القمر.',
      properties: <String, dynamic>{'solarEclipseAlignment': 'Sun–Moon–Earth', 'lunarEclipseAlignment': 'Sun–Earth–Moon'},
      source: 'Orbital geometry reference',
    ),
    OccultEntry(
      id: 'astronomy-exoplanets',
      name: 'الكواكب خارج النظام الشمسي',
      category: 'astronomy',
      description: 'الكوكب الخارجي يدور حول نجم غير الشمس. تُكتشف كواكب كثيرة بطرائق مثل العبور الذي يقيس انخفاض ضوء النجم أو السرعة الشعاعية التي تقيس حركة النجم.',
      properties: <String, dynamic>{'methods': 'Transit; radial velocity', 'location': 'Other star systems'},
      source: 'Exoplanet detection overview',
    ),
    OccultEntry(
      id: 'astronomy-lightyear',
      name: 'السنة الضوئية',
      category: 'astronomy',
      description: 'وحدة مسافة وليست وحدة زمن: المسافة التي يقطعها الضوء في الفراغ خلال سنة يوليانية، وتساوي نحو 9.46 تريليون كيلومتر.',
      properties: <String, dynamic>{'approximateKilometers': 9460000000000, 'unitType': 'distance'},
      source: 'Astronomical distance reference',
    ),
    OccultEntry(
      id: 'astronomy-spectroscopy',
      name: 'التحليل الطيفي للنجوم',
      category: 'astronomy',
      description: 'يساعد تحليل الضوء إلى أطواله الموجية على استنتاج تركيب النجوم ودرجة حرارتها وحركتها؛ فالخطوط الطيفية ترتبط بانتقالات ذرية وجزيئية.',
      properties: <String, dynamic>{'observedSignal': 'Electromagnetic spectrum', 'uses': 'Composition, temperature, radial motion'},
      source: 'Observational astronomy reference',
    ),
    OccultEntry(
      id: 'planet-pluto',
      name: 'بلوتو والكواكب القزمة',
      category: 'planets',
      description: 'بلوتو كوكب قزم في حزام كايبر. يدور حول الشمس وله أقمار، لكنه لم يحقق شرط تنظيف جواره المداري وفق تعريف الاتحاد الفلكي الدولي للكوكب.',
      properties: <String, dynamic>{'classification': 'Dwarf planet', 'region': 'Kuiper belt'},
      source: 'IAU planetary classification summary',
    ),
    OccultEntry(
      id: 'planet-venus',
      name: 'الزهرة والغلاف الجوي',
      category: 'planets',
      description: 'يمتلك الزهرة غلافًا جويًا كثيفًا يغلب عليه ثاني أكسيد الكربون، ويسبب الاحتباس الحراري الشديد ارتفاع حرارة سطحه إلى مستويات أعلى من عطارد.',
      properties: <String, dynamic>{'atmosphere': 'Mostly carbon dioxide', 'surfaceTemperatureC': 465},
      source: 'Planetary science reference',
    ),
    OccultEntry(
      id: 'planet-jupiter-moons',
      name: 'أقمار المشتري الكبيرة',
      category: 'planets',
      description: 'آيو وأوروبا وغانيميد وكاليستو هي الأقمار الجليلية الأربعة، وقد رصدها غاليليو عام 1610. تختلف أسطحها ونشاطها الجيولوجي وبيئاتها.',
      properties: <String, dynamic>{'moons': 'Io, Europa, Ganymede, Callisto', 'discoveryYear': 1610},
      source: 'Historical and planetary science reference',
    ),
    OccultEntry(
      id: 'zodiac-tropical-sidereal',
      name: 'الأبراج الاستوائية والنجمية',
      category: 'zodiac',
      description: 'يستخدم النظام الاستوائي نقاط الاعتدال والانقلاب لتقسيم دائرة البروج، بينما يرتبط النظام النجمي بمواقع مرجعية للنجوم. تختلف الحدود بين النظامين، ولا يثبت أي منهما صلاحية التنبؤات التنجيمية.',
      properties: <String, dynamic>{'systems': 'Tropical; sidereal', 'field': 'History of astrology'},
      source: 'Historical astronomy and astrology overview',
    ),
  ];

  static Future<List<OccultEntry>> fetchAllEntries() async {
    final byId = <String, OccultEntry>{
      for (final entry in _starterEntries) entry.id: entry,
    };

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final records = _extractRecords(decoded);
      for (var i = 0; i < records.length; i++) {
        try {
          final entry = OccultEntry.fromJson(records[i]);
          if (entry.name.trim().isEmpty || entry.description.trim().isEmpty) {
            continue;
          }
          final id = entry.id.trim().isEmpty
              ? 'asset-entry-$i'
              : entry.id.trim();
          byId[id] = OccultEntry(
            id: id,
            name: entry.name,
            category: entry.category,
            description: entry.description,
            properties: entry.properties,
            abjadValue: entry.abjadValue,
            source: entry.source ?? 'assets/all_knowledge.json',
          );
        } catch (_) {
          // Skip one malformed record without discarding other valid records.
          continue;
        }
      }
    } catch (_) {
      // Keep bundled starter entries when the optional asset cannot be read.
    }

    final result = byId.values.toList()
      ..sort((a, b) => a.category.compareTo(b.category));
    return result;
  }

  static List<Map<String, dynamic>> _extractRecords(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
    if (decoded is Map) {
      for (final key in const ['entries', 'items', 'records', 'knowledge', 'data']) {
        final value = decoded[key];
        if (value is List) {
          return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
        }
      }
      // Treat a single record as a one-item collection.
      if (decoded.containsKey('name') || decoded.containsKey('title')) {
        return <Map<String, dynamic>>[Map<String, dynamic>.from(decoded)];
      }
    }
    return const <Map<String, dynamic>>[];
  }

  static Future<List<OccultEntry>> fetchByCategory(String category) async {
    final all = await fetchAllEntries();
    if (category == 'all') return all;
    return all.where((entry) => entry.category == category).toList();
  }
}