import '../../domain/entities/insight.dart';
import '../../domain/repositories/insight_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class InsightRepositoryImpl implements InsightRepository {
  final SettingsLocalDatasource localDatasource;

  InsightRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Insight>> getDailyInsights() async {
    return await localDatasource.getDailyInsights();
  }

  @override
  Future<List<Insight>> getInsightsByCategory(InsightCategory category) async {
    return await localDatasource.getInsightsByCategory(category);
  }

  @override
  Future<Insight> getRandomInsight() async {
    return await localDatasource.getRandomInsight();
  }

  @override
  Future<List<Insight>> searchInsights(String query) async {
    return await localDatasource.searchInsights(query);
  }

  @override
  Future<void> markAsRead(String insightId) async {
    await localDatasource.markInsightAsRead(insightId);
  }

  @override
  Future<int> getUnreadCount() async {
    return await localDatasource.getUnreadInsightCount();
  }
}