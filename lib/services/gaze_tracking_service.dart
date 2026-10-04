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
    this.yawDegrees = 0,
    this.pitchDegrees = 0,
  });
  final double horizontal;
  final double vertical;
  final double confidence;
  final bool faceDetected;
  final double yawDegrees;
  final double pitchDegrees;
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
        confidence: angles.confidence,
        faceDetected: true,
        yawDegrees: angles.yaw,
        pitchDegrees: angles.pitch,
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
      final plane = image.planes.first;
      final bytes = plane.bytes;
      final out = List<int>.filled(image.width * image.height * 3, 0);
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final s = y * plane.bytesPerRow + x * 4;
          final d = (y * image.width + x) * 3;
          if (s + 3 >= bytes.length) continue;
          out[d] = bytes[s + 2];
          out[d + 1] = bytes[s + 1];
          out[d + 2] = bytes[s];
        }
      }
      return out;
    }
    if (image.planes.isEmpty) throw StateError('YUV frame planes غير صالحة.');
    final out = List<int>.filled(image.width * image.height * 3, 0);
    final isNv21 = image.format.group == ImageFormatGroup.nv21 ||
        (image.planes.length == 1 && image.planes.first.bytes.length >= image.width * image.height * 3 ~/ 2);
    if (isNv21) {
      final bytes = image.planes.first.bytes;
      final ySize = image.width * image.height;
      final uvStart = ySize;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final yp = y * image.width + x;
          final uv = uvStart + (y >> 1) * image.width + (x & ~1);
          if (yp >= bytes.length || uv + 1 >= bytes.length) continue;
          final yy = bytes[yp] - 16;
          final v = bytes[uv] - 128;
          final u = bytes[uv + 1] - 128;
          _writeRgb(out, (y * image.width + x) * 3, yy, u, v);
        }
      }
      return out;
    }
    if (image.planes.length < 3) {
      throw StateError('YUV420 يتطلب ثلاث planes أو NV21.');
    }
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final yp = y * yPlane.bytesPerRow + x * yPlane.bytesPerPixel;
        final up = (y >> 1) * uPlane.bytesPerRow + (x >> 1) * uPlane.bytesPerPixel;
        final vp = (y >> 1) * vPlane.bytesPerRow + (x >> 1) * vPlane.bytesPerPixel;
        if (yp >= yPlane.bytes.length || up >= uPlane.bytes.length || vp >= vPlane.bytes.length) continue;
        final yy = yPlane.bytes[yp] - 16;
        final u = uPlane.bytes[up] - 128;
        final v = vPlane.bytes[vp] - 128;
        _writeRgb(out, (y * image.width + x) * 3, yy, u, v);
      }
    }
    return out;
  }

  void _writeRgb(List<int> out, int d, int yy, int u, int v) {
    out[d] = (1.164 * yy + 1.596 * v).round().clamp(0, 255);
    out[d + 1] = (1.164 * yy - 0.392 * u - 0.813 * v).round().clamp(0, 255);
    out[d + 2] = (1.164 * yy + 2.017 * u).round().clamp(0, 255);
  }

  Future<void> dispose() => _detector.close();
}
