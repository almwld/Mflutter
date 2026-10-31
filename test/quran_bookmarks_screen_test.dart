import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/presentation/screens/quran_bookmarks_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Quran bookmarks route uses the shared saved-verse store', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(home: QuranBookmarksScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('علامات المصحف'), findsOneWidget);
    expect(find.text('لا توجد آيات محفوظة بعد'), findsOneWidget);
  });
}
