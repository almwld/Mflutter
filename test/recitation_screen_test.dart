import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/recitation_screen.dart';

void main() {
  testWidgets('recitation screen exposes all Quran surahs and explains streaming', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecitationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('التلاوة الصوتية'), findsOneWidget);
    expect(find.text('تلاوة مشاري العفاسي'), findsOneWidget);
    expect(find.text('المصدر الصوتي: EveryAyah.com'), findsOneWidget);
    expect(find.textContaining('يلزم اتصال بالإنترنت'), findsOneWidget);

    for (final name in ['الفاتحة', 'البقرة', 'الإخلاص', 'الفلق', 'الناس']) {
      final item = find.text(name);
      await tester.scrollUntilVisible(
        item,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(item, findsOneWidget, reason: 'Missing recitation entry: $name');
    }
  });
}
