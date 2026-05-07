import '../entities/user_profile_model.dart';

abstract class SettingsRepository {
  Future<UserProfile> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<List<String>> getRecentSearches();
  Future<void> addRecentSearch(String query);
  Future<void> clearRecentSearches();
  Future<Map<String, dynamic>> getStatistics();
}