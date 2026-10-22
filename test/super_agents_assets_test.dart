import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/services/agent_memory_service.dart';
import 'package:mudabbir_al_asrar/services/agent_registry.dart';
import 'package:mudabbir_al_asrar/services/agent_knowledge_service.dart';
import 'package:mudabbir_al_asrar/services/local_gguf_runtime_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Zion-style orchestration roles are registered', () {
    final ids = AgentRegistry.all.map((agent) => agent.id).toSet();
    expect(ids, containsAll(<String>[
      'planner',
      'researcher',
      'retriever',
      'overthinker',
      'loop_engineering',
      'critic',
      'verifier',
      'memory',
      'obsidian',
      'safety',
    ]));
  });

  test('bundled agent knowledge asset declares source-grounding rules', () async {
    final raw = await rootBundle.loadString('assets/agent_knowledge.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    expect(data['mode'], 'offline_first');
    expect(data['sources'], isA<List<dynamic>>());
    expect((data['operating_rules'] as List).join(' '), contains('لا تخترع آية'));
  });

  test('Arabic knowledge normalization removes diacritics consistently', () {
    expect(
      AgentKnowledgeService.normalize('إِنَّ الْقُرْآنَ'),
      AgentKnowledgeService.normalize('ان القران'),
    );
  });

  test('Obsidian-style vault persists and verifies readback locally', () async {
    SharedPreferences.setMockInitialValues({});
    final vault = AgentMemoryService.instance;
    final result = await vault.saveVaultNote(
      title: 'اختبار الوكلاء',
      content: 'هذه ملاحظة اختبار محفوظة محليًا مع مصدر واضح.',
      sources: const ['assets/agent_knowledge.json'],
    );
    expect(result['saved'], isTrue);
    expect(result['readBack'], isTrue);
    final matches = await vault.searchVault('اختبار الوكلاء');
    expect(matches, hasLength(1));
    expect(matches.single['sources'], contains('assets/agent_knowledge.json'));
  });

  test('GGUF runtime never claims inference before a successful model load', () async {
    final runtime = LocalGgufRuntimeService.instance;
    expect(runtime.isLoaded, isFalse);
    await expectLater(
      runtime.generateGroundedAnswer(
        question: 'اختبار',
        evidence: 'مصدر محلي تجريبي',
      ),
      throwsA(isA<StateError>()),
    );
  });
}
