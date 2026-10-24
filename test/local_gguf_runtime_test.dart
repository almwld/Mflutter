import 'dart:typed_data';

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

  group('GGUF header validation', () {
    Uint8List header({
      int version = 3,
      int tensorCount = 1,
      int metadataCount = 1,
    }) {
      final bytes = Uint8List(24);
      bytes.setRange(0, 4, const <int>[0x47, 0x47, 0x55, 0x46]);
      final data = ByteData.sublistView(bytes);
      data.setUint32(4, version, Endian.little);
      data.setUint64(8, tensorCount, Endian.little);
      data.setUint64(16, metadataCount, Endian.little);
      return bytes;
    }

    test('accepts a structurally plausible GGUF v3 header', () {
      final bytes = header();
      expect(
        LocalGgufRuntimeService.isGgufHeaderValid(bytes, 1024 * 1024),
        isTrue,
      );
    });

    test('rejects a truncated fixed header', () {
      expect(
        LocalGgufRuntimeService.isGgufHeaderValid(header().take(8).toList(), 1024 * 1024),
        isFalse,
      );
      expect(
        LocalGgufRuntimeService.isGgufHeaderValid(header(), 23),
        isFalse,
      );
    });

    test('rejects bad magic and unsupported versions', () {
      final badMagic = header();
      badMagic[0] = 0;
      expect(
        LocalGgufRuntimeService.isGgufHeaderValid(badMagic, 1024 * 1024),
        isFalse,
      );
      expect(
        LocalGgufRuntimeService.isGgufHeaderValid(header(version: 1), 1024 * 1024),
        isFalse,
      );
    });

    test('rejects empty or implausible tensor and metadata counts', () {
      for (final bytes in <Uint8List>[
        header(tensorCount: 0),
        header(metadataCount: 0),
        header(tensorCount: 1000001),
        header(metadataCount: 100001),
      ]) {
        expect(
          LocalGgufRuntimeService.isGgufHeaderValid(bytes, 1024 * 1024),
          isFalse,
        );
      }
    });
  });
  group('memory-aware context sizing', () {
    test('uses a conservative context when RAM probing is unavailable', () {
      expect(
        LocalGgufRuntimeService.recommendedContextSize(freeRamBytes: 0),
        1024,
      );
    });

    test('reduces context on constrained devices', () {
      const gib = 1024 * 1024 * 1024;
      expect(
        LocalGgufRuntimeService.recommendedContextSize(
          freeRamBytes: 2 * gib,
          requestedContextSize: 2048,
        ),
        512,
      );
      expect(
        LocalGgufRuntimeService.recommendedContextSize(
          freeRamBytes: 4 * gib,
          requestedContextSize: 2048,
        ),
        1024,
      );
    });

    test('preserves requested context when RAM headroom is high', () {
      const gib = 1024 * 1024 * 1024;
      expect(
        LocalGgufRuntimeService.recommendedContextSize(
          freeRamBytes: 6 * gib,
          requestedContextSize: 3072,
        ),
        3072,
      );
    });

    test('clamps requested context to supported bounds', () {
      const gib = 1024 * 1024 * 1024;
      expect(
        LocalGgufRuntimeService.recommendedContextSize(
          freeRamBytes: 6 * gib,
          requestedContextSize: 100,
        ),
        512,
      );
      expect(
        LocalGgufRuntimeService.recommendedContextSize(
          freeRamBytes: 6 * gib,
          requestedContextSize: 9000,
        ),
        4096,
      );
    });
  });

}
