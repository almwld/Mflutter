import 'dart:math' as math;
import 'package:camera/camera.dart';
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
  DateTime? _lastInferenceAt;
  static const _inferenceInterval = Duration(milliseconds: 80);

  bool get modelAvailable => _modelAvailable;
  GazeEstimate _last = const GazeEstimate(horizontal: 0, vertical: 0, confidence: 0, faceDetected: false);
  GazeEstimate get last => _last;

  Future<GazeEstimate?> process(
    InputImage image,
    CameraImage frame,
    CameraDescription camera,
  ) async {
    if (_busy) return null;
    final now = DateTime.now();
    if (_lastInferenceAt != null && now.difference(_lastInferenceAt!) < _inferenceInterval) return null;
    _busy = true;
    _lastInferenceAt = now;
    try {
      if (!GazeModelService.instance.isLoaded) {
        await GazeModelService.instance.load();
      }
      _modelAvailable = GazeModelService.instance.isLoaded;
      if (!_modelAvailable) throw StateError('نموذج L2CS غير متاح.');

      final faces = await _detector.processImage(image);
      if (faces.isEmpty) {
        _last = const GazeEstimate(horizontal: 0, vertical: 0, confidence: 0, faceDetected: false);
        return _last;
      }

      final face = faces.first;
      final rawBox = _mapBoxToRaw(face.boundingBox, frame.width, frame.height, image.metadata.rotation);
      final rgb = _cameraImageToRgb(frame);
      final angles = GazeModelService.instance.inferRgb(
        rgb: rgb,
        width: frame.width,
        height: frame.height,
        left: rawBox.left.floor(),
        top: rawBox.top.floor(),
        right: rawBox.right.ceil(),
        bottom: rawBox.bottom.ceil(),
      );

      _last = GazeEstimate(
        horizontal: (angles.yaw / 180.0).clamp(-1.0, 1.0),
        vertical: (angles.pitch / 180.0).clamp(-1.0, 1.0),
        confidence: 1.0,
        faceDetected: true,
      );
      return _last;
    } finally {
      _busy = false;
    }
  }

  math.Rectangle<double> _mapBoxToRaw(
    math.Rectangle<double> box,
    int rawWidth,
    int rawHeight,
    InputImageRotation rotation,
  ) {
    final points = <math.Point<double>>[
      math.Point(box.left, box.top),
      math.Point(box.right, box.top),
      math.Point(box.left, box.bottom),
      math.Point(box.right, box.bottom),
    ];
    final mapped = points.map((p) {
      switch (rotation) {
        case InputImageRotation.rotation90deg:
          return math.Point(rawWidth - p.y, p.x);
        case InputImageRotation.rotation180deg:
          return math.Point(rawWidth - p.x, rawHeight - p.y);
        case InputImageRotation.rotation270deg:
          return math.Point(p.y, rawHeight - p.x);
        case InputImageRotation.rotation0deg:
          return p;
      }
    }).toList();
    final xs = mapped.map((p) => p.x);
    final ys = mapped.map((p) => p.y);
    return math.Rectangle(
      xs.reduce(math.min).clamp(0, rawWidth - 1),
      ys.reduce(math.min).clamp(0, rawHeight - 1),
      (xs.reduce(math.max) - xs.reduce(math.min)).clamp(1, rawWidth.toDouble()),
      (ys.reduce(math.max) - ys.reduce(math.min)).clamp(1, rawHeight.toDouble()),
    );
  }

  List<int> _cameraImageToRgb(CameraImage image) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      final bytes = image.planes.first.bytes;
      final out = List<int>.filled(image.width * image.height * 3, 0);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final s = y * image.planes.first.bytesPerRow + x * 4;
          final d = (y * image.width + x) * 3;
          out[d] = bytes[s + 2];
          out[d + 1] = bytes[s + 1];
          out[d + 2] = bytes[s];
        }
      }
      return out;
    }
    if (image.planes.isEmpty) throw StateError('YUV frame planes غير صالحة.');
    final yPlane = image.planes[0];
    final yBytes = yPlane.bytes;
    final uvPlane = image.planes.length >= 2 ? image.planes[1] : image.planes[0];
    final uvBytes = uvPlane.bytes;
    final isNv21 = image.planes.length == 1;
    final out = List<int>.filled(image.width * image.height * 3, 0);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final yp = y * yPlane.bytesPerRow + x;
        final uvRow = (y >> 1) * uvPlane.bytesPerRow;
        final uvCol = (x >> 1) * 2;
        final up = isNv21 ? uvRow + uvCol : uvRow + uvCol;
        final first = uvBytes[up] - 128;
        final second = uvBytes[up + 1] - 128;
        final u = (isNv21 ? second : first);
        final v = (isNv21 ? first : second);
        final yy = yBytes[yp] - 16;
        final r = (1.164 * yy + 1.596 * v).round().clamp(0, 255);
        final g = (1.164 * yy - 0.392 * u - 0.813 * v).round().clamp(0, 255);
        final b = (1.164 * yy + 2.017 * u).round().clamp(0, 255);
        final d = (y * image.width + x) * 3;
        out[d] = r; out[d + 1] = g; out[d + 2] = b;
      }
    }
    return out;
  }

  Future<void> dispose() => _detector.close();
}
