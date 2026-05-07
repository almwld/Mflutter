import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// =============================================================================
/// ColorScheme - نظام الألوان
/// =============================================================================
/// إنشاء أنظمة ألوان للتطبيق (فاتح/داكن)
/// =============================================================================

class ColorSchemeBuilder {
  ColorSchemeBuilder._();

  // ═══════════════════════════════════════════════════════════════════════════
  // نظام الألوان الفاتح
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء نظام ألوان فاتح
  static ColorScheme light({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? tertiary,
    Color? onTertiary,
  }) {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary ?? AppColors.primaryNavy,
      onPrimary: onPrimary ?? AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryNavyLight.withOpacity(0.3),
      onPrimaryContainer: AppColors.primaryNavy,
      secondary: secondary ?? AppColors.primaryGold,
      onSecondary: onSecondary ?? AppColors.textPrimary,
      secondaryContainer: AppColors.primaryGoldLight.withOpacity(0.2),
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: tertiary ?? AppColors.primaryNavyDark,
      onTertiary: onTertiary ?? AppColors.textOnPrimary,
      tertiaryContainer: AppColors.primaryNavyDark.withOpacity(0.2),
      onTertiaryContainer: AppColors.textOnPrimary,
      error: error ?? AppColors.error,
      onError: onError ?? Colors.white,
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,
      surface: surface ?? AppColors.cardBackground,
      onSurface: onSurface ?? AppColors.textPrimary,
      surfaceContainerHighest: AppColors.backgroundLight,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.primaryNavy.withOpacity(0.2),
      outlineVariant: AppColors.primaryNavy.withOpacity(0.1),
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.3),
      inverseSurface: AppColors.primaryNavyDark,
      onInverseSurface: AppColors.textOnPrimary,
      inversePrimary: AppColors.primaryNavyLight,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // نظام الألوان الداكن
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء نظام ألوان داكن
  static ColorScheme dark({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? error,
    Color? onError,
    Color? tertiary,
    Color? onTertiary,
  }) {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: primary ?? AppColors.primaryNavyLight,
      onPrimary: onPrimary ?? AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryNavy.withOpacity(0.5),
      onPrimaryContainer: AppColors.primaryGoldLight,
      secondary: secondary ?? AppColors.primaryGold,
      onSecondary: onSecondary ?? AppColors.textPrimary,
      secondaryContainer: AppColors.primaryGoldDark.withOpacity(0.3),
      onSecondaryContainer: AppColors.primaryGold,
      tertiary: tertiary ?? AppColors.primaryGoldLight,
      onTertiary: onTertiary ?? AppColors.textPrimary,
      tertiaryContainer: AppColors.primaryGoldDark.withOpacity(0.2),
      onTertiaryContainer: AppColors.primaryGoldLight,
      error: error ?? AppColors.error,
      onError: onError ?? Colors.white,
      errorContainer: AppColors.error.withOpacity(0.3),
      onErrorContainer: AppColors.error,
      surface: surface ?? AppColors.cardBackgroundDark,
      onSurface: onSurface ?? AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.backgroundDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.primaryNavyLight.withOpacity(0.3),
      outlineVariant: AppColors.primaryNavyLight.withOpacity(0.2),
      shadow: Colors.black.withOpacity(0.4),
      scrim: Colors.black.withOpacity(0.5),
      inverseSurface: AppColors.textPrimaryDark,
      onInverseSurface: AppColors.primaryNavyDark,
      inversePrimary: AppColors.primaryNavy,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ألوان خاصة للبصيرة
  // ═══════════════════════════════════════════════════════════════════════════

  /// نظام ألوان البصيرة
  static ColorScheme insight() {
    return ColorScheme.light(
      primary: AppColors.primaryNavy,
      secondary: AppColors.primaryGold,
      tertiary: AppColors.deepBackground,
      surface: AppColors.cardBackground,
      error: AppColors.error,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ألوان خاصة بالجُمَّل
  // ═══════════════════════════════════════════════════════════════════════════

  /// نظام ألوان الجُمَّل
  static ColorScheme abjad() {
    return ColorScheme.light(
      primary: AppColors.elementFire,
      secondary: AppColors.elementWater,
      tertiary: AppColors.elementEarth,
      surface: AppColors.cardBackground,
      error: AppColors.error,
    );
  }
}