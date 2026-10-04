import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/main.dart';
import 'package:mudabbir_al_asrar/presentation/screens/home_screen.dart';
import 'package:mudabbir_al_asrar/presentation/screens/quran/mushaf_screen.dart';
import 'package:mudabbir_al_asrar/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Mudabbir reaches the canonical Mushaf from the home navigation', (tester) async {
    await tester.pumpWidget(const MudabbirApp());
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MushafScreen), findsNothing);

    await tester.tap(find.text('مصحف'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.byType(MushafScreen), findsOneWidget);
  });
}
