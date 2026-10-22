import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/recitation_screen.dart';

void main() {
  testWidgets('recitation screen explains online streaming and lists selected surahs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecitationScreen()));

    expect(find.text('التلاوة الصوتية'), findsOneWidget);
    expect(find.text('تلاوة مشاري العفاسي'), findsOneWidget);
    expect(find.text('المصدر الصوتي: EveryAyah.com'), findsOneWidget);
    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.text('البقرة'), findsOneWidget);
    expect(find.text('الإخلاص'), findsOneWidget);
    expect(find.text('الفلق'), findsOneWidget);
    expect(find.text('الناس'), findsOneWidget);
    expect(find.textContaining('يلزم اتصال بالإنترنت'), findsOneWidget);
  });
}
