import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/local_gguf_runtime_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GGUF runtime never claims inference before a successful model load', () async {
    final runtime = LocalGgufRuntimeService.instance;
    expect(runtime.isLoaded, isFalse);
    await expectLater(
      runtime.generateGroundedAnswer(
        question: 'اختبار',
        evidence: 'مصدر محلي تجريبي',
      ),
      throwsA(isA<StateError>()),
    );
  });
}
