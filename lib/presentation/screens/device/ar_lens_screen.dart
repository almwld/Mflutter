import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ARLensScreen extends StatefulWidget {
  const ARLensScreen({super.key});

  @override
  State<ARLensScreen> createState() => _ARLensScreenState();
}

class _ARLensScreenState extends State<ARLensScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  int _generation = 0;
  bool _loading = true;
  bool _flashOn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _generation++;
      final oldController = _controller;
      _controller = null;
      oldController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final generation = ++_generation;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'لم يتم العثور على كاميرا في هذا الجهاز.',
        );
      }

      final safeIndex = _cameraIndex < cameras.length ? _cameraIndex : 0;
      final controller = CameraController(
        cameras[safeIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }

      _cameras = cameras;
      _cameraIndex = safeIndex;
      _controller = controller;
      setState(() {
        _loading = false;
        _error = null;
      });
    } on CameraException catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = _cameraErrorMessage(e);
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تشغيل الكاميرا. تحقق من أذونات الكاميرا ثم أعد المحاولة.';
      });
    }
  }

  String _cameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
        return 'تم رفض إذن الكاميرا. فعّل إذن الكاميرا من إعدادات التطبيق ثم أعد المحاولة.';
      case 'CameraAccessRestricted':
        return 'الوصول إلى الكاميرا مقيّد على هذا الجهاز.';
      case 'NoCamera':
        return error.description ?? 'لم يتم العثور على كاميرا.';
      default:
        return 'تعذر تشغيل الكاميرا: ${error.description ?? error.code}';
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final currentDirection = _cameras[_cameraIndex].lensDirection;
    final nextIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection != currentDirection,
    );
    _cameraIndex = nextIndex < 0 ? (_cameraIndex + 1) % _cameras.length : nextIndex;
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final enable = !_flashOn;
      await controller.setFlashMode(enable ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = enable);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تغيير الإضاءة: ${e.description ?? e.code}')),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('عدسة التدبر'),
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'إعادة تشغيل الكاميرا',
            onPressed: _initializeCamera,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.black,
                  child: _buildCameraView(controller),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
              child: Column(
                children: [
                  const Text(
                    'وجّه العدسة نحو النص أو الصفحة التي تريد قراءتها',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'معاينة كاميرا مباشرة • لا يتم تحليل الصورة أو حفظها تلقائيًا',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.68),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LensControl(
                        icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        label: 'الإضاءة',
                        onTap: _toggleFlash,
                      ),
                      const SizedBox(width: 18),
                      _LensControl(
                        icon: Icons.cameraswitch_rounded,
                        label: 'تبديل الكاميرا',
                        onTap: _switchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(CameraController? controller) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00BCD4)),
            SizedBox(height: 14),
            Text(
              'جارٍ تهيئة الكاميرا…',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null || controller == null || !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Color(0xFF00BCD4), size: 48),
              const SizedBox(height: 16),
              Text(
                _error ?? 'الكاميرا غير جاهزة.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, height: 1.6),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Container(
              width: 230,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(.9),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  color: Color(0xFF00BCD4),
                  size: 42,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LensControl extends StatelessWidget {
  const _LensControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: AppColors.primaryNavyLight.withOpacity(.8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
