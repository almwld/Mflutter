import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// =============================================================================
/// Decorations - زخارف التطبيق
/// =============================================================================
/// زخارف وتدرجات وإطارات العناصر
/// =============================================================================

class Decorations {
  Decorations._();

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف البطاقات
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة البطاقة الأساسية
  static BoxDecoration get cardBasic => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// زخرفة البطاقة المُعلَّقة
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// زخرفة البطاقة الذهبية
  static BoxDecoration get cardGold => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGoldLight,
            AppColors.primaryGold,
            AppColors.primaryGoldDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// زخرفة البطاقة الكحلية
  static BoxDecoration get cardNavy => BoxDecoration(
        gradient: AppColors.navyGoldGradient,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  /// زخرفة البطاقة العميقة
  static BoxDecoration get cardDeep => BoxDecoration(
        gradient: AppColors.deepGradient,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف الأزرار
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة الزر الذهبي
  static BoxDecoration get buttonGold => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryGoldLight,
            AppColors.primaryGold,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  /// زخرفة الزر الكحلي
  static BoxDecoration get buttonNavy => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryNavyLight,
            AppColors.primaryNavy,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  /// زخرفة الزر الدائري الذهبي
  static BoxDecoration get circularButtonGold => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGoldLight,
            AppColors.primaryGold,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف الإطارات
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة الإطار الذهبي
  static BoxDecoration get goldenFrame => BoxDecoration(
        border: Border.all(
          color: AppColors.primaryGold,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      );

  /// زخرفة الإطار الكحلي
  static BoxDecoration get navyFrame => BoxDecoration(
        border: Border.all(
          color: AppColors.primaryNavy,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف الفقاعات
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة فقاعة المستخدم
  static BoxDecoration get userBubble => BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppDimensions.chatBubbleRadius),
          topLeft: Radius.circular(AppDimensions.chatBubbleRadius),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(AppDimensions.chatBubbleRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// زخرفة فقاعة المساعد
  static BoxDecoration get assistantBubble => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppDimensions.chatBubbleRadius),
          topLeft: Radius.circular(AppDimensions.chatBubbleRadius),
          bottomRight: Radius.circular(AppDimensions.chatBubbleRadius),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف الأقراص
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة القرص الذهبي
  static BoxDecoration get goldenWheel => BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryGoldLight,
            AppColors.primaryGold,
            AppColors.primaryGoldDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      );

  /// زخرفة القرص الكحلي
  static BoxDecoration get navyWheel => BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryNavyLight,
            AppColors.primaryNavy,
            AppColors.primaryNavyDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف شريط الطاقة
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة شريط الطاقة
  static BoxDecoration get energyBar => BoxDecoration(
        color: AppColors.primaryNavyDark,
        borderRadius: BorderRadius.circular(AppDimensions.energyBarRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف الخلفية
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة الخلفية العميقة
  static BoxDecoration get deepBackground => const BoxDecoration(
        gradient: AppColors.deepGradient,
      );

  /// زخرفة الخلفية الكحلية
  static BoxDecoration get navyBackground => const BoxDecoration(
        gradient: AppColors.navyGoldGradient,
      );

  /// زخرفة الخلفية الذهبية
  static BoxDecoration get goldBackground => const BoxDecoration(
        gradient: AppColors.goldGradient,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // زخارف التألق
  // ═══════════════════════════════════════════════════════════════════════════

  /// زخرفة التألق الذهبي
  static BoxDecoration get goldenShimmer => BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      );

  /// زخرفة التألق الكحلي
  static BoxDecoration get navyShimmer => BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      );
}

/// =============================================================================
/// GradientDecorations - تدرجات مُخصصة
/// =============================================================================

class GradientDecorations {
  GradientDecorations._();

  /// تدرج كحلي عميق
  static const LinearGradient deepNavy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A237E),
      Color(0xFF0D1259),
      Color(0xFF050A20),
    ],
  );

  /// تدرج ذهبي متوهج
  static const LinearGradient glowingGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE57F),
      Color(0xFFFFD700),
      Color(0xFFC7A600),
    ],
  );

  /// تدرج قوس قزح
  static const LinearGradient rainbow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE53935),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFF9C27B0),
    ],
  );

  /// تدرج عنصر النار
  static const LinearGradient fire = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFEB3B),
      Color(0xFFFF9800),
      Color(0xFFE53935),
    ],
  );

  /// تدرج عنصر الماء
  static const LinearGradient water = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF81D4FA),
      Color(0xFF29B6F6),
      Color(0xFF1E88E5),
    ],
  );

  /// تدرج عنصر التراب
  static const LinearGradient earth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA1887F),
      Color(0xFF795548),
      Color(0xFF5D4037),
    ],
  );

  /// تدرج عنصر الهواء
  static const LinearGradient air = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFBDBDBD),
      Color(0xFF9E9E9E),
    ],
  );

  /// تدرج عنصر الروح
  static const LinearGradient spirit = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE1BEE7),
      Color(0xFF9C27B0),
      Color(0xFF7B1FA2),
    ],
  );
}