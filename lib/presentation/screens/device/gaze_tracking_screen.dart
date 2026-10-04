import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../services/gaze_tracking_service.dart';
import '../../../services/gaze_model_service.dart';
import '../../../services/vision_asset_service.dart';
import '../../../services/gaze_fusion_service.dart';

class GazeTrackingScreen extends StatefulWidget {
  const GazeTrackingScreen({super.key});
  @override
  State<GazeTrackingScreen> createState() => _GazeTrackingScreenState();
}

class _GazeTrackingScreenState extends State<GazeTrackingScreen> {
  CameraController? _controller;
  final _gaze = GazeTrackingService.instance;
  final _fusion = GazeFusionService.instance;
  GazeEstimate? _estimate;
  bool _busy = false;
  bool _modelReady = false;
  String? _modelError;
  bool _calibrating = false;
  int _calibrationIndex = 0;
  final List<GazeCalibrationSample> _calibrationSamples = [];
  final List<Offset> _targets = const [
    Offset(0.10, 0.10), Offset(0.50, 0.10), Offset(0.90, 0.10),
    Offset(0.10, 0.50), Offset(0.50, 0.50), Offset(0.90, 0.50),
    Offset(0.10, 0.90), Offset(0.50, 0.90), Offset(0.90, 0.90),
  ];
  Timer? _calibrationTimer;
  DateTime? _targetStartedAt;

  @override
  void initState() {
    super.initState();
    _prepareModels();
    _fusion.load();
    _init();
  }

  Future<void> _prepareModels() async {
    try {
      await VisionAssetService.validate();
      await GazeModelService.instance.load();
      if (mounted) setState(() => _modelReady = true);
    } catch (error) {
      if (mounted) setState(() => _modelError = error.toString());
    }
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await controller.initialize();
    await controller.startImageStream((image) async {
      if (_busy || !mounted) return;
      _busy = true;
      try {
        final input = _inputImage(image, camera, controller);
        if (input != null) {
          final result = await _gaze.process(input, image, camera);
          if (result != null && mounted) {
            setState(() => _estimate = result);
            _collectCalibrationSample(result);
          }
        }
      } finally {
        _busy = false;
      }
    });
    if (mounted) setState(() => _controller = controller);
  }

  InputImage? _inputImage(CameraImage image, CameraDescription camera, CameraController controller) {
    final orientations = <DeviceOrientation,int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    var compensation = orientations[controller.value.deviceOrientation];
    if (compensation == null) return null;
    final sensor = camera.sensorOrientation;
    if (Platform.isAndroid && camera.lensDirection == CameraLensDirection.front) {
      compensation = (sensor + compensation) % 360;
    } else if (Platform.isAndroid) {
      compensation = (sensor - compensation + 360) % 360;
    }
    final rotation = InputImageRotationValue.fromRawValue(compensation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _collectCalibrationSample(GazeEstimate e) {
    if (!_calibrating || !e.faceDetected || e.confidence <= 0) return;
    final started = _targetStartedAt;
    if (started == null || DateTime.now().difference(started) < const Duration(milliseconds: 700)) return;
    final target = _targets[_calibrationIndex];
    _calibrationSamples.add(GazeCalibrationSample(
      yawDegrees: e.yawDegrees,
      pitchDegrees: e.pitchDegrees,
      targetX: target.dx,
      targetY: target.dy,
    ));
    if (_calibrationSamples.length % 12 == 0) {
      final samplesForTarget = _calibrationSamples.where((s) => s.targetX == target.dx && s.targetY == target.dy).length;
      if (samplesForTarget >= 12) _advanceCalibration();
    }
  }

  void _startCalibration() {
    if (_calibrating) return;
    setState(() {
      _calibrating = true;
      _calibrationIndex = 0;
      _calibrationSamples.clear();
      _targetStartedAt = DateTime.now();
    });
    _calibrationTimer?.cancel();
    _calibrationTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted && _calibrating) setState(() {});
    });
  }

  Future<void> _advanceCalibration() async {
    if (!_calibrating) return;
    if (_calibrationIndex >= _targets.length - 1) {
      final samples = List<GazeCalibrationSample>.from(_calibrationSamples);
      try {
        await _fusion.fit(samples: samples);
        if (mounted) {
          _calibrationTimer?.cancel();
          setState(() => _calibrating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ معايرة النظر بنجاح')),
          );
        }
      } catch (error) {
        if (mounted) {
          _calibrationTimer?.cancel();
          setState(() => _calibrating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر إكمال المعايرة: $error')),
          );
        }
      }
      return;
    }
    if (mounted) {
      setState(() {
        _calibrationIndex++;
        _targetStartedAt = DateTime.now();
      });
    }
  }

  String _gazeText(GazeEstimate e, BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final point = _fusion.map(
      yawDegrees: e.yawDegrees,
      pitchDegrees: e.pitchDegrees,
      width: size.width,
      height: size.height,
      confidence: e.confidence,
    );
    return 'Yaw: ${e.yawDegrees.toStringAsFixed(1)}°  Pitch: ${e.pitchDegrees.toStringAsFixed(1)}°\n'
        'النقطة: (${point.x.toStringAsFixed(0)}, ${point.y.toStringAsFixed(0)})\n'
        'الثقة: ${(point.confidence * 100).round()}%';
  }

  double get _calibrationProgress {
    final started = _targetStartedAt;
    if (!_calibrating || started == null) return 0;
    return (DateTime.now().difference(started).inMilliseconds / 700.0).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _calibrationTimer?.cancel();
    _controller?.dispose();
    _gaze.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final e = _estimate;
    return Scaffold(
      appBar: AppBar(title: const Text('تتبّع النظر الحقيقي')),
      body: c == null || !c.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Positioned.fill(child: CameraPreview(c)),
              if (_calibrating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _CalibrationTargetPainter(
                        target: _targets[_calibrationIndex],
                        progress: _calibrationProgress,
                      ),
                    ),
                  ),
                ),
              if (!_calibrating)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 92,
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: _modelReady ? _startCalibration : null,
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text('معايرة تتبع النظر'),
                    ),
                  ),
                ),
              Positioned(
                left: 16, right: 16, bottom: 24,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      e == null ? (_modelError != null ? 'تعذر تحميل نموذج النظر: $_modelError' : (_modelReady ? 'جارٍ تحليل الوجه…' : 'جارٍ تجهيز نماذج الرؤية…')) :
                      e.faceDetected
                          ? _gazeText(e, context)
                          : 'لم يتم اكتشاف وجه',
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
            ]),
    );
  }
}


class _CalibrationTargetPainter extends CustomPainter {
  const _CalibrationTargetPainter({required this.target, required this.progress});
  final Offset target;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(target.dx * size.width, target.dy * size.height);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawCircle(center, 24, paint);
    canvas.drawCircle(center, 8, Paint()..style = PaintingStyle.fill);
    if (progress < 1) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 32),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalibrationTargetPainter oldDelegate) =>
      oldDelegate.target != target || oldDelegate.progress != progress;
}
