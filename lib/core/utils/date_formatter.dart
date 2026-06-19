import 'package:intl/intl.dart';

/// =============================================================================
/// DateFormatter - مُنسيق التاريخ
/// =============================================================================
/// يُنسيق التواريخ والأوقات
/// =============================================================================

class DateFormatter {
  DateFormatter._();

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق التاريخ الهجري
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق التاريخ الهجري
  static String formatHijri(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  /// تنسيق التاريخ الهجري الطويل
  static String formatHijriLong(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd', 'ar');
    return '${formatter.format(date)} هـ';
  }

  /// تنسيق التاريخ الميلادي
  static String formatGregorian(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'en').format(date);
  }

  /// تنسيق التاريخ الميلادي الطويل
  static String formatGregorianLong(DateTime date) {
    return DateFormat('d MMMM yyyy', 'ar').format(date);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق الوقت
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق الوقت (12 ساعة)
  static String formatTime12(DateTime date) {
    return DateFormat('h:mm a', 'ar').format(date);
  }

  /// تنسيق الوقت (24 ساعة)
  static String formatTime24(DateTime date) {
    return DateFormat('HH:mm', 'ar').format(date);
  }

  /// تنسيق الوقت مع الثواني
  static String formatTimeWithSeconds(DateTime date) {
    return DateFormat('HH:mm:ss', 'ar').format(date);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق التاريخ والوقت
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(date);
  }

  /// تنسيق التاريخ والوقت الطويل
  static String formatDateTimeLong(DateTime date) {
    return DateFormat('d MMMM yyyy، h:mm a', 'ar').format(date);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق المدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق المدة (ساعات ودقائق)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    }
    return '$minutes دقيقة';
  }

  /// تنسيق المدة (دقائق وثواني)
  static String formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// تنسيق الثواني
  static String formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق الفترة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق الفترة الزمنية (من الآن)
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = difference.inDays ~/ 365;
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = difference.inDays ~/ 30;
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// تنسيق الفترة الزمنية (للمستقبل)
  static String formatTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'انتهت المدة';
    } else if (difference.inDays > 365) {
      final years = difference.inDays ~/ 365;
      return 'خلال $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = difference.inDays ~/ 30;
      return 'خلال $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'خلال ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'خلال ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'خلال ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تنسيق خاص
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق اسم اليوم
  static String getDayName(DateTime date) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[date.weekday % 7];
  }

  /// تنسيق اسم الشهر
  static String getMonthName(DateTime date) {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return months[date.month - 1];
  }

  /// تنسيق التاريخ الشائع
  static String formatCommon(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'اليوم، ${formatTime12(date)}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'أمس، ${formatTime12(date)}';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'غداً، ${formatTime12(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}