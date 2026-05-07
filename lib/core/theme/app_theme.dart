import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// =============================================================================
/// AppTheme - ثيم التطبيق
/// =============================================================================
/// ثيم كحلي + ذهبي بمعايير Material Design 3
/// =============================================================================

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // الثيم الفاتح
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // الألوان الرئيسية
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryNavy,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryGold,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // الخلفية
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
      ),

      // البطاقات
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.primaryNavy.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textPrimary,
          elevation: 4,
          shadowColor: AppColors.primaryGold.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyles.buttonText,
        ),
      ),

      // حقل الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavy.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavy.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        hintStyle: TextStyles.hintText,
        labelStyle: TextStyles.labelText,
      ),

      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
      ),

      // النص
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge,
        displayMedium: TextStyles.displayMedium,
        displaySmall: TextStyles.displaySmall,
        headlineLarge: TextStyles.headlineLarge,
        headlineMedium: TextStyles.headlineMedium,
        headlineSmall: TextStyles.headlineSmall,
        titleLarge: TextStyles.titleLarge,
        titleMedium: TextStyles.titleMedium,
        titleSmall: TextStyles.titleSmall,
        bodyLarge: TextStyles.bodyLarge,
        bodyMedium: TextStyles.bodyMedium,
        bodySmall: TextStyles.bodySmall,
        labelLarge: TextStyles.labelLarge,
        labelMedium: TextStyles.labelMedium,
        labelSmall: TextStyles.labelSmall,
      ),

      // التدرج
      extensions: [
        MudabbirColors(
          primaryNavy: AppColors.primaryNavy,
          primaryGold: AppColors.primaryGold,
          deepBackground: AppColors.deepBackground,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الثيم الداكن
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // الألوان الرئيسية
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryNavyLight,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryGold,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.cardBackgroundDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // الخلفية
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepBackground,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
      ),

      // البطاقات
      cardTheme: CardTheme(
        color: AppColors.cardBackgroundDark,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textPrimary,
          elevation: 4,
          shadowColor: AppColors.primaryGold.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyles.buttonText,
        ),
      ),

      // حقل الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackgroundDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        hintStyle: TextStyles.hintTextDark,
        labelStyle: TextStyles.labelTextDark,
      ),

      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
      ),

      // النص
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLargeDark,
        displayMedium: TextStyles.displayMediumDark,
        displaySmall: TextStyles.displaySmallDark,
        headlineLarge: TextStyles.headlineLargeDark,
        headlineMedium: TextStyles.headlineMediumDark,
        headlineSmall: TextStyles.headlineSmallDark,
        titleLarge: TextStyles.titleLargeDark,
        titleMedium: TextStyles.titleMediumDark,
        titleSmall: TextStyles.titleSmallDark,
        bodyLarge: TextStyles.bodyLargeDark,
        bodyMedium: TextStyles.bodyMediumDark,
        bodySmall: TextStyles.bodySmallDark,
        labelLarge: TextStyles.labelLargeDark,
        labelMedium: TextStyles.labelMediumDark,
        labelSmall: TextStyles.labelSmallDark,
      ),

      // التدرج
      extensions: [
        MudabbirColors(
          primaryNavy: AppColors.primaryNavyLight,
          primaryGold: AppColors.primaryGold,
          deepBackground: AppColors.deepBackground,
        ),
      ],
    );
  }
}

/// =============================================================================
/// MudabbirColors - ألوان مُخصصة للتطبيق
/// =============================================================================

class MudabbirColors extends ThemeExtension<MudabbirColors> {
  final Color primaryNavy;
  final Color primaryGold;
  final Color deepBackground;

  const MudabbirColors({
    required this.primaryNavy,
    required this.primaryGold,
    required this.deepBackground,
  });

  @override
  MudabbirColors copyWith({
    Color? primaryNavy,
    Color? primaryGold,
    Color? deepBackground,
  }) {
    return MudabbirColors(
      primaryNavy: primaryNavy ?? this.primaryNavy,
      primaryGold: primaryGold ?? this.primaryGold,
      deepBackground: deepBackground ?? this.deepBackground,
    );
  }

  @override
  MudabbirColors lerp(ThemeExtension<MudabbirColors>? other, double t) {
    if (other is! MudabbirColors) return this;
    return MudabbirColors(
      primaryNavy: Color.lerp(primaryNavy, other.primaryNavy, t)!,
      primaryGold: Color.lerp(primaryGold, other.primaryGold, t)!,
      deepBackground: Color.lerp(deepBackground, other.deepBackground, t)!,
    );
  }
}