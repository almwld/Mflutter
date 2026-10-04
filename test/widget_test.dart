import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/main.dart';

void main() {
  testWidgets('Mudabbir app boots with the canonical Mushaf screen', (tester) async {
    await tester.pumpWidget(const MudabbirApp());
    await tester.pump();
    expect(find.textContaining('صفحة'), findsWidgets);
  });
}
