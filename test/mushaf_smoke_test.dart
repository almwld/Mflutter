import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/main.dart';
import 'package:mudabbir_al_asrar/presentation/screens/home_screen.dart';
import 'package:mudabbir_al_asrar/presentation/screens/quran/mushaf_screen.dart';
import 'package:mudabbir_al_asrar/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Mudabbir reaches the canonical Mushaf from the home reading card',
      (tester) async {
    await tester.pumpWidget(const MudabbirApp());
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MushafScreen), findsNothing);

    final readingCard = find.text('المصحف الشريف');
    expect(readingCard, findsOneWidget);
    await tester.ensureVisible(readingCard);
    await tester.tap(readingCard);

    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.byType(MushafScreen), findsOneWidget);
  });
}
