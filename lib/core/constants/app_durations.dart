/// =============================================================================
/// AppDurations - مدد الحركة والتأثيرات
/// =============================================================================
/// مدة الرسوم المتحركة والتأثيرات البصرية بالمللي ثانية
/// =============================================================================

class AppDurations {
  AppDurations._();

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد سريعة (للتفاعلات البسيطة)
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة سريعة جداً (للتأثيرات الفورية)
  static const Duration instant = Duration(milliseconds: 50);

  /// مدة قصيرة جداً (للنبضات السريعة)
  static const Duration fast = Duration(milliseconds: 100);

  /// مدة قصيرة (للتأثيرات السريعة)
  static const Duration short = Duration(milliseconds: 200);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد متوسطة (للتأثيرات القياسية)
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة متوسطة (للانتقالات القياسية)
  static const Duration medium = Duration(milliseconds: 300);

  /// مدة متوسطة طويلة (للانتقالات البطيئة قليلاً)
  static const Duration mediumLong = Duration(milliseconds: 400);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد طويلة (للتأثيرات البطيئة)
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة طويلة (للانتقالات البطيئة)
  static const Duration long = Duration(milliseconds: 500);

  /// مدة طويلة جداً (للانتقالات البطيئة جداً)
  static const Duration veryLong = Duration(milliseconds: 700);

  /// مدة إضافية طويلة (للتأثيرات الممتدة)
  static const Duration extraLong = Duration(milliseconds: 1000);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد خاصة للتأثيرات المتكررة
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة نبض واحدة
  static const Duration pulseOne = Duration(milliseconds: 600);

  /// مدة نبضتين
  static const Duration pulseTwo = Duration(milliseconds: 1200);

  /// مدة النبض المستمر
  static const Duration pulseContinuous = Duration(milliseconds: 1500);

  /// مدة التنفس
  static const Duration breathing = Duration(milliseconds: 3000);

  /// مدة الشهيق
  static const Duration inhale = Duration(milliseconds: 4000);

  /// مدة الزفير
  static const Duration exhale = Duration(milliseconds: 2000);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد الكتابة
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة حرف واحد للكتابة
  static const Duration typingChar = Duration(milliseconds: 50);

  /// مدة كلمة للكتابة
  static const Duration typingWord = Duration(milliseconds: 150);

  /// مدة فاصل بين الرسائل
  static const Duration typingDelay = Duration(milliseconds: 100);

  /// مدة قبل بدء الكتابة
  static const Duration typingStart = Duration(milliseconds: 500);

  /// مدة بعد انتهاء الكتابة
  static const Duration typingEnd = Duration(milliseconds: 300);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد التحميل
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة شريط التحميل
  static const Duration loadingBar = Duration(milliseconds: 800);

  /// مدة دوّار التحميل
  static const Duration loadingSpinner = Duration(milliseconds: 1000);

  /// مدة متعدد مراحل التحميل
  static const Duration loadingSteps = Duration(milliseconds: 2000);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد الانتقال بين الشاشات
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة انتقال شاشة
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// مدة انتقال شاشة منسدلة
  static const Duration pageSlide = Duration(milliseconds: 350);

  /// مدة انتقال فتحة
  static const Duration bottomSheet = Duration(milliseconds: 250);

  /// مدة انتقال مربّع حوار
  static const Duration dialog = Duration(milliseconds: 200);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد التألق
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة التألق
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// مدة تألق مطوّل
  static const Duration shimmerLong = Duration(milliseconds: 2000);

  /// مدة توهج
  static const Duration glow = Duration(milliseconds: 800);

  /// مدة بريق
  static const Duration sparkle = Duration(milliseconds: 600);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد الجسيمات
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة سقوط الجسيمات
  static const Duration particleFall = Duration(seconds: 3);

  /// مدة طفو الجسيمات
  static const Duration particleFloat = Duration(seconds: 4);

  /// مدة تلاشي الجسيمات
  static const Duration particleFade = Duration(milliseconds: 1500);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد الظهور والاختفاء
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة الظهور
  static const Duration fadeIn = Duration(milliseconds: 300);

  /// مدة الاختفاء
  static const Duration fadeOut = Duration(milliseconds: 200);

  /// مدة الظهور البطيء
  static const Duration fadeInSlow = Duration(milliseconds: 500);

  /// مدة الاختفاء البطيء
  static const Duration fadeOutSlow = Duration(milliseconds: 400);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد الدوران والتدوير
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة دوران كامل
  static const Duration rotateOnce = Duration(milliseconds: 1000);

  /// مدة دوران نصف
  static const Duration rotateHalf = Duration(milliseconds: 500);

  /// مدة دوران ربع
  static const Duration rotateQuarter = Duration(milliseconds: 250);

  // ═══════════════════════════════════════════════════════════════════════════
  // مدد التصغير والتكبير
  // ═══════════════════════════════════════════════════════════════════════════

  /// مدة تكبير/تصغير
  static const Duration scale = Duration(milliseconds: 200);

  /// مدة تكبير/تصغير بطيء
  static const Duration scaleSlow = Duration(milliseconds: 400);

  /// مدة تكبير بطيء جداً
  static const Duration scaleVerySlow = Duration(milliseconds: 800);

  // ═══════════════════════════════════════════════════════════════════════════
  // ثابت التأخير
  // ═══════════════════════════════════════════════════════════════════════════

  /// تأخير قصير
  static const Duration delayShort = Duration(milliseconds: 100);

  /// تأخير متوسط
  static const Duration delayMedium = Duration(milliseconds: 200);

  /// تأخير طويل
  static const Duration delayLong = Duration(milliseconds: 500);

  /// تأخير طويل جداً
  static const Duration delayVeryLong = Duration(seconds: 1);

  /// تأخير بين الحروف في الكتابة
  static const Duration delayTypingChar = Duration(milliseconds: 40);

  /// تأخير بين الكلمات في الكتابة
  static const Duration delayTypingWord = Duration(milliseconds: 150);
}