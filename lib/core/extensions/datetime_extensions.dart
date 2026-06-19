/// =============================================================================
/// DateTimeExtensions - إضافات التاريخ والوقت
/// =============================================================================
/// إضافات مفيدة للتواريخ والأوقات
/// =============================================================================

extension DateTimeExtensions on DateTime {
  // ═══════════════════════════════════════════════════════════════════════════
  // التحقق
  // ═══════════════════════════════════════════════════════════════════════════

  /// هل اليوم؟
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// هل الأمس؟
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
           month == yesterday.month &&
           day == yesterday.day;
  }

  /// هل غداً؟
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
           month == tomorrow.month &&
           day == tomorrow.day;
  }

  /// هل نفس اليوم؟
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// هل نهاية الأسبوع؟
  bool get isWeekend => weekday == 6 || weekday == 7;

  // ═══════════════════════════════════════════════════════════════════════════
  // التنسيق
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق التاريخ
  String get formattedDate {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  /// تنسيق الوقت
  String get formattedTime {
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  /// تنسيق التاريخ والوقت
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// تنسيق طويل
  String get formattedLong {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const days = [
      'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء',
      'الخميس', 'الجمعة', 'السبت',
    ];

    return '${days[weekday % 7]}، $day ${months[month - 1]} $year';
  }

  /// تنسيق نسبي
  String get relativeFormatted {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // المستقبل
      return _formatFuture(difference.abs());
    } else {
      // الماضي
      return _formatPast(difference);
    }
  }

  /// اسم اليوم
  String get dayName {
    const days = [
      'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء',
      'الخميس', 'الجمعة', 'السبت',
    ];
    return days[weekday % 7];
  }

  /// اسم الشهر
  String get monthName {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return months[month - 1];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // التعديل
  // ═══════════════════════════════════════════════════════════════════════════

  /// بداية اليوم
  DateTime get startOfDay => DateTime(year, month, day);

  /// نهاية اليوم
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// بداية الأسبوع
  DateTime get startOfWeek {
    final diff = weekday % 7;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// نهاية الأسبوع
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6)).endOfDay;

  /// بداية الشهر
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// نهاية الشهر
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// بداية السنة
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// نهاية السنة
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // ═══════════════════════════════════════════════════════════════════════════
  // العمليات
  // ═══════════════════════════════════════════════════════════════════════════

  /// إضافة أيام
  DateTime addDays(int days) => add(Duration(days: days));

  /// طرح أيام
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// إضافة ساعات
  DateTime addHours(int hours) => add(Duration(hours: hours));

  /// طرح ساعات
  DateTime subtractHours(int hours) => subtract(Duration(hours: hours));

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال خاصة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق الماضي
  String _formatPast(Duration diff) {
    if (diff.inDays > 365) {
      final years = diff.inDays ~/ 365;
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (diff.inDays > 30) {
      final months = diff.inDays ~/ 30;
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} ${diff.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ${diff.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} ${diff.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// تنسيق المستقبل
  String _formatFuture(Duration diff) {
    if (diff.inDays > 365) {
      final years = diff.inDays ~/ 365;
      return 'خلال $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (diff.inDays > 30) {
      final months = diff.inDays ~/ 30;
      return 'خلال $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (diff.inDays > 0) {
      return 'خلال ${diff.inDays} ${diff.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (diff.inHours > 0) {
      return 'خلال ${diff.inHours} ${diff.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (diff.inMinutes > 0) {
      return 'خلال ${diff.inMinutes} ${diff.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }
}

/// =============================================================================
/// DateOnlyCompare - مقارنة التاريخ فقط
/// =============================================================================

extension DateOnlyCompare on DateTime {
  /// يساوي تاريخ فقط
  bool equalsDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// قبل
  bool isBeforeDate(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.isBefore(otherDate);
  }

  /// بعد
  bool isAfterDate(DateTime other) {
    final thisDate = DateTime(year, month, day);
    final otherDate = DateTime(other.year, other.month, other.day);
    return thisDate.isAfter(otherDate);
  }
}