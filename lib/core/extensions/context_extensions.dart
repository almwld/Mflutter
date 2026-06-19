import 'package:flutter/material.dart';

/// =============================================================================
/// ContextExtensions - إضافات السياق
/// =============================================================================
/// إضافات مفيدة للوصول السريع من الـ BuildContext
/// =============================================================================

extension ContextExtensions on BuildContext {
  // ═══════════════════════════════════════════════════════════════════════════
  // الأبعاد
  // ═══════════════════════════════════════════════════════════════════════════

  /// حجم الشاشة
  Size get screenSize => MediaQuery.of(this).size;

  /// عرض الشاشة
  double get screenWidth => screenSize.width;

  /// ارتفاع الشاشة
  double get screenHeight => screenSize.height;

  /// نسبة الشاشة
  double get aspectRatio => screenSize.aspectRatio;

  // ═══════════════════════════════════════════════════════════════════════════
  // الحواف
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحواف الآمنة
  EdgeInsets get safeArea => MediaQuery.of(this).padding;

  /// الحواف الآمنة (bottom)
  double get safeAreaBottom => safeArea.bottom;

  /// الحواف الآمنة (top)
  double get safeAreaTop => safeArea.top;

  // ═══════════════════════════════════════════════════════════════════════════
  // الاتجاه
  // ═══════════════════════════════════════════════════════════════════════════

  /// اتجاه النص
  TextDirection get textDirection => Directionality.of(this);

  /// هل RTL؟
  bool get isRTL => textDirection == TextDirection.rtl;

  // ═══════════════════════════════════════════════════════════════════════════
  // الثيم
  // ═══════════════════════════════════════════════════════════════════════════

  /// الثيم
  ThemeData get theme => Theme.of(this);

  /// مستخدم الألوان
  ColorScheme get colorScheme => theme.colorScheme;

  /// النص
  TextTheme get textTheme => theme.textTheme;

  /// البيانات
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  // ═══════════════════════════════════════════════════════════════════════════
  // السوفولد
  // ═══════════════════════════════════════════════════════════════════════════

  /// ارتفاع السوفلد
  double get scaffoldHeight => screenHeight - safeAreaTop - safeAreaBottom;

  // ═══════════════════════════════════════════════════════════════════════════
  // اللوكال
  // ═══════════════════════════════════════════════════════════════════════════

  /// اللوكال الحالي
  Locale get locale => Localizations.localeOf(this);

  /// اللغة الحالية
  String get languageCode => locale.languageCode;

  // ═══════════════════════════════════════════════════════════════════════════
  // العرض
  // ═══════════════════════════════════════════════════════════════════════════

  /// عرض صغير؟
  bool get isSmallWidth => screenWidth < 600;

  /// عرض متوسط؟
  bool get isMediumWidth => screenWidth >= 600 && screenWidth < 840;

  /// عرض كبير؟
  bool get isLargeWidth => screenWidth >= 840;

  /// تصميم موبايل؟
  bool get isMobile => isSmallWidth;

  /// تصميم تابلت؟
  bool get isTablet => isMediumWidth || isLargeWidth;

  // ═══════════════════════════════════════════════════════════════════════════
  // العرض المُعبَّر
  // ═══════════════════════════════════════════════════════════════════════════

  /// جزء من العرض
  double fractionWidth(double fraction) => screenWidth * fraction;

  /// جزء من الارتفاع
  double fractionHeight(double fraction) => screenHeight * fraction;
}

/// =============================================================================
/// NumberExtensions - إضافات الأرقام
/// =============================================================================

extension NumberExtensions on num {
  // ═══════════════════════════════════════════════════════════════════════════
  // التنسيق
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق كعملة
  String toCurrency({String symbol = 'ر.س', int decimals = 2}) {
    return '${toStringAsFixed(decimals)} $symbol';
  }

  /// تنسيق كرقم
  String toFormattedNumber({String separator = ','}) {
    final str = abs().toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(str[i]);
      count++;
    }
    return '${this < 0 ? '-' : ''}${buffer.toString().split('').reversed.join()}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الوقت
  // ═══════════════════════════════════════════════════════════════════════════

  /// إلى Duration
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());

  // ═══════════════════════════════════════════════════════════════════════════
  // الحجم
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق كحجم ملف
  String toFileSize() {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// =============================================================================
/// DurationExtensions - إضافات المدة
/// =============================================================================

extension DurationExtensions on Duration {
  // ═══════════════════════════════════════════════════════════════════════════
  // التنسيق
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنسيق كمدة
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// تنسيق كمدة مفصلة
  String get formattedLong {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours ساعة');
    if (minutes > 0) parts.add('$minutes دقيقة');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds ثانية');

    return parts.join(' و ');
  }
}