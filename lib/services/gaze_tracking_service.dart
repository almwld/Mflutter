import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'gaze_model_service.dart';

class GazeEstimate {
  const GazeEstimate({
    required this.horizontal,
    required this.vertical,
    required this.confidence,
    required this.faceDetected,
  });
  final double horizontal;
  final double vertical;
  final double confidence;
  final bool faceDetected;
}

class GazeTrackingService {
  GazeTrackingService._();
  static final instance = GazeTrackingService._();

  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableTracking: true,
    ),
  );

  bool _busy = false;
  bool _modelAvailable = false;

  bool get modelAvailable => _modelAvailable;
  GazeEstimate _last = const GazeEstimate(horizontal: 0, vertical: 0, confidence: 0, faceDetected: false);
  GazeEstimate get last => _last;

  Future<GazeEstimate?> process(InputImage image) async {
    if (_busy) return null;
    _busy = true;
    try {
      if (!GazeModelService.instance.isLoaded) {
        await GazeModelService.instance.load();
      }
      _modelAvailable = GazeModelService.instance.isLoaded;
      if (!_modelAvailable) {
        throw StateError('نموذج L2CS غير متاح.');
      }
      final faces = await _detector.processImage(image);
      if (faces.isEmpty) {
        _last = const GazeEstimate(horizontal: 0, vertical: 0, confidence: 0, faceDetected: false);
        return _last;
      }
      final face = faces.first;
      final box = face.boundingBox;
      // L2CS inference is intentionally not replaced by head/eye heuristics.
      // The current service still receives InputImage only; until the camera RGB
      // frame is available here, fail explicitly instead of publishing fake gaze.
      throw StateError(
        'إطار RGB الخام مطلوب لتشغيل L2CS بعد قص الوجه؛ لا يتم استخدام تقدير بديل وهمي.',
      );

      }
      final eyeX = (left.x + right.x) / 2.0;
      final eyeY = (left.y + right.y) / 2.0;
      final cx = box.center.dx;
      final cy = box.center.dy;
      final horizontal = ((eyeX - cx) / (box.width * 0.25)).clamp(-1.0, 1.0);
      final vertical = ((eyeY - cy) / (box.height * 0.25)).clamp(-1.0, 1.0);
      final headX = ((face.headEulerAngleY ?? 0) / 45.0).clamp(-1.0, 1.0);
      final headY = ((face.headEulerAngleX ?? 0) / 30.0).clamp(-1.0, 1.0);
      _last = GazeEstimate(
        horizontal: (horizontal * 0.7 + headX * 0.3).clamp(-1.0, 1.0),
        vertical: (vertical * 0.7 + headY * 0.3).clamp(-1.0, 1.0),
        confidence: 0.75,
        faceDetected: true,
      );
      return _last;
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() => _detector.close();
}
