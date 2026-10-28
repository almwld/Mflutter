import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/home_screen.dart';

void main() {
  testWidgets('More screen exposes previously orphaned screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));

    const labels = <String>[
      'القرآن التفاعلي',
      'علامات المصحف',
      'فهرس السور',
      'صفحة المصحف',
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

    // Filtering a lazy list can preserve an offset beyond the restored
    // content's extent. Scroll to the expected item instead of assuming one
    // drag is sufficient to reset the scroll position.
    final firstTool = find.text('القرآن التفاعلي');
    await tester.scrollUntilVisible(
      firstTool,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(firstTool, findsOneWidget);
  });
}
