/// =============================================================================
/// ScienceConstants - ثوابت العلوم
/// =============================================================================

class ScienceConstants {
  ScienceConstants._();

  /// العلوم الأساسية (42 علماً)
  static const List<ScienceInfo> sciences = [
    // علم الحروف
    ScienceInfo(id: 1, name: 'علم الحروف', nameEn: 'Science of Letters', icon: 'abc', count: 28, description: 'دراسة أسرار الحروف العربية وتأثيرها'),
    ScienceInfo(id: 2, name: 'علم الأعداد', nameEn: 'Science of Numbers', icon: 'numbers', count: 10, description: 'دراسة أسرار الأرقام ومعانيها'),
    ScienceInfo(id: 3, name: 'علم العناصر', nameEn: 'Science of Elements', icon: 'science', count: 5, description: 'دراسة العناصر الأربعة والروح'),
    ScienceInfo(id: 4, name: 'علم الكواكب', nameEn: 'Science of Planets', icon: 'public', count: 7, description: 'دراسة تأثير الكواكب السبعة'),
    ScienceInfo(id: 5, name: 'علم الأبراج', nameEn: 'Science of Zodiac', icon: 'star', count: 12, description: 'دراسة الأبراج الإثني عشر'),
    ScienceInfo(id: 6, name: 'علم الأسماء', nameEn: 'Science of Names', icon: 'badge', count: 99, description: 'دراسة الأسماء الحسنى'),

    // علوم القرآن
    ScienceInfo(id: 7, name: 'علم القراءات', nameEn: 'Science of Readings', icon: 'menu_book', count: 7, description: 'علم القراءات العشر'),
    ScienceInfo(id: 8, name: 'علم التجويد', nameEn: 'Science of Tajweed', icon: 'record_voice_over', count: 15, description: 'أحكام التجويد'),
    ScienceInfo(id: 9, name: 'علم التفسير', nameEn: 'Science of Tafsir', icon: 'library_books', count: 40, description: 'تفسير القرآن الكريم'),
    ScienceInfo(id: 10, name: 'علم أسباب النزول', nameEn: 'Science of Revelation', icon: 'history_edu', count: 200, description: 'أسباب نزول الآيات'),

    // علوم الحديث
    ScienceInfo(id: 11, name: 'علم مصطلح الحديث', nameEn: 'Hadith Sciences', icon: 'auto_stories', count: 12, description: 'مصطلح الحديث الشريف'),
    ScienceInfo(id: 12, name: 'علم الجرح والتعديل', nameEn: 'Science of Validation', icon: 'verified', count: 100, description: 'جرح وتعديل الرواة'),

    // علوم الفقه
    ScienceInfo(id: 13, name: 'علم أصول الفقه', nameEn: 'Usul al-Fiqh', icon: 'balance', count: 8, description: 'أصول الفقه الإسلامي'),
    ScienceInfo(id: 14, name: 'علم الفقه المقارن', nameEn: 'Comparative Fiqh', icon: 'compare_arrows', count: 4, description: 'الفقه المقارن'),

    // علوم اللغة
    ScienceInfo(id: 15, name: 'علم النحو', nameEn: 'Arabic Grammar', icon: 'account_tree', count: 20, description: 'قواعد النحو العربي'),
    ScienceInfo(id: 16, name: 'علم الصرف', nameEn: 'Arabic Morphology', icon: 'settings_system_daydream', count: 15, description: 'قواعد الصرف العربي'),
    ScienceInfo(id: 17, name: 'علم البلاغة', nameEn: 'Rhetoric', icon: 'campaign', count: 3, description: 'البلاغة العربية'),
    ScienceInfo(id: 18, name: 'علم المعاني', nameEn: 'Semantics', icon: 'text_fields', count: 10, description: 'علم المعاني'),

    // علوم روحانية
    ScienceInfo(id: 19, name: 'علم الأسرار', nameEn: 'Science of Secrets', icon: 'visibility', count: 7, description: 'أسرار العلوم الربانية'),
    ScienceInfo(id: 20, name: 'علم الأوفاق', nameEn: 'Science of Squares', icon: 'grid_on', count: 100, description: 'بناء الأوفاق'),

    // علوم طبيعية
    ScienceInfo(id: 21, name: 'علم الفلك', nameEn: 'Astronomy', icon: 'nights_stay', count: 12, description: 'علم الفلك'),
    ScienceInfo(id: 22, name: 'علم الطبيعة', nameEn: 'Natural Sciences', icon: 'eco', count: 50, description: 'علوم الطبيعة'),

    // علوم رياضية
    ScienceInfo(id: 23, name: 'علم الحساب', nameEn: 'Arithmetic', icon: 'calculate', count: 10, description: 'علم الحساب'),
    ScienceInfo(id: 24, name: 'علم الهندسة', nameEn: 'Geometry', icon: 'architecture', count: 20, description: 'علم الهندسة'),

    // علوم متنوعة
    ScienceInfo(id: 25, name: 'علم الخط', nameEn: 'Calligraphy', icon: 'edit', count: 20, description: 'فن الخط العربي'),
    ScienceInfo(id: 26, name: 'علم الموسيقى', nameEn: 'Music', icon: 'music_note', count: 7, description: 'علم الموسيقى'),

    // المزيد من العلوم
    ScienceInfo(id: 27, name: 'علم الكيمياء', nameEn: 'Chemistry', icon: 'science', count: 100, description: 'علم الكيمياء'),
    ScienceInfo(id: 28, name: 'علم البصريات', nameEn: 'Optics', icon: 'visibility', count: 10, description: 'علم البصريات'),
    ScienceInfo(id: 29, name: 'علم الميكانيكا', nameEn: 'Mechanics', icon: 'settings', count: 20, description: 'علم الميكانيكا'),
    ScienceInfo(id: 30, name: 'علم الحرارة', nameEn: 'Thermodynamics', icon: 'thermostat', count: 10, description: 'علم الحرارة'),

    // علوم شرعية
    ScienceInfo(id: 31, name: 'علم أركان الإسلام', nameEn: 'Pillars of Islam', icon: 'mosque', count: 5, description: 'أركان الإسلام'),
    ScienceInfo(id: 32, name: 'علم أركان الإيمان', nameEn: 'Pillars of Faith', icon: 'faith', count: 6, description: 'أركان الإيمان'),
    ScienceInfo(id: 33, name: 'علم السيرة', nameEn: 'Prophet Biography', icon: 'person', count: 50, description: 'سيرة النبي'),

    // علوم متقدمة
    ScienceInfo(id: 34, name: 'علم الروحانيات', nameEn: 'Spiritual Sciences', icon: 'auto_awesome', count: 42, description: 'علوم الروحانيات'),
    ScienceInfo(id: 35, name: 'علم التعويذات', nameEn: 'Incantations', icon: 'shield', count: 30, description: 'علم التعويذات'),

    // علوم الطاقة
    ScienceInfo(id: 36, name: 'علم الطاقة', nameEn: 'Energy Science', icon: 'bolt', count: 7, description: 'علوم الطاقة'),
    ScienceInfo(id: 37, name: 'علم الأبعاد', nameEn: 'Dimensions', icon: '3d_rotation', count: 4, description: 'علوم الأبعاد'),

    // علوم مستقبلية
    ScienceInfo(id: 38, name: 'علم الذكاء الاصطناعي', nameEn: 'AI', icon: 'psychology', count: 100, description: 'علوم الذكاء الاصطناعي'),
    ScienceInfo(id: 39, name: 'علم البيانات', nameEn: 'Data Science', icon: 'storage', count: 50, description: 'علوم البيانات'),

    // علوم إلهية
    ScienceInfo(id: 40, name: 'علم التوحيد', nameEn: 'Monotheism', icon: 'supervisor_account', count: 20, description: 'علم التوحيد'),
    ScienceInfo(id: 41, name: 'علم السمع والبصر', nameEn: 'Senses', icon: 'visibility', count: 5, description: 'السمع والبصر'),
    ScienceInfo(id: 42, name: 'علم الحواس', nameEn: 'Perception', icon: 'sensors', count: 5, description: 'الحواس الخمس'),
  ];

  /// الحصول على علم بالمعرف
  static ScienceInfo? getScience(int id) {
    try {
      return sciences.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// الحصول على العلوم حسب الفئة
  static List<ScienceInfo> getSciencesByCategory(String category) {
    return sciences.where((s) => s.category == category).toList();
  }
}

/// =============================================================================
/// ScienceInfo - معلومات العلم
/// =============================================================================

class ScienceInfo {
  final int id;
  final String name;
  final String nameEn;
  final String icon;
  final int count;
  final String description;
  final String category;

  const ScienceInfo({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.count,
    required this.description,
    this.category = 'general',
  });
}

/// =============================================================================
/// DivineNames - الأسماء الإلهية
/// =============================================================================

class DivineNames {
  DivineNames._();

  /// الأسماء الإلهية الكاملة (99 اسم)
  static const List<DivineNameInfo> names = [
    DivineNameInfo(number: 1, name: 'الله', meaning: 'الإله الحق', attribute: 'ذاته'),
    DivineNameInfo(number: 2, name: 'الرحمن', meaning: 'ذو الرحمة الواسعة', attribute: 'الرحمة'),
    DivineNameInfo(number: 3, name: 'الرحيم', meaning: 'ذو الرحمة المخصصة', attribute: 'الرحمة'),
    DivineNameInfo(number: 4, name: 'الملك', meaning: 'ملك الملوك', attribute: 'الملك'),
    DivineNameInfo(number: 5, name: 'القدوس', meaning: 'المتنزه عن النقائص', attribute: 'التقديس'),
    DivineNameInfo(number: 6, name: 'السلام', meaning: 'المحروس من النقائص', attribute: 'الكمال'),
    DivineNameInfo(number: 7, name: 'المؤمن', meaning: 'الموثوق', attribute: 'الأمان'),
    DivineNameInfo(number: 8, name: 'المهيمن', meaning: 'الحافظ', attribute: 'الحفظ'),
    DivineNameInfo(number: 9, name: 'العزيز', meaning: 'ذو العزة التامة', attribute: 'العزة'),
    DivineNameInfo(number: 10, name: 'الجبار', meaning: 'القاهر لجميع الخلق', attribute: 'القهر'),
    DivineNameInfo(number: 11, name: 'المتكبر', meaning: 'المتصف بالكبرياء', attribute: 'الكبرياء'),
    DivineNameInfo(number: 12, name: 'الخالق', meaning: 'المبدع للأشياء', attribute: 'الخلق'),
    DivineNameInfo(number: 13, name: 'البارئ', meaning: 'المصمم للأشياء', attribute: 'البرء'),
    DivineNameInfo(number: 14, name: 'المصور', meaning: 'المصور للمخلوقات', attribute: 'الصورة'),
    DivineNameInfo(number: 15, name: 'الغفار', meaning: 'كثير المغفرة', attribute: 'المغفرة'),
    DivineNameInfo(number: 16, name: 'القهار', meaning: 'الغالب على جميع things', attribute: 'الغلب'),
    DivineNameInfo(number: 17, name: 'الوهاب', meaning: 'كثير العطاء', attribute: 'العطاء'),
    DivineNameInfo(number: 18, name: 'الرزاق', meaning: 'مسبب الرزق', attribute: 'الرزق'),
    DivineNameInfo(number: 19, name: 'الفتاح', meaning: 'الفاتح للأبواب', attribute: 'الفتح'),
    DivineNameInfo(number: 20, name: 'العليم', meaning: 'المحيط علماً', attribute: 'العلم'),
  ];

  /// الحصول على اسم بالمعرف
  static DivineNameInfo? getName(int number) {
    try {
      return names.firstWhere((n) => n.number == number);
    } catch (_) {
      return null;
    }
  }

  /// الحصول على الأسماء حسب الصفة
  static List<DivineNameInfo> getNamesByAttribute(String attribute) {
    return names.where((n) => n.attribute == attribute).toList();
  }
}

/// =============================================================================
/// DivineNameInfo - معلومات الاسم الإلهي
/// =============================================================================

class DivineNameInfo {
  final int number;
  final String name;
  final String meaning;
  final String attribute;
  final int color;

  const DivineNameInfo({
    required this.number,
    required this.name,
    required this.meaning,
    required this.attribute,
    this.color = 0xFFFFD700,
  });
}