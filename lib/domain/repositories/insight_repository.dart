import '../entities/insight.dart';

abstract class InsightRepository {
  Future<List<Insight>> getDailyInsights();
  Future<List<Insight>> getInsightsByCategory(InsightCategory category);
  Future<Insight> getRandomInsight();
  Future<List<Insight>> searchInsights(String query);
  Future<void> markAsRead(String insightId);
  Future<int> getUnreadCount();
}