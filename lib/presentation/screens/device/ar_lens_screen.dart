import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/smart_lens_service.dart';

enum _LensMode { text, quran, objects }

class ARLensScreen extends StatefulWidget {
  const ARLensScreen({super.key});

  @override
  State<ARLensScreen> createState() => _ARLensScreenState();
}

class _ARLensScreenState extends State<ARLensScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  int _generation = 0;
  bool _loading = true;
  bool _flashOn = false;
  bool _processing = false;
  String? _error;
  String? _capturedPath;
  String? _recognizedText;
  String? _translatedText;
  String? _analysisError;
  List<QuranLensMatch> _matches = const [];
  List<ObjectLensLabel> _labels = const [];
  _LensMode _mode = _LensMode.text;

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
      final old = _controller;
      _controller = null;
      old?.dispose();
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
        throw CameraException('NoCamera', 'لم يتم العثور على كاميرا في هذا الجهاز.');
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
      setState(() => _loading = false);
    } on CameraException catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = _cameraErrorMessage(e);
      });
    } catch (_) {
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
        return 'تم رفض إذن الكاميرا. فعّل الإذن من إعدادات التطبيق ثم أعد المحاولة.';
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
    final direction = _cameras[_cameraIndex].lensDirection;
    final next = _cameras.indexWhere((camera) => camera.lensDirection != direction);
    _cameraIndex = next < 0 ? (_cameraIndex + 1) % _cameras.length : next;
    _capturedPath = null;
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final enabled = !_flashOn;
      await controller.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = enabled);
    } catch (e) {
      _notify('تعذر تغيير الإضاءة: $e');
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectMode(_LensMode mode) {
    setState(() {
      _mode = mode;
      _recognizedText = null;
      _translatedText = null;
      _analysisError = null;
      _matches = const [];
      _labels = const [];
    });
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _processing) return;
    setState(() {
      _processing = true;
      _analysisError = null;
      _recognizedText = null;
      _translatedText = null;
      _matches = const [];
      _labels = const [];
    });
    try {
      final photo = await controller.takePicture();
      if (!mounted) return;
      setState(() => _capturedPath = photo.path);
      final lens = SmartLensService.instance;
      if (_mode == _LensMode.objects) {
        final labels = await lens.analyzeObjects(photo.path);
        if (!mounted) return;
        setState(() => _labels = labels);
        if (labels.isEmpty) {
          setState(() => _analysisError = 'لم يتعرف النموذج على عناصر واضحة. جرّب إضاءة أفضل وصورة أقرب.');
        }
      } else {
        final text = await lens.extractArabicText(photo.path);
        if (!mounted) return;
        setState(() => _recognizedText = text);
        if (text.trim().isEmpty) {
          setState(() => _analysisError = 'لم أستطع استخراج نص واضح. قرّب الكاميرا وثبّت الصورة ثم أعد المحاولة.');
        } else if (_mode == _LensMode.quran) {
          final matches = await lens.matchQuranText(text);
          if (!mounted) return;
          setState(() => _matches = matches);
          if (matches.isEmpty) {
            setState(() => _analysisError = 'لم أعثر على تطابق موثوق كفاية في نص المصحف المحلي. لا تعتمد على التخمين؛ أعد التصوير بوضوح أكبر.');
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analysisError = e.toString().contains('ara.traineddata') ||
                e.toString().contains('SocketException') ||
                e.toString().contains('HTTP')
            ? 'يلزم تنزيل نموذج التعرف العربي لأول مرة. اتصل بالإنترنت ثم أعد المحاولة؛ بعد تنزيله يعمل OCR محليًا.'
            : 'تعذر تحليل الصورة: $e';
      });
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _retake() {
    setState(() {
      _capturedPath = null;
      _recognizedText = null;
      _translatedText = null;
      _analysisError = null;
      _matches = const [];
      _labels = const [];
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('العدسة الذكية'),
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'إعادة تهيئة الكاميرا',
            onPressed: _initializeCamera,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: _buildCameraView(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                children: [
                  const Text(
                    'اختر ما تريد أن تحلله',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _modeChip(_LensMode.text, 'النصوص', Icons.text_fields_rounded),
                      _modeChip(_LensMode.quran, 'القرآن', Icons.menu_book_rounded),
                      _modeChip(
                        _LensMode.objects,
                        'الأشياء (غير مفعّل)',
                        Icons.center_focus_strong_rounded,
                        enabled: false,
                      ),
                    ],
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
                      const SizedBox(width: 8),
                      _LensControl(
                        icon: Icons.cameraswitch_rounded,
                        label: 'تبديل',
                        onTap: _switchCamera,
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _processing ? null : _captureAndAnalyze,
                        icon: Icon(_mode == _LensMode.objects ? Icons.search_rounded : Icons.document_scanner_rounded),
                        label: Text(_mode == _LensMode.objects ? 'حلّل الصورة' : 'التقط وحلّل'),
                      ),
                    ],
                  ),
                  if (_capturedPath != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _retake,
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('التقاط صورة أخرى'),
                      ),
                    ),
                  ],
                  if (_processing) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(color: Color(0xFF00BCD4)),
                    const SizedBox(height: 6),
                    const Text(
                      'تجري المعالجة محليًا على الجهاز…',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                  if (_recognizedText != null) _buildTextResult(theme),
                  if (_translatedText != null) _buildInfoCard('الترجمة الإنجليزية', _translatedText!, Icons.translate_rounded),
                  if (_mode == _LensMode.text && (_recognizedText?.isNotEmpty ?? false))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'الترجمة الآلية غير مفعّلة؛ لن ينزّل التطبيق نموذجًا تلقائيًا.',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  if (_mode == _LensMode.quran && _matches.isNotEmpty) _buildQuranMatches(theme),
                  if (_mode == _LensMode.objects && _labels.isNotEmpty) _buildObjectLabels(theme),
                  if (_analysisError != null) _buildInfoCard('ملاحظة', _analysisError!, Icons.info_outline_rounded),
                  const SizedBox(height: 6),
                  const Text(
                    'الخصوصية: لا تُرفع الصورة إلى خادم. يتطلب OCR العربي استيراد ara.traineddata يدويًا؛ لا ينزّل التطبيق نماذج تلقائيًا، والترجمة وتحليل الأشياء غير مفعّلين حاليًا.',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(
    _LensMode mode,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    final selected = _mode == mode;
    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : const Color(0xFF00BCD4)),
      label: Text(label),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      selectedColor: const Color(0xFF00838F),
      backgroundColor: const Color(0xFF12352E),
      side: BorderSide(color: selected ? const Color(0xFF00BCD4) : Colors.white24),
      onSelected: enabled ? (_) => _selectMode(mode) : null,
    );
  }

  Widget _buildCameraView() {
    final controller = _controller;
    if (_capturedPath != null) {
      return Image.file(File(_capturedPath!), fit: BoxFit.contain);
    }
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00BCD4)),
            SizedBox(height: 12),
            Text('جارٍ تهيئة الكاميرا…', style: TextStyle(color: Colors.white)),
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
              const Icon(Icons.no_photography_outlined, color: Color(0xFF00BCD4), size: 44),
              const SizedBox(height: 12),
              Text(_error ?? 'الكاميرا غير جاهزة.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, height: 1.5)),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: _initializeCamera, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
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
              width: 240,
              height: 154,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(.9), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(Icons.center_focus_strong_rounded, color: Color(0xFF00BCD4), size: 42)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextResult(ThemeData theme) {
    return Card(
      color: const Color(0xFF12352E),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('النص المستخرج', textDirection: TextDirection.rtl, style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(
              _recognizedText ?? '',
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.8),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                tooltip: 'نسخ النص',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _recognizedText ?? ''));
                  _notify('تم نسخ النص المستخرج.');
                },
                icon: const Icon(Icons.content_copy_rounded, color: Color(0xFF00BCD4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranMatches(ThemeData theme) {
    return Card(
      color: const Color(0xFF12352E),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('أقرب مطابقات من المصحف المعتمد', textDirection: TextDirection.rtl, style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('هذه مطابقة آلية تقريبية وليست تصحيحًا معتمدًا للتلاوة أو للنص.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white60, fontSize: 11)),
            for (final match in _matches)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(match.reference, textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFF80CBC4), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    SelectableText(match.canonicalText, textDirection: TextDirection.rtl, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.8)),
                    Text('درجة التشابه: ${(match.score * 100).round()}%', textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectLabels(ThemeData theme) {
    return Card(
      color: const Color(0xFF12352E),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('العناصر التي تعرّف عليها النموذج', textDirection: TextDirection.rtl, style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
            for (final label in _labels)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(label.label, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white))),
                    Text('${(label.confidence * 100).round()}%', style: const TextStyle(color: Color(0xFF80CBC4))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String message, IconData icon) {
    return Card(
      color: const Color(0xFF12352E),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF00BCD4)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  SelectableText(message, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LensControl extends StatelessWidget {
  const _LensControl({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: AppColors.primaryNavyLight.withOpacity(.8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    ),
  );
}
