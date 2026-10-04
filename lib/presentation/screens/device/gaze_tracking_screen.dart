import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../services/gaze_tracking_service.dart';

class GazeTrackingScreen extends StatefulWidget {
  const GazeTrackingScreen({super.key});
  @override
  State<GazeTrackingScreen> createState() => _GazeTrackingScreenState();
}

class _GazeTrackingScreenState extends State<GazeTrackingScreen> {
  CameraController? _controller;
  final _gaze = GazeTrackingService.instance;
  GazeEstimate? _estimate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
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
          final result = await _gaze.process(input);
          if (result != null && mounted) setState(() => _estimate = result);
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

  @override
  void dispose() {
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
              Positioned(
                left: 16, right: 16, bottom: 24,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      e == null ? 'جارٍ تحليل الوجه…' :
                      e.faceDetected
                          ? 'الاتجاه الأفقي: ${e.horizontal.toStringAsFixed(2)}\nالاتجاه العمودي: ${e.vertical.toStringAsFixed(2)}\nالثقة: ${(e.confidence*100).round()}%'
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
