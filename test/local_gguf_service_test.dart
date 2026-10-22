import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/local_gguf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local GGUF generation fails closed until a model is loaded', () {
    final service = LocalGgufService.instance;
    expect(
      () => service.generateChat(
        systemPrompt: 'system',
        userPrompt: 'hello',
      ),
      throwsStateError,
    );
  });

  test('GGUF import is explicitly Android-only', () async {
    if (Platform.isAndroid) return;
    await expectLater(
      LocalGgufService.instance.importModel('/missing/model.gguf'),
      throwsUnsupportedError,
    );
  });
}
