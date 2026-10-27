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

  group('resumable download range validation', () {
    test('parses a valid partial response and total length', () {
      expect(
        LocalGgufRuntimeService.parseContentRange('bytes 194-999/1000'),
        (start: 194, end: 999, total: 1000),
      );
    });

    test('allows an unknown total while retaining the start offset', () {
      expect(
        LocalGgufRuntimeService.parseContentRange('bytes 194-999/*'),
        (start: 194, end: 999, total: null),
      );
    });

    test('rejects malformed or internally inconsistent range headers', () {
      for (final value in <String>[
        'bytes nope-999/1000',
        'bytes 900-899/1000',
        'bytes 900-999/999',
        'items 194-999/1000',
        'bytes 194-999',
      ]) {
        expect(
          LocalGgufRuntimeService.parseContentRange(value),
          isNull,
          reason: value,
        );
      }
    });
  });

  group('generation concurrency guard', () {
    test('allows generation only with a loaded idle controller', () {
      expect(
        LocalGgufRuntimeService.canStartGeneration(
          isLoaded: true,
          hasController: true,
          isBusy: false,
          isGenerating: false,
        ),
        isTrue,
      );
    });

    test('rejects missing model, missing controller, and lifecycle operations', () {
      final cases = <Map<String, bool>>[
        {'isLoaded': false, 'hasController': true, 'isBusy': false, 'isGenerating': false},
        {'isLoaded': true, 'hasController': false, 'isBusy': false, 'isGenerating': false},
        {'isLoaded': true, 'hasController': true, 'isBusy': true, 'isGenerating': false},
        {'isLoaded': true, 'hasController': true, 'isBusy': false, 'isGenerating': true},
        {'isLoaded': true, 'hasController': true, 'isBusy': true, 'isGenerating': true},
      ];
      for (final state in cases) {
        expect(
          LocalGgufRuntimeService.canStartGeneration(
            isLoaded: state['isLoaded']!,
            hasController: state['hasController']!,
            isBusy: state['isBusy']!,
            isGenerating: state['isGenerating']!,
          ),
          isFalse,
          reason: '$state',
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
