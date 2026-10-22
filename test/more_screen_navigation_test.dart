import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/home_screen.dart';

void main() {
  testWidgets('More screen exposes previously orphaned screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));

    const labels = <String>[
      'القرآن التفاعلي',
      'حاسبة الأبجد',
      'التدريب',
      'الإعجاز',
      'المقارنة',
      'النواة',
      'مركز السيادة',
      'الخدمات الكونية',
      'الذكاء المتقدم',
      'التخصيص المتقدم',
      'الملف الشخصي',
      'مشغل التلاوة',
      'المساعدة',
      'المجتمع',
      'التحديات',
      'لوحة المتصدرين',
      'علم الكواكب',
      'علم الحروف',
    ];

    for (final label in labels) {
      final finder = find.text(label);
      await tester.scrollUntilVisible(
        finder,
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget, reason: 'Missing More entry: $label');
    }
  });

  testWidgets('Arabic search ignores hamza variants and tashkeel', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    final search = find.byType(TextField);

    await tester.enterText(search, 'القران');
    await tester.pumpAndSettle();
    expect(find.text('القرآن التفاعلي'), findsOneWidget);
    expect(find.text('1 نتيجة'), findsOneWidget);

    await tester.enterText(search, 'التَّدريب');
    await tester.pumpAndSettle();
    expect(find.text('التدريب'), findsOneWidget);
    expect(find.text('1 نتيجة'), findsOneWidget);
  });

  testWidgets('More screen search filters tools and can be cleared', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));

    final search = find.byType(TextField);
    expect(search, findsOneWidget);

    await tester.enterText(search, 'التلاوة');
    await tester.pumpAndSettle();
    expect(find.text('مشغل التلاوة'), findsOneWidget);
    expect(find.text('القرآن التفاعلي'), findsNothing);
    expect(find.text('1 نتيجة'), findsOneWidget);

    await tester.enterText(search, 'لا توجد أداة مطابقة');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد واجهة بهذا الاسم'), findsOneWidget);

    await tester.enterText(search, '');
    await tester.pumpAndSettle();
    // The ListView retains its scroll offset while the filtered result list
    // changes. Return to the top before asserting the first lazy-built item.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    expect(find.text('القرآن التفاعلي'), findsOneWidget);
  });
}
