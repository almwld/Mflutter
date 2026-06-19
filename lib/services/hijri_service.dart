class HijriService {
  static final List<String> _hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static String getCurrentHijriMonth() {
    // تقريبي - التاريخ الهجري الفعلي يحتاج حساباً دقيقاً
    return 'ذو القعدة 1446';
  }

  static String getHijriMonth(int month) {
    return _hijriMonths[month - 1];
  }

  static Map<String, String> getSpecialMonths() {
    return {
      'رمضان': 'شهر الصيام والقرآن',
      'ذو الحجة': 'شهر الحج',
      'محرم': 'شهر الله المحرم',
      'رجب': 'شهر الإسراء والمعراج',
    };
  }
}
