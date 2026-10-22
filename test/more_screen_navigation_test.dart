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
}
