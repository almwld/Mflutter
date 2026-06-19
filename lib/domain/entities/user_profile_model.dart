/// =============================================================================
/// UserProfile - ملف المستخدم
/// =============================================================================

class UserProfile {
  final String id;
  final String name;
  final String? email;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    required this.createdAt,
    required this.preferences,
    required this.stats,
  });

  /// الوصف
  String get description =>
      'الاسم: $name\n'
      'البريد: ${email ?? 'غير محدد'}\n'
      'تاريخ التسجيل: ${createdAt.toLocal()}';
}

/// =============================================================================
/// UserPreferences - تفضيلات المستخدم
/// =============================================================================

class UserPreferences {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final String fontSize;
  final bool autoPlayAudio;

  const UserPreferences({
    this.isDarkMode = false,
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.fontSize = 'medium',
    this.autoPlayAudio = false,
  });

  /// الوصف
  String get description =>
      'الوضع: ${isDarkMode ? 'داكن' : 'فاتح'}\n'
      'اللغة: $language\n'
      'الإشعارات: ${notificationsEnabled ? 'مُفعَّلة' : 'مُعطَّلة'}';
}

/// =============================================================================
/// UserStats - إحصائيات المستخدم
/// =============================================================================

class UserStats {
  final int totalSearches;
  final int totalChats;
  final int totalAbjadCalculations;
  final int versesRead;
  final int sciencesExplored;
  final int divineNamesStudied;
  final DateTime lastActive;

  const UserStats({
    this.totalSearches = 0,
    this.totalChats = 0,
    this.totalAbjadCalculations = 0,
    this.versesRead = 0,
    this.sciencesExplored = 0,
    this.divineNamesStudied = 0,
    required this.lastActive,
  });

  /// الوصف
  String get description =>
      'عمليات البحث: $totalSearches\n'
      'المحادثات: $totalChats\n'
      'حسابات الجمل: $totalAbjadCalculations';
}

/// =============================================================================
/// SearchHistory - سجل البحث
/// =============================================================================

class SearchHistory {
  final String query;
  final DateTime searchedAt;
  final int resultCount;

  const SearchHistory({
    required this.query,
    required this.searchedAt,
    required this.resultCount,
  });

  /// الوصف
  String get description =>
      'البحث: $query\n'
      'النتائج: $resultCount\n'
      'التاريخ: ${searchedAt.toLocal()}';
}

/// =============================================================================
/// Bookmark - علامة مرجعية
/// =============================================================================

class Bookmark {
  final String id;
  final String type;
  final int referenceId;
  final String? note;
  final DateTime createdAt;
  final List<String> tags;

  const Bookmark({
    required this.id,
    required this.type,
    required this.referenceId,
    this.note,
    required this.createdAt,
    this.tags = const [],
  });

  /// الوصف
  String get description =>
      'النوع: $type\n'
      'المرجع: $referenceId\n'
      'الملاحظة: ${note ?? 'لا توجد'}';
}