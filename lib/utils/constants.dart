/// =============================================================================
/// AppColors - ألوان التطبيق
/// =============================================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color primaryGold = Color(0xFFFFD700);

  // ألوان الخلفية
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1B263B);
  static const Color cardBackground = Color(0xFF415A77);

  // ألوان النص
  static const Color textOnPrimary = Color(0xFFE0E1DD);
  static const Color textSecondary = Color(0xFF778DA9);
  static const Color textHint = Color(0xFF415A77);

  // ألوان العناصر
  static const Color elementFire = Color(0xFFFF6B6B);
  static const Color elementWater = Color(0xFF4ECDC4);
  static const Color elementEarth = Color(0xFF95E1D3);
  static const Color elementAir = Color(0xFFF38181);
  static const Color elementSpirit = Color(0xFFFFD93D);

  // ألوان الكواكب
  static const Color planetSun = Color(0xFFFFD700);
  static const Color planetMoon = Color(0xFFC0C0C0);
  static const Color planetMars = Color(0xFFFF4444);
  static const Color planetMercury = Color(0xFF8B4513);
  static const Color planetJupiter = Color(0xFF4169E1);
  static const Color planetVenus = Color(0xFFDA70D6);
  static const Color planetSaturn = Color(0xFF696969);

  // ألوان الأبراج
  static const Color zodiacFire = Color(0xFFFF6B6B);
  static const Color zodiacEarth = Color(0xFF8B4513);
  static const Color zodiacAir = Color(0xFF87CEEB);
  static const Color zodiacWater = Color(0xFF4169E1);

  // تدرجات لونية
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, Color(0xFF0D47A1)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, Color(0xFFFFA500)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceDark, backgroundDark],
  );
}

/// =============================================================================
/// AppDimensions - أبعاد التطبيق
/// =============================================================================

class AppDimensions {
  AppDimensions._();

  // الهوامش
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // الحشو
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // الزوايا
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // الأيقونات
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // البطاقات
  static const double cardElevation = 4.0;
  static const double cardRadius = 16.0;

  // التنقل
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;
}

/// =============================================================================
/// AppStrings - نصوص التطبيق
/// =============================================================================

class AppStrings {
  AppStrings._();

  // اسم التطبيق
  static const String appName = 'مُدَبِّر الْأَسْرَارِ الْعُلْيَا';
  static const String appTagline = 'إدارة أسرار العلوم الربانية';

  // الشاشات
  static const String home = 'الرئيسية';
  static const String quran = 'القرآن';
  static const String abjad = 'الجُمَّل';
  static const String chat = 'المحادثة';
  static const String sciences = 'العلوم';
  static const String attributes = 'الصفات';
  static const String insights = 'البصيرة';
  static const String settings = 'الإعدادات';

  // الأزرار
  static const String calculate = 'احسب';
  static const String search = 'بحث';
  static const String send = 'إرسال';
  static const String save = 'حفظ';

  // الحالات
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String empty = 'لا توجد بيانات';
  static const String success = 'تم بنجاح';
}