import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// =============================================================================
/// DarkTheme - الثيم الداكن
/// =============================================================================
/// ثيم داكن بتدرجات كحلية وذهبية
/// =============================================================================

class DarkTheme {
  DarkTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // الثيم الداكن الكامل
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // الألوان الرئيسية
      colorScheme: const ColorScheme.dark(
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
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
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
          shadowColor: AppColors.primaryGold.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyles.buttonText,
        ),
      ),

      // أيقونات الأزرار
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
        ),
      ),

      // حقل الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackgroundDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.4)),
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
      ),

      // الحوارات
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.cardBackgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // الشيت السفلي
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // الفاصلة
      dividerTheme: DividerThemeData(
        color: AppColors.primaryNavyLight.withOpacity(0.2),
        thickness: 1,
      ),

      // التلميحات
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
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
        MudabbirDarkColors(
          primaryNavy: AppColors.primaryNavyLight,
          primaryGold: AppColors.primaryGold,
          deepBackground: AppColors.deepBackground,
        ),
      ],
    );
  }
}

/// =============================================================================
/// MudabbirDarkColors - ألوان مُخصصة للوضع الداكن
/// =============================================================================

class MudabbirDarkColors extends ThemeExtension<MudabbirDarkColors> {
  final Color primaryNavy;
  final Color primaryGold;
  final Color deepBackground;

  const MudabbirDarkColors({
    required this.primaryNavy,
    required this.primaryGold,
    required this.deepBackground,
  });

  @override
  MudabbirDarkColors copyWith({
    Color? primaryNavy,
    Color? primaryGold,
    Color? deepBackground,
  }) {
    return MudabbirDarkColors(
      primaryNavy: primaryNavy ?? this.primaryNavy,
      primaryGold: primaryGold ?? this.primaryGold,
      deepBackground: deepBackground ?? this.deepBackground,
    );
  }

  @override
  MudabbirDarkColors lerp(ThemeExtension<MudabbirDarkColors>? other, double t) {
    if (other is! MudabbirDarkColors) return this;
    return MudabbirDarkColors(
      primaryNavy: Color.lerp(primaryNavy, other.primaryNavy, t)!,
      primaryGold: Color.lerp(primaryGold, other.primaryGold, t)!,
      deepBackground: Color.lerp(deepBackground, other.deepBackground, t)!,
    );
  }
}