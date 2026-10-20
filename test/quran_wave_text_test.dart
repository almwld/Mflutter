import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/widgets/quran_wave_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows original Quran words and animates key words',
      (tester) async {
    const verse = 'الله رب العالمين';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: QuranWaveText(
              text: verse,
              style: TextStyle(fontSize: 24, fontFamily: 'Amiri'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('الله'), findsOneWidget);
    expect(find.text('رب'), findsOneWidget);
    expect(find.text('العالمين'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == verse), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
  });

  testWidgets('respects reduced motion without changing words',
      (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    const verse = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const MaterialApp(
          home: Scaffold(
            body: QuranWaveText(
              text: verse,
              style: TextStyle(fontSize: 24, fontFamily: 'Amiri'),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(verse), findsOneWidget);
    expect(find.text('بِسْمِ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
