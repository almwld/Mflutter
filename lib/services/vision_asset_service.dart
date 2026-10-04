import 'package:flutter/services.dart';

/// Validates that the vision model assets are present in the Flutter bundle.
/// It does not copy or modify model files.
class VisionAssetService {
  const VisionAssetService._();

  static const faceLandmarkerAsset = 'assets/face_landmarker.task';
  static const gazeModelAsset = 'assets/models/gaze_fp16.tflite';

  static Future<Map<String, int>> validate() async {
    final result = <String, int>{};
    for (final path in [faceLandmarkerAsset, gazeModelAsset]) {
      final data = await rootBundle.load(path);
      if (data.lengthInBytes == 0) {
        throw StateError('ملف النموذج فارغ: $path');
      }
      result[path] = data.lengthInBytes;
    }
    return result;
  }
}
