import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/widgets/quran_text_shimmer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('keeps the original Quran text and respects reduced motion',
      (tester) async {
    const verse = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuranTextShimmer(
                baseColor: Color(0xFFFFECB3),
                child: Text(verse),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text(verse), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders with automatic animation enabled', (tester) async {
    const verse = 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: QuranTextShimmer(
              baseColor: Color(0xFFFFECB3),
              child: Text(verse),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text(verse), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
