import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/agent_knowledge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concurrent knowledge initialization builds one canonical Quran corpus', () async {
    final service = AgentKnowledgeService.instance;
    await Future.wait<void>([
      service.initialize(),
      service.initialize(),
      service.initialize(),
    ]);

    expect(service.loadedSources, contains('assets/quran_full.json'));
    expect(service.documentCount, greaterThanOrEqualTo(6236));

    final matches = await service.search('بسم الله الرحمن الرحيم', limit: 3);
    expect(matches, isNotEmpty);
    expect(
      matches.any((document) => document.source == 'assets/quran_full.json'),
      isTrue,
    );
  });
}
