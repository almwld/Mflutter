import 'package:flutter/foundation.dart' show FlutterError;

import 'external_asset_service.dart';

/// Validates optional vision models imported into app-private storage.
/// Large model files are intentionally not bundled in the APK.
class VisionAssetService {
  const VisionAssetService._();

  static const faceLandmarkerAsset = 'assets/face_landmarker.task';
  static const gazeModelAsset = 'assets/models/gaze_fp16.tflite';

  static Future<Map<String, int>> validate() async {
    final result = <String, int>{};
    final missing = <String>[];
    for (final path in [faceLandmarkerAsset, gazeModelAsset]) {
      try {
        final data = await ExternalAssetService.instance.loadBytes(path);
        if (data.lengthInBytes == 0) {
          throw StateError('ملف النموذج فارغ: $path');
        }
        result[path] = data.lengthInBytes;
      } on FlutterError {
        missing.add(path);
      }
    }
    if (missing.isNotEmpty) {
      throw StateError(
        'ملفات الرؤية غير مستوردة: ${missing.join(', ')}. '
        'افتح مساحة الوكلاء > استيراد أصول OCR/ML Kit واختر الملفات المحلية.',
      );
    }
    return result;
  }
}
