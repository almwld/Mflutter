import 'package:flutter/material.dart';

/// =============================================================================
/// RTLUtils - أدوات RTL
/// =============================================================================
/// مساعدة في دعم اللغة العربية من اليمين لليسار
/// =============================================================================

class RTLUtils {
  RTLUtils._();

  // ═══════════════════════════════════════════════════════════════════════════
  // اتجاه النص
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على اتجاه النص
  static TextDirection getTextDirection(String text) {
    // إذا كان النص يحتوي على أحرف عربية، استخدم RTL
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// التحقق من أن النص عربي
  static bool isRTL(String text) {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return arabicRegex.hasMatch(text.trim());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // اتجاه المحاذاة
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على محاذاة النص
  static TextAlign getTextAlign({bool isRTL = true}) {
    return isRTL ? TextAlign.right : TextAlign.left;
  }

  /// الحصول على محاذاة البداية
  static Alignment getStartAlignment({bool isRTL = true}) {
    return isRTL ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// الحصول على محاذاة النهاية
  static Alignment getEndAlignment({bool isRTL = true}) {
    return isRTL ? Alignment.centerLeft : Alignment.centerRight;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // اتجاه العناصر
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على اتجاه الصف
  static MainAxisAlignment getRowMainAlignment({bool isRTL = true}) {
    return isRTL ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// الحصول على اتجاه RTL
  static Directionality getDirectionality({bool isRTL = true}) {
    return isRTL ? Directionality.rtl : Directionality.ltr;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EdgeInsets RTL
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل EdgeInsets للـ RTL
  static EdgeInsets flipEdgeInsets(EdgeInsets insets) {
    return EdgeInsets.only(
      left: insets.right,
      right: insets.left,
      top: insets.top,
      bottom: insets.bottom,
    );
  }

  /// الحصول على padding RTL
  static EdgeInsets getPadding({
    bool isRTL = true,
    double start = 16,
    double end = 16,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: isRTL ? end : start,
      right: isRTL ? start : end,
      top: top,
      bottom: bottom,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // محاذاة الأيقونات
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على موقع الأيقونة في TextField
  static IconAlignment getIconAlignment({bool isRTL = true}) {
    return isRTL ? IconAlignment.end : IconAlignment.start;
  }

  /// الحصول على موقع الأيقونة المساعد
  static MainAxisAlignment getIconRowAlignment({bool isRTL = true}) {
    return isRTL ? MainAxisAlignment.start : MainAxisAlignment.end;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BorderRadius RTL
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل BorderRadius للـ RTL
  static BorderRadius flipBorderRadius(BorderRadius radius) {
    return BorderRadius.only(
      topRight: radius.topLeft,
      topLeft: radius.topRight,
      bottomRight: radius.bottomLeft,
      bottomLeft: radius.bottomRight,
    );
  }

  /// الحصول على border radius للـ RTL
  static BorderRadius getRTLBorderRadius({
    double topStart = 12,
    double topEnd = 12,
    double bottomStart = 12,
    double bottomEnd = 12,
  }) {
    // في RTL، يتم عكس الأرقام
    return BorderRadius.only(
      topRight: Radius.circular(topStart),
      topLeft: Radius.circular(topEnd),
      bottomRight: Radius.circular(bottomStart),
      bottomLeft: Radius.circular(bottomEnd),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحولات RTL
  // ═══════════════════════════════════════════════════════════════════════════

  /// إنشاء Widget مع Directionality
  static Widget withDirectionality(Widget child, {bool isRTL = true}) {
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }

  /// إنشاء Widget مع المحاذاة الصحيحة
  static Widget withCorrectAlignment(
    Widget child, {
    bool isRTL = true,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final effectiveAlignment = isRTL
        ? (mainAxisAlignment == MainAxisAlignment.start
            ? MainAxisAlignment.end
            : mainAxisAlignment)
        : mainAxisAlignment;

    return Row(
      mainAxisAlignment: effectiveAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [child],
    );
  }
}

/// =============================================================================
/// RTLProvider - مزود RTL
/// =============================================================================

class RTLProvider extends InheritedWidget {
  final bool isRTL;

  const RTLProvider({
    super.key,
    required this.isRTL,
    required super.child,
  });

  static RTLProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RTLProvider>();
  }

  static bool isRTLOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RTLProvider>();
    return provider?.isRTL ?? true;
  }
}