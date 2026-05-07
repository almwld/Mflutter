import '../entities/insight.dart';
import '../repositories/insight_repository.dart';

class GetDailyInsightsUseCase {
  final InsightRepository repository;

  GetDailyInsightsUseCase(this.repository);

  Future<List<Insight>> call() async {
    return await repository.getDailyInsights();
  }
}

class GetInsightsByCategoryUseCase {
  final InsightRepository repository;

  GetInsightsByCategoryUseCase(this.repository);

  Future<List<Insight>> call(InsightCategory category) async {
    return await repository.getInsightsByCategory(category);
  }
}

class GetRandomInsightUseCase {
  final InsightRepository repository;

  GetRandomInsightUseCase(this.repository);

  Future<Insight> call() async {
    return await repository.getRandomInsight();
  }
}

class SearchInsightsUseCase {
  final InsightRepository repository;

  SearchInsightsUseCase(this.repository);

  Future<List<Insight>> call(String query) async {
    return await repository.searchInsights(query);
  }
}

class MarkInsightAsReadUseCase {
  final InsightRepository repository;

  MarkInsightAsReadUseCase(this.repository);

  Future<void> call(String insightId) async {
    await repository.markAsRead(insightId);
  }
}

class GetUnreadCountUseCase {
  final InsightRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<int> call() async {
    return await repository.getUnreadCount();
  }
}