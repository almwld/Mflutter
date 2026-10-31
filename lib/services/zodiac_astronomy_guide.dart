/// Clear epistemic separation for zodiac-related screens.
class ZodiacAstronomyGuide {
  ZodiacAstronomyGuide._();

  static const String astronomyTitle = 'علم الفلك';
  static const String astrologyTitle = 'التنجيم';
  static const String astronomyExplanation =
      'علم الفلك علم طبيعي يدرس الأجرام والظواهر الكونية باستخدام الرصد والرياضيات والفيزياء. '
      'يمكن حساب إحداثيات الشمس والأجرام ضمن نموذج محدد مع بيان دقته وحدوده.';
  static const String astrologyExplanation =
      'التنجيم منظومة معتقدات تربط مواقع الأجرام بسمات الأشخاص أو أحداث حياتهم. '
      'هذه الادعاءات التنبؤية ليست مثبتة علميًا بوصفها وسيلة موثوقة للتنبؤ بالشخصية أو المستقبل.';
  static const String zodiacConventionNote =
      'تواريخ الأبراج الشائعة تعتمد تقسيمًا استوائيًا اصطلاحيًا، ولا تمثل حدود الكوكبات الفلكية المرصودة. '
      'تختلف النتائج باختلاف النظام المستخدم والمنطقة الزمنية وموقع الشمس الفعلي.';
  static const String calculationLimit =
      'الحسابات الشمسية المضمنة تقديرية تعليمية، وليست بديلًا عن تقويم فلكي عالي الدقة أو بيانات رصدية.';

  static const List<String> tropicalSignNames = <String>[
    'الحمل', 'الثور', 'الجوزاء', 'السرطان', 'الأسد', 'العذراء',
    'الميزان', 'العقرب', 'القوس', 'الجدي', 'الدلو', 'الحوت',
  ];

  /// Tropical zodiac sector derived from solar ecliptic longitude.
  /// This is a coordinate convention, not a scientific personality reading.
  static String tropicalSignFromLongitude(double longitudeDegrees) {
    if (!longitudeDegrees.isFinite) {
      throw ArgumentError.value(longitudeDegrees, 'longitudeDegrees');
    }
    final normalized = (longitudeDegrees % 360 + 360) % 360;
    return tropicalSignNames[(normalized / 30).floor()];
  }
}
