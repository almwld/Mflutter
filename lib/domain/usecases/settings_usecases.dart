import '../entities/user_profile_model.dart';
import '../repositories/settings_repository.dart';

class GetUserProfileUseCase {
  final SettingsRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile> call() async {
    return await repository.getUserProfile();
  }
}

class SaveUserProfileUseCase {
  final SettingsRepository repository;

  SaveUserProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    await repository.saveUserProfile(profile);
  }
}

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<AppSettings> call() async {
    return await repository.getSettings();
  }
}

class SaveSettingsUseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase(this.repository);

  Future<void> call(AppSettings settings) async {
    await repository.saveSettings(settings);
  }
}

class GetRecentSearchesUseCase {
  final SettingsRepository repository;

  GetRecentSearchesUseCase(this.repository);

  Future<List<String>> call() async {
    return await repository.getRecentSearches();
  }
}

class AddRecentSearchUseCase {
  final SettingsRepository repository;

  AddRecentSearchUseCase(this.repository);

  Future<void> call(String query) async {
    await repository.addRecentSearch(query);
  }
}

class GetStatisticsUseCase {
  final SettingsRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getStatistics();
  }
}