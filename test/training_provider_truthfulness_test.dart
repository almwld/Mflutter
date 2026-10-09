import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/providers/training_provider.dart';

void main() {
  test('training request is rejected until a real training runtime exists', () async {
    final provider = TrainingProvider();
    await expectLater(
      provider.trainOnVerses([
        {'text': 'sample verse', 'axis_type': 'cosmic'},
      ], epochs: 1),
      throwsA(isA<UnsupportedError>()),
    );

    expect(provider.isTraining, isFalse);
    expect(provider.status, contains('لم تُغيّر أي أوزان'));
    expect(provider.error, isNotNull);
    provider.dispose();
  });

  test('inference does not run without a verified local model', () async {
    final provider = TrainingProvider();
    await expectLater(
      provider.predict('اختبار'),
      throwsA(isA<StateError>()),
    );
    provider.dispose();
  });
}
