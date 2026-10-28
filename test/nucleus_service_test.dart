import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/agent_registry.dart';
import 'package:mudabbir_al_asrar/services/nucleus_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('agent registry identifiers are unique and stable', () {
    final ids = AgentRegistry.all.map((agent) => agent.id).toList();
    expect(ids, isNotEmpty);
    expect(ids.toSet().length, ids.length);
    expect(AgentRegistry.byId('muwajjih'), isNotNull);
    expect(AgentRegistry.byId('tafsir'), isNotNull);
  });

  test('visual scalar is clamped and rejects non-finite values', () {
    final core = NucleusService();
    core.setVisualEnergy(1.4);
    expect(core.visualEnergy, 1.0);
    core.setVisualEnergy(-0.3);
    expect(core.visualEnergy, 0.0);
    expect(() => core.setVisualEnergy(double.nan), throwsArgumentError);
  });

  test('Quran context validates and retains selected verse', () {
    final core = NucleusService();
    core.setQuranContext(surahNumber: 12, ayahNumber: 4, verseText: 'إذ قال يوسف لأبيه');
    expect(core.currentSurahNumber, 12);
    expect(core.currentAyahNumber, 4);
    expect(core.currentVerseText, 'إذ قال يوسف لأبيه');
    expect(() => core.setQuranContext(surahNumber: 115, ayahNumber: 1), throwsArgumentError);
  });

  test('nucleus data is immutable to consumers', () {
    final data = NucleusService().getNucleusData();
    expect(() => data['name'] = 'changed', throwsUnsupportedError);
  });
}
