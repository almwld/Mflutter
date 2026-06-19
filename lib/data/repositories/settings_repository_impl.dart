import '../../domain/entities/user_profile_model.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;

  SettingsRepositoryImpl({required this.localDatasource});

  @override
  Future<UserProfile> getUserProfile() async {
    return await localDatasource.getUserProfile();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await localDatasource.saveUserProfile(profile);
  }

  @override
  Future<AppSettings> getSettings() async {
    return await localDatasource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await localDatasource.saveSettings(settings);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return await localDatasource.getRecentSearches();
  }

  @override
  Future<void> addRecentSearch(String query) async {
    await localDatasource.addRecentSearch(query);
  }

  @override
  Future<void> clearRecentSearches() async {
    await localDatasource.clearRecentSearches();
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    return await localDatasource.getStatistics();
  }
}