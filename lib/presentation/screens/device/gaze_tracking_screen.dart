import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:face_detection_tflite/face_detection_tflite.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/gaze_fusion_service.dart';

class GazeTrackingScreen extends StatefulWidget {
  const GazeTrackingScreen({super.key});

  @override
  State<GazeTrackingScreen> createState() => _GazeTrackingScreenState();
}

class _GazeTrackingScreenState extends State<GazeTrackingScreen>
    with WidgetsBindingObserver {
  static const _targets = <Offset>[
    Offset(.15, .22), Offset(.5, .22), Offset(.85, .22),
    Offset(.15, .5), Offset(.5, .5), Offset(.85, .5),
    Offset(.15, .78), Offset(.5, .78), Offset(.85, .78),
  ];

  final _fusion = GazeFusionService.instance;
  final _dwell = GazeDwellController();
  final _samples = <GazeCalibrationSample>[];
  CameraController? _camera;
  FaceDetector? _detector;
  StreamSubscription<AccelerometerEvent>? _accelerometer;
  StreamSubscription<GyroscopeEvent>? _gyroscope;
  Size _viewSize = Size.zero;
  GazeScreenPoint? _point;
  double? _yaw;
  double? _pitch;
  double _tiltX = 0;
  double _tiltY = 0;
  double _motion = 0;
  int _generation = 0;
  int _targetIndex = 0;
  bool _loading = true;
  bool _tracking = true;
  bool _processing = false;
  bool _calibrating = false;
  bool _dwellNoticeShown = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _accelerometer = accelerometerEvents.listen((e) {
      final magnitude = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (magnitude > .1) {
        _tiltX = (e.y / magnitude).clamp(-1.0, 1.0).toDouble();
        _tiltY = (e.x / magnitude).clamp(-1.0, 1.0).toDouble();
      }
    }, onError: (_) {});
    _gyroscope = gyroscopeEvents.listen((e) {
      _motion = (math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z).clamp(0.0, 5.0) / 5.0).toDouble();
    }, onError: (_) {});
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _generation++;
      unawaited(_releaseCamera());
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final generation = ++_generation;
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      await _releaseCamera();
      if (!mounted || generation != _generation) return;
      await _fusion.load();
      final detector = await FaceDetector.create(model: FaceDetectionModel.frontCamera);
      final cameras = await availableCameras();
      final front = cameras.where((c) => c.lensDirection == CameraLensDirection.front);
      final info = front.isNotEmpty ? front.first : (cameras.isEmpty ? null : cameras.first);
      if (info == null) throw StateError('لم يتم العثور على كاميرا.');
      final camera = CameraController(
        info,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await camera.initialize();
      if (!mounted || generation != _generation) {
        await camera.dispose();
        await detector.dispose();
        return;
      }
      _camera = camera;
      _detector = detector;
      setState(() => _loading = false);
      if (_tracking) await _startStream();
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() { _loading = false; _error = 'تعذر تهيئة تتبع النظر المحلي: $error'; });
      }
    }
  }

  Future<void> _startStream() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || camera.value.isStreamingImages) return;
    try {
      await camera.startImageStream((image) => unawaited(_processFrame(image)));
    } catch (error) {
      if (mounted) setState(() => _error = 'تعذر تشغيل بث الكاميرا: $error');
    }
  }

  Future<void> _stopStream() async {
    final camera = _camera;
    if (camera != null && camera.value.isStreamingImages) {
      try { await camera.stopImageStream(); } catch (_) {}
    }
  }

  Future<void> _releaseCamera() async {
    await _stopStream();
    final camera = _camera;
    final detector = _detector;
    _camera = null;
    _detector = null;
    // Releasing one native resource must not prevent releasing the other or
    // leak an asynchronous exception during lifecycle changes/dispose.
    try {
      await camera?.dispose();
    } catch (error) {
      debugPrint('Could not dispose gaze camera: $error');
    }
    try {
      await detector?.dispose();
    } catch (error) {
      debugPrint('Could not dispose gaze detector: $error');
    }
  }

  double? _eyeRatio(Eye? eye, bool horizontal) {
    if (eye == null || eye.contour.length < 3) return null;
    final xs = eye.contour.map((p) => p.x).toList();
    final ys = eye.contour.map((p) => p.y).toList();
    final minValue = horizontal ? xs.reduce((a, b) => a < b ? a : b) : ys.reduce((a, b) => a < b ? a : b);
    final maxValue = horizontal ? xs.reduce((a, b) => a > b ? a : b) : ys.reduce((a, b) => a > b ? a : b);
    final extent = maxValue - minValue;
    if (extent < 1 || !extent.isFinite) return null;
    final iris = horizontal ? eye.irisCenter.x : eye.irisCenter.y;
    return ((iris - minValue) / extent).clamp(0.0, 1.0).toDouble();
  }

  double? _eyeOpenness(Eye? eye) {
    if (eye == null || eye.contour.length < 6) return null;
    final xs = eye.contour.map((point) => point.x).toList();
    final ys = eye.contour.map((point) => point.y).toList();
    final width = xs.reduce((a, b) => a > b ? a : b) -
        xs.reduce((a, b) => a < b ? a : b);
    final height = ys.reduce((a, b) => a > b ? a : b) -
        ys.reduce((a, b) => a < b ? a : b);
    if (!width.isFinite || !height.isFinite || width < 2 || height < 1) {
      return null;
    }
    final ratio = height / width;
    return ratio.isFinite ? ratio : null;
  }

  void _rejectFrame() {
    if (mounted && _point != null) setState(() => _point = null);
    _dwell.reset();
    _dwellNoticeShown = false;
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_processing || !_tracking || !mounted || _detector == null) return;
    if (_viewSize.isEmpty) {
      _rejectFrame();
      return;
    }
    _processing = true;
    try {
      final faces = await _detector!.detectFacesFromCameraImage(
        image, mode: FaceDetectionMode.full, maxDim: 640,
      );
      if (!mounted) return;
      if (faces.isEmpty) {
        _rejectFrame();
        return;
      }
      final eyes = faces.first.eyes;
      final leftEye = eyes?.leftEye;
      final rightEye = eyes?.rightEye;
      final leftX = _eyeRatio(leftEye, true);
      final rightX = _eyeRatio(rightEye, true);
      final leftY = _eyeRatio(leftEye, false);
      final rightY = _eyeRatio(rightEye, false);
      final leftOpenness = _eyeOpenness(leftEye);
      final rightOpenness = _eyeOpenness(rightEye);

      if (leftX == null || rightX == null || leftY == null || rightY == null ||
          leftOpenness == null || rightOpenness == null ||
          leftOpenness < .07 || rightOpenness < .07) {
        _rejectFrame();
        return;
      }

      final eyeX = 1 - (leftX + rightX) / 2;
      final eyeY = (leftY + rightY) / 2;
      final opennessQuality =
          (math.min(leftOpenness, rightOpenness) / .22).clamp(0.0, 1.0);
      final symmetryError = (leftX - rightX).abs() + (leftY - rightY).abs();
      final symmetryQuality = (1.0 - symmetryError / 1.1).clamp(0.0, 1.0);
      final motionQuality = (1.0 - _motion * .7).clamp(.2, 1.0);
      final quality = (opennessQuality * symmetryQuality * motionQuality)
          .clamp(0.0, 1.0)
          .toDouble();
      if (quality < .45) {
        _rejectFrame();
        return;
      }

      // This remains a geometric estimate, not trained L2CS inference.
      final yaw = (eyeX - .5) * 120 + _tiltX * 8;
      final pitch = (.5 - eyeY) * 100 + _tiltY * 8;
      _yaw = yaw;
      _pitch = pitch;
      final point = _fusion.map(
        yawDegrees: yaw,
        pitchDegrees: pitch,
        width: _viewSize.width,
        height: _viewSize.height,
        confidence: quality,
      );
      final event = _dwell.update(x: point.x, y: point.y, confidence: point.confidence);
      if (event.intent == GazeIntent.dwellActivated && !_dwellNoticeShown) {
        _dwellNoticeShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تثبيت النظر على الهدف التجريبي.')),
            );
          }
        });
      }
      if (point.x < _viewSize.width * .3 || point.x > _viewSize.width * .7 ||
          point.y < _viewSize.height * .3 || point.y > _viewSize.height * .7) {
        _dwellNoticeShown = false;
      }
      setState(() => _point = point);
    } catch (error) {
      _rejectFrame();
      if (mounted) setState(() => _error = 'تعذر تحليل إطار الكاميرا: $error');
    } finally {
      _processing = false;
    }
  }

  Future<void> _captureTarget() async {
    if (_yaw == null || _pitch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ضع وجهك أمام الكاميرا وانتظر اكتشاف العينين.')),
      );
      return;
    }
    final target = _targets[_targetIndex];
    _samples.add(GazeCalibrationSample(
      yawDegrees: _yaw!, pitchDegrees: _pitch!,
      targetX: target.dx, targetY: target.dy,
    ));
    if (_targetIndex < _targets.length - 1) {
      setState(() => _targetIndex++);
      return;
    }
    try {
      await _fusion.fit(samples: List<GazeCalibrationSample>.unmodifiable(_samples));
      if (!mounted) return;
      setState(() { _calibrating = false; _targetIndex = 0; _samples.clear(); _point = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتملت المعايرة وحُفظت محلياً.')),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذرت المعايرة: $error')),
      );
    }
  }

  Future<void> _toggleTracking() async {
    if (_tracking) {
      setState(() { _tracking = false; _point = null; });
      await _stopStream();
    } else {
      setState(() => _tracking = true);
      await _startStream();
    }
  }

  String get _direction {
    final p = _point;
    if (p == null || _viewSize.isEmpty) return 'لم يُكتشف النظر بعد';
    final x = p.x / _viewSize.width, y = p.y / _viewSize.height;
    if (x < .35) return 'النظر إلى اليسار';
    if (x > .65) return 'النظر إلى اليمين';
    if (y < .35) return 'النظر إلى الأعلى';
    if (y > .65) return 'النظر إلى الأسفل';
    return 'النظر إلى المركز';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelerometer?.cancel();
    _gyroscope?.cancel();
    unawaited(_releaseCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GazeFusion — تتبع النظر'),
        actions: [
          IconButton(
            tooltip: 'إعادة ضبط المعايرة',
            onPressed: () async { await _fusion.clear(); if (mounted) setState(() => _point = null); },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.visibility_off_rounded, size: 44),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _initialize, child: const Text('إعادة المحاولة')),
                  ]),
                ))
              : LayoutBuilder(builder: (context, constraints) {
                  _viewSize = Size(constraints.maxWidth, constraints.maxHeight);
                  final camera = _camera;
                  return Stack(fit: StackFit.expand, children: [
                    if (camera != null && camera.value.isInitialized)
                      Center(child: AspectRatio(
                        aspectRatio: camera.value.aspectRatio,
                        child: CameraPreview(camera),
                      )),
                    Positioned(left: 12, right: 12, top: 12, child: Card(
                      color: AppColors.primaryNavy.withOpacity(.88),
                      child: Padding(padding: const EdgeInsets.all(12), child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_direction, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_fusion.isCalibrated ? 'المعايرة: مكتملة' : 'المعايرة: افتراضية — نفّذ معايرة 9 نقاط',
                            textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(_tracking ? 'المعالجة محلية • لا تُحفظ الصور ولا تُرفع' : 'التتبع متوقف',
                            textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(
                            _point == null
                                ? 'جودة التتبع: لا توجد قراءة موثوقة'
                                : 'جودة التتبع التقديرية: ${(_point!.confidence * 100).round()}% • تقدير هندسي وليس احتمال نموذج مدرّب',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      )),
                    )),
                    if (_calibrating)
                      Positioned(
                        left: _targets[_targetIndex].dx * constraints.maxWidth - 22,
                        top: _targets[_targetIndex].dy * constraints.maxHeight - 22,
                        child: const Icon(Icons.gps_fixed_rounded, size: 44, color: Colors.amber),
                      )
                    else if (_tracking && _point != null)
                      Positioned(
                        left: (_point!.x - 14).clamp(0.0, constraints.maxWidth - 28).toDouble(),
                        top: (_point!.y - 14).clamp(0.0, constraints.maxHeight - 28).toDouble(),
                        child: Container(width: 28, height: 28, decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 3),
                          color: Colors.amber.withOpacity(.25),
                        )),
                      ),
                    Positioned(left: 12, right: 12, bottom: 12, child: Column(children: [
                      if (_calibrating)
                        FilledButton.icon(
                          onPressed: _captureTarget,
                          icon: const Icon(Icons.center_focus_strong_rounded),
                          label: Text('ثبّت النظر على النقطة ' + (_targetIndex + 1).toString() + '/9 ثم اضغط'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: () => setState(() { _calibrating = true; _targetIndex = 0; _samples.clear(); }),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('معايرة النظر (9 نقاط)'),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _toggleTracking,
                        icon: Icon(_tracking ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(_tracking ? 'إيقاف التتبع مؤقتاً' : 'استئناف التتبع'),
                      ),
                    ])),
                  ]);
                }),
    );
  }
}
