import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/providers/agent_chat_provider.dart';

void main() {
  group('explicit Quran verse references', () {
    test('parses surah:ayah and surah/ayah forms', () {
      expect(
        AgentChatProvider.parseVerseReference('2:255'),
        (surah: 2, ayah: 255),
      );
      expect(
        AgentChatProvider.parseVerseReference(' 18 / 10 '),
        (surah: 18, ayah: 10),
      );
    });

    test('parses Arabic-Indic and Persian digits used in Arabic input', () {
      expect(
        AgentChatProvider.parseVerseReference('٢:٢٥٥'),
        (surah: 2, ayah: 255),
      );
      expect(
        AgentChatProvider.parseVerseReference('۱۸/۱۰'),
        (surah: 18, ayah: 10),
      );
    });

    test('preserves numeric values so the local index can report range errors', () {
      expect(
        AgentChatProvider.parseVerseReference('115:1'),
        (surah: 115, ayah: 1),
      );
      expect(
        AgentChatProvider.parseVerseReference('2:0'),
        (surah: 2, ayah: 0),
      );
    });

    test('does not treat prose or malformed references as direct lookups', () {
      for (final query in <String>[
        '',
        '2',
        '2:255:1',
        'surah 2 ayah 255',
        '2 /',
        'abc:123',
      ]) {
        expect(
          AgentChatProvider.parseVerseReference(query),
          isNull,
          reason: query,
        );
      }
    });
  });
}
