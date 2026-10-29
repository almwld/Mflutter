import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/screens/home_screen.dart';

void main() {
  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('More screen exposes previously orphaned screens', (tester) async {
    await useTallViewport(tester);
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
      expect(finder, findsOneWidget, reason: 'Missing More entry: $label');
    }
  });

  testWidgets('Arabic search ignores hamza variants and tashkeel', (tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));
    final search = find.byType(TextField);

    await tester.enterText(search, 'القران');
    await tester.pumpAndSettle();
    expect(find.text('القرآن التفاعلي'), findsOneWidget);
    // The broad Quran query also matches the Quran font-variants screen.
    expect(find.text('2 نتيجة'), findsOneWidget);

    await tester.enterText(search, 'التَّدريب');
    await tester.pumpAndSettle();
    expect(find.text('التدريب'), findsOneWidget);
    expect(find.text('1 نتيجة'), findsOneWidget);
  });

  testWidgets('More screen search filters tools and can be cleared', (tester) async {
    await useTallViewport(tester);
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

    expect(find.text('القرآن التفاعلي'), findsOneWidget);
  });
}
