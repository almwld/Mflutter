import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/templates/components/canvas_block_entrance.dart';

void main() {
  testWidgets('canvas block entrance animates without changing its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CanvasBlockEntrance(child: Text('كتلة العرض')),
      ),
    ));
    expect(find.text('كتلة العرض'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('canvas block entrance respects reduced motion', (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        home: Scaffold(
          body: CanvasBlockEntrance(child: Text('عرض فوري')),
        ),
      ),
    ));
    expect(find.text('عرض فوري'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
