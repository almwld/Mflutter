class HijriService {
  static const List<String> _hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const List<String> _monthLengths = [
    '30', '29', '30', '29', '30', '29', '30', '29', '30', '29', '30', '29',
  ];

  /// تحويل وفق التقويم الهجري الحسابي (مدني)، وليس رؤية الهلال المحلية.
  static ({int year, int month, int day}) fromGregorian(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    final jd = date.day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) -
        (y ~/ 100) + (y ~/ 400) - 32045;

    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final ll = l - 10631 * n + 354;
    final j = (((10985 - ll) ~/ 5316)) * ((50 * ll) ~/ 17719) +
        (ll ~/ 5670) * ((43 * ll) ~/ 15238);
    final l2 = ll - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final month = (24 * l2) ~/ 709;
    final day = l2 - (709 * month ~/ 24);
    final year = 30 * n + j - 30;

    return (year: year, month: month, day: day);
  }

  static String getCurrentHijriMonth() {
    final h = fromGregorian(DateTime.now());
    return _hijriMonths[h.month - 1] + ' ' + h.year.toString();
  }

  static String getCurrentHijriDate() {
    final h = fromGregorian(DateTime.now());
    return h.day.toString() + ' ' + _hijriMonths[h.month - 1] + ' ' + h.year.toString();
  }

  static String getHijriMonth(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'يجب أن يكون بين 1 و12');
    }
    return _hijriMonths[month - 1];
  }

  static int getMonthLength(int month, int year) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'يجب أن يكون بين 1 و12');
    }
    if (month == 12) {
      final leap = ((11 * year + 14) % 30) < 11;
      return leap ? 30 : 29;
    }
    return int.parse(_monthLengths[month - 1]);
  }

  static Map<String, String> getSpecialMonths() {
    return {
      'رمضان': 'شهر الصيام والقرآن',
      'ذو الحجة': 'شهر الحج',
      'محرم': 'شهر الله المحرم',
      'رجب': 'من الأشهر الحرم',
    };
  }
}
