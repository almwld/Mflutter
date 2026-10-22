import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/external_asset_service.dart';

void main() {
  group('ExternalAssetService destinations', () {
    test('routes Tesseract language data to the external tessdata directory', () {
      expect(
        ExternalAssetService.destinationForFileName('ara.traineddata'),
        'tessdata/ara.traineddata',
      );
    });

    test('routes task and TFLite files outside the APK asset bundle', () {
      expect(
        ExternalAssetService.destinationForFileName('face_landmarker.task'),
        'assets/face_landmarker.task',
      );
      expect(
        ExternalAssetService.destinationForFileName('gaze_fp16.tflite'),
        'assets/models/gaze_fp16.tflite',
      );
    });

    test('routes optional training checkpoint files to the external models directory', () {
      expect(
        ExternalAssetService.destinationForFileName('mudabbir_weights.json'),
        'assets/models/mudabbir_weights.json',
      );
      expect(
        ExternalAssetService.destinationForFileName('training_history.json'),
        'assets/models/training_history.json',
      );
    });
  });
}
