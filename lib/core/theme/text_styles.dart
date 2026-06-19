import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// =============================================================================
/// TextStyles - أنماط النصوص
/// =============================================================================
/// خطوط Cairo للنص العربي مع أحجام وأوزان متنوعة
/// =============================================================================

class TextStyles {
  TextStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // عنوان شريط التطبيق
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get appBarTitle => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // الأزرار
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // تلميحات الإدخال
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get hintText => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get hintTextDark => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryDark,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // تسميات الإدخال
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get labelText => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelTextDark => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العرض - Light
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العناوين الرئيسية - Light
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العناوين الفرعية - Light
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // النص الأساسي - Light
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // التسميات - Light
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // النص العربي الجميل - القرآن
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get quranText => GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryNavy,
        height: 2.0,
        letterSpacing: 1.5,
      );

  static TextStyle get quranTextLarge => GoogleFonts.amiri(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryNavy,
        height: 2.2,
        letterSpacing: 2,
      );

  static TextStyle get quranTextSmall => GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryNavy,
        height: 1.8,
        letterSpacing: 1,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العرض - Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get displayLargeDark => GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMediumDark => GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
      );

  static TextStyle get displaySmallDark => GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العناوين الرئيسية - Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get headlineLargeDark => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0,
      );

  static TextStyle get headlineMediumDark => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0,
      );

  static TextStyle get headlineSmallDark => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // العناوين الفرعية - Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get titleLargeDark => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0,
      );

  static TextStyle get titleMediumDark => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmallDark => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.1,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // النص الأساسي - Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get bodyLargeDark => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMediumDark => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmallDark => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryDark,
        letterSpacing: 0.4,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // التسميات - Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get labelLargeDark => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMediumDark => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmallDark => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
        letterSpacing: 0.5,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // النص العربي الجميل - القرآن Dark
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get quranTextDark => GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryGoldLight,
        height: 2.0,
        letterSpacing: 1.5,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // نص خاص للنتائج
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get resultNumber => GoogleFonts.cairo(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGold,
        letterSpacing: 2,
      );

  static TextStyle get resultLabel => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // نص العد التنازلي
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get counterText => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryNavy,
      );
}