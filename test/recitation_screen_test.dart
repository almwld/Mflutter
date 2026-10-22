import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/recitation_screen.dart';

void main() {
  testWidgets('recitation screen exposes all Quran surahs and explains streaming', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecitationScreen()));

    // QuranLoaderService reads the bundled JSON asynchronously. Let that
    // asset I/O finish outside the widget test's fake async clock; then pump
    // the resulting setState without waiting for the indeterminate spinner.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('التلاوة الصوتية'), findsOneWidget);
    expect(find.text('تلاوة مشاري العفاسي'), findsOneWidget);
    expect(find.text('المصدر الصوتي: EveryAyah.com'), findsOneWidget);
    expect(find.textContaining('يلزم اتصال بالإنترنت'), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets,
        reason: 'The local surah index should finish loading into a scrollable list.');

    for (final name in ['الفاتحة', 'البقرة', 'الإخلاص', 'الفلق', 'الناس']) {
      final item = find.text(name);
      await tester.scrollUntilVisible(
        item,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(item, findsOneWidget, reason: 'Missing recitation entry: $name');
    }
  });
}
