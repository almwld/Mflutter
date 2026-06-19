import '../entities/verse.dart';
import '../entities/abjad_result.dart';
import '../entities/letter.dart';

/// =============================================================================
/// QuranRepository - مستودع القرآن
/// =============================================================================

abstract class QuranRepository {
  /// جلب جميع السور
  Future<List<Surah>> getAllSurahs();

  /// جلب آيات سورة
  Future<List<Verse>> getSurahVerses(int surahNumber);

  /// جلب آية محددة
  Future<Verse?> getVerse(int surahNumber, int ayahNumber);

  /// بحث في القرآن
  Future<List<Verse>> search(String query);

  /// جلب آية عشوائية
  Future<Verse> getRandomVerse();

  /// جلب آية يومية
  Future<Verse> getDailyVerse();

  /// جلب آيات مشابهة
  Future<List<Verse>> getSimilarVerses(String text);

  /// جلب الأجزاء
  Future<List<Juz>> getAllJuz();

  /// جلب جزء
  Future<Juz?> getJuz(int juzNumber);

  /// جلب إحصائيات البحث
  Future<Map<String, int>> getSearchStatistics();
}

/// =============================================================================
/// AbjadRepository - مستودع الجُمَّل
/// =============================================================================

abstract class AbjadRepository {
  /// حساب الجمل
  AbjadResultEntity calculateAbjad(String text);

  /// تحليل الحروف
  LetterAnalysis analyzeLetters(String text);

  /// الحصول على توازن العناصر
  ElementBalance getElementalBalance(String text);

  /// الحصول على تأثير الكواكب
  PlanetaryInfluence getPlanetaryInfluence(String text);

  /// الحصول على رنين الاسم الإلهي
  DivineResonance getDivineResonance(String text);

  /// الحصول على القيم لكل حرف
  List<LetterBreakdown> getLetterBreakdown(String text);
}

/// =============================================================================
/// ModelsRepository - مستودع النماذج
/// =============================================================================

abstract class ModelsRepository {
  /// جلب معلومات النموذج
  Future<ModelInfo?> getModelInfo(String modelName);

  /// تحميل النموذج
  Future<bool> loadModel(String modelName);

  /// تشغيل الاستدلال
  Future<Map<String, dynamic>> runInference(
    String modelName,
    List<double> features,
  );

  /// استخراج الميزات
  List<double> extractFeatures(String text);

  /// جلب جميع النماذج
  Future<List<ModelInfo>> getAllModels();

  /// إلغاء تحميل النموذج
  Future<void> unloadModel(String modelName);
}

/// =============================================================================
/// ChatRepository - مستودع المحادثة
/// =============================================================================

abstract class ChatRepository {
  /// جلب المحادثة
  Future<ChatConversation?> getConversation(String conversationId);

  /// جلب جميع المحادثات
  Future<List<ChatConversation>> getAllConversations();

  /// إنشاء محادثة جديدة
  Future<ChatConversation> createConversation(String title);

  /// إضافة رسالة
  Future<ChatMessage> addMessage(
    String conversationId,
    String content,
    MessageType type,
  );

  /// حذف محادثة
  Future<void> deleteConversation(String conversationId);

  /// حفظ المحادثة
  Future<void> saveConversation(ChatConversation conversation);

  /// جلب سجل البحث
  Future<List<SearchHistory>> getSearchHistory();
}

/// =============================================================================
/// SettingsRepository - مستودع الإعدادات
/// =============================================================================

abstract class SettingsRepository {
  /// جلب الثيم
  Future<String> getTheme();

  /// تعيين الثيم
  Future<void> setTheme(String theme);

  /// جلب اللغة
  Future<String> getLanguage();

  /// تعيين اللغة
  Future<void> setLanguage(String language);

  /// جلب إعداد
  Future<T?> getSetting<T>(String key);

  /// تعيين إعداد
  Future<void> setSetting<T>(String key, T value);

  /// مسح ذاكرة التخزين المؤقت
  Future<void> clearCache();

  /// جلب ملف المستخدم
  Future<UserProfile?> getUserProfile();

  /// حفظ ملف المستخدم
  Future<void> saveUserProfile(UserProfile profile);
}