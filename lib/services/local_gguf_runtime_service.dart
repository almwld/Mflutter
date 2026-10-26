import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';

/// Private-storage GGUF lifecycle and llama.cpp runtime for Android.
///
/// An imported file is not treated as a loaded model until its GGUF
/// header is checked and llama.cpp successfully loads it.
class LocalGgufRuntimeService extends ChangeNotifier {
  LocalGgufRuntimeService._();
  static final LocalGgufRuntimeService instance = LocalGgufRuntimeService._();

  static const _minimumGgufBytes = 1024 * 1024;
  static const recommendedModelFileName = '3arabLM-4B-islamic-v2.Q4_K_M.gguf';
  static const recommendedModelUrl =
      'https://huggingface.co/mradermacher/3arabLM-4B-islamic-v2-GGUF/resolve/main/3arabLM-4B-islamic-v2.Q4_K_M.gguf';

  LlamaController? _controller;
  String _status = 'لم يتم تثبيت نموذج GGUF محلي';
  bool _busy = false;
  bool _generating = false;
  bool _loaded = false;
  String? _loadedPath;
  bool _downloading = false;
  bool _downloadCancelled = false;
  HttpClient? _downloadClient;

  String get status => _status;
  bool get isBusy => _busy;
  bool get isGenerating => _generating;
  bool get isLoaded => _loaded;
  String? get loadedPath => _loadedPath;
  bool get isDownloading => _downloading;

  bool get isDownloading => _downloading;

  /// Downloads the recommended GGUF into app-private storage. Interrupted
  /// downloads remain as .part files and resume with an HTTP Range request.
  Future<File> downloadRecommendedModel({
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    _ensureAndroid();
    if (_busy || _generating || _loaded) {
      throw StateError('أوقف العملية الحالية وأفرغ النموذج قبل التنزيل.');
    }
    _busy = true;
    _downloading = true;
    _downloadCancelled = false;
    _status = 'جارٍ تجهيز تنزيل النموذج المحلي...';
    notifyListeners();

    HttpClient? client;
    try {
      final directory = await _modelDirectory();
      final target = File('${directory.path}/$recommendedModelFileName');
      final partial = File('${target.path}.part');

      if (await target.exists()) {
        if (await _isValidGguf(target)) {
          await _selectModel(recommendedModelFileName);
          _status = 'النموذج موجود مسبقًا وتم تحديده: $recommendedModelFileName';
          return target;
        }
        await target.delete();
      }

      client = HttpClient()..connectionTimeout = const Duration(seconds: 45);
      _downloadClient = client;
      var retryFromStart = false;

      while (true) {
        if (_downloadCancelled) throw StateError('أُلغي تنزيل النموذج.');
        var offset = await partial.exists() ? await partial.length() : 0;
        final request = await client.getUrl(Uri.parse(recommendedModelUrl));
        request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        if (offset > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
        }

        final response = await request.close().timeout(const Duration(seconds: 90));
        if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable &&
            offset > 0 && !retryFromStart) {
          await response.drain<void>();
          if (await partial.exists()) await partial.delete();
          retryFromStart = true;
          continue;
        }
        if (response.statusCode != HttpStatus.ok &&
            response.statusCode != HttpStatus.partialContent) {
          final status = response.statusCode;
          await response.drain<void>();
          throw HttpException('خادم النموذج أعاد HTTP $status.', uri: Uri.parse(recommendedModelUrl));
        }

        int? expectedTotal;
        final append = response.statusCode == HttpStatus.partialContent;
        if (append) {
          final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
          final match = contentRange == null
              ? null
              : RegExp(r'^bytes (\d+)-(\d+)/(\d+|\*)$').firstMatch(contentRange);
          if (offset == 0 || match == null || int.tryParse(match.group(1)!) != offset) {
            await response.drain<void>();
            throw HttpException('استجابة الاستئناف لا تطابق حجم الملف الجزئي؛ بقي الملف الجزئي محفوظًا.');
          }
          if (match.group(3) != '*') expectedTotal = int.tryParse(match.group(3)!);
        } else {
          // If the server ignores Range, truncate and restart instead of
          // appending a second copy of the complete model.
          offset = 0;
          if (response.contentLength >= 0) expectedTotal = response.contentLength;
        }

        final output = await partial.open(mode: append ? FileMode.append : FileMode.writeOnly);
        var received = offset;
        var lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
        try {
          await for (final chunk in response) {
            if (_downloadCancelled) throw StateError('أُلغي تنزيل النموذج.');
            await output.writeFrom(chunk);
            received += chunk.length;
            final now = DateTime.now();
            if (now.difference(lastUpdate) >= const Duration(milliseconds: 500)) {
              lastUpdate = now;
              onProgress?.call(received, expectedTotal);
              _status = expectedTotal == null
                  ? 'جارٍ تنزيل النموذج: ${(received / (1024 * 1024)).toStringAsFixed(1)} MiB'
                  : 'جارٍ تنزيل النموذج: ${(received / (1024 * 1024)).toStringAsFixed(1)} / ${(expectedTotal / (1024 * 1024)).toStringAsFixed(1)} MiB';
              notifyListeners();
            }
          }
          await output.flush();
        } finally {
          await output.close();
        }

        if (_downloadCancelled) throw StateError('أُلغي تنزيل النموذج.');
        final actualLength = await partial.length();
        onProgress?.call(actualLength, expectedTotal);
        if (expectedTotal != null && actualLength != expectedTotal) {
          throw HttpException(
            'التنزيل غير مكتمل: وصل $actualLength بايت من أصل $expectedTotal. أعد المحاولة لاستكماله.',
          );
        }
        if (!await _isValidGguf(partial)) {
          throw const FormatException(
            'انتهى التنزيل لكن ترويسة GGUF غير صالحة؛ لم يتم تفعيل الملف كنموذج.',
          );
        }

        if (await target.exists()) await target.delete();
        await partial.rename(target.path);
        await _selectModel(recommendedModelFileName);
        _status = 'اكتمل تنزيل النموذج والتحقق الأولي منه. حمّله لاختبار التوافق الفعلي مع llama.cpp.';
        return target;
      }
    } catch (error) {
      _status = _downloadCancelled
          ? 'أُوقف التنزيل؛ حُفظ الجزء المكتمل لاستئنافه لاحقًا.'
          : 'تعذر تنزيل النموذج: $error';
      rethrow;
    } finally {
      client?.close(force: _downloadCancelled);
      _downloadClient = null;
      _downloading = false;
      _busy = false;
      notifyListeners();
    }
  }

  /// Stops the network transfer without deleting the resumable partial file.
  void cancelDownload() {
    if (!_downloading) return;
    _downloadCancelled = true;
    _downloadClient?.close(force: true);
  }


  Future<Directory> _modelDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/mudabbir_models');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<File> modelFile() async {
    final directory = await _modelDirectory();
    final marker = File('${directory.path}/selected-model.txt');
    if (!await marker.exists()) {
      throw StateError('لم يتم استيراد نموذج GGUF من ذاكرة الهاتف.');
    }

    final selected = (await marker.readAsString()).trim();
    if (!selected.toLowerCase().endsWith('.gguf') ||
        selected.contains('/') ||
        selected.contains(String.fromCharCode(92)) ||
        selected == '.' ||
        selected == '..') {
      throw StateError('اسم ملف النموذج المحلي المحدد غير صالح.');
    }

    final file = File('${directory.path}/$selected');
    if (!await file.exists()) {
      throw StateError('ملف النموذج المستورد غير موجود؛ أعد استيراده من ذاكرة الهاتف.');
    }
    return file;
  }

  Future<void> _selectModel(String fileName) async {
    final directory = await _modelDirectory();
    await File('${directory.path}/selected-model.txt')
        .writeAsString(fileName, flush: true);
  }

  /// Checks the selected imported file's header. Native model loading remains
  /// the final compatibility check and is the only point that enables inference.
  Future<bool> hasValidModel() async {
    try {
      return await _isValidGguf(await modelFile());
    } catch (_) {
      return false;
    }
  }

  Future<File> importModel(String sourcePath) async {
    _ensureAndroid();
    if (_busy || _generating || _loaded) {
      throw StateError('أوقف التوليد وأفرغ النموذج قبل استبدال ملف GGUF.');
    }
    _busy = true;
    _status = 'جارٍ فحص ملف GGUF المستورد...';
    notifyListeners();
    try {
      final source = File(sourcePath);
      final sourceName = source.uri.pathSegments.isEmpty
          ? ''
          : source.uri.pathSegments.last;
      if (!sourceName.toLowerCase().endsWith('.gguf') ||
          sourceName == '.' ||
          sourceName == '..' ||
          sourceName.contains('/') ||
          sourceName.contains(String.fromCharCode(92))) {
        throw const FormatException('اختر ملفًا بامتداد .gguf من الهاتف.');
      }
      if (!await _isValidGguf(source)) {
        throw const FormatException(
          'الملف ليس GGUF صالحًا أو أنه غير مكتمل (الترويسة/الحجم غير صالحين).',
        );
      }
      final directory = await _modelDirectory();
      final target = File('${directory.path}/$sourceName');
      if (source.absolute.path == target.absolute.path) {
        await _selectModel(sourceName);
        _status = 'النموذج المحدد موجود بالفعل في مساحة التطبيق: $sourceName';
        return target;
      }
      final temp = File('${target.path}.importing');
      if (await temp.exists()) await temp.delete();
      await source.openRead().pipe(temp.openWrite());
      if (!await _isValidGguf(temp)) {
        await temp.delete();
        throw const FormatException('فشل التحقق من نسخة GGUF بعد الاستيراد.');
      }
      if (await target.exists()) await target.delete();
      await temp.rename(target.path);
      await _selectModel(sourceName);
      _status = 'تم استيراد النموذج $sourceName إلى مساحة التطبيق الخاصة.';
      return target;
    } catch (error) {
      _status = 'فشل استيراد النموذج: $error';
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> loadModel({int threads = 4, int contextSize = 2048}) async {
    _ensureAndroid();
    if (_busy || _generating) throw StateError('أوقف العملية الحالية قبل تحميل النموذج.');
    _busy = true;
    _status = 'جارٍ تحميل النموذج داخل llama.cpp...';
    notifyListeners();
    try {
      final file = await modelFile();
      if (!await _isValidGguf(file)) {
        throw StateError('لم يُعثر على ملف GGUF صالح في مساحة التطبيق. استورد نموذجًا من الهاتف أولًا.');
      }
      final previousController = _controller;
      _controller = null;
      _loaded = false;
      _loadedPath = null;
      try {
        await previousController?.dispose();
      } catch (_) {
        // Continue with a fresh controller; the old native instance is no
        // longer exposed to chat even if its cleanup reports an error.
      }
      final controller = LlamaController();
      // A quantized 4B model can still exhaust RAM even when its GGUF header
      // is valid. Probe available memory first and reduce KV-cache context on
      // constrained phones. If probing is unavailable, use a conservative
      // context rather than assuming the device has enough free memory.
      var effectiveContextSize = recommendedContextSize(
        freeRamBytes: 0,
        requestedContextSize: contextSize,
      );
      try {
        try {
          final gpuInfo = await controller.detectGpu();
          effectiveContextSize = recommendedContextSize(
            freeRamBytes: gpuInfo.freeRamBytes,
            requestedContextSize: contextSize,
          );
        } catch (_) {
          // Some devices/builds cannot report GPU/RAM details. CPU loading
          // remains available with the conservative fallback context.
        }
        await controller.loadModel(
          modelPath: file.path,
          threads: threads.clamp(1, 8).toInt(),
          contextSize: effectiveContextSize,
          gpuLayers: 0,
        );
      } catch (_) {
        // A failed native load can still allocate partial native resources.
        try {
          await controller.dispose();
        } catch (_) {}
        rethrow;
      }
      _controller = controller;
      _loadedPath = file.path;
      _loaded = true;
      _status = 'تم تحميل النموذج محليًا؛ الاستدلال يعمل على الجهاز دون خادم. سياق الذاكرة: $effectiveContextSize رمز (تقدير RAM تقريبي).';
    } catch (error) {
      _status = 'فشل تحميل GGUF في محرك الاستدلال: $error';
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<String> generateGroundedAnswer({
    required String question,
    required String evidence,
    int maxTokens = 512,
  }) async {
    final controller = _controller;
    if (!_loaded || controller == null) {
      throw StateError('لا يوجد نموذج GGUF محمّل؛ لم يُنفّذ استدلال توليدي.');
    }
    final prompt = 'أنت مساعد عربي يعمل محليًا داخل تطبيق مُدَبِّر. '
        'أجب باللغة العربية. استخدم الأدلة المرفقة فقط للادعاءات المتعلقة بالقرآن. '
        'لا تخترع آيات أو مراجع أو أسماء مصادر. إذا لم تكف الأدلة فصرّح بذلك. '
        'ميّز بين نص المصدر والاستنتاج المولّد.\n\n'
        'السؤال: $question\n\nالأدلة المحلية:\n$evidence';
    final buffer = StringBuffer();
    _generating = true;
    _status = 'جارٍ التوليد محليًا...';
    notifyListeners();
    try {
      await for (final token in controller.generateChat(
        messages: [
          ChatMessage(role: 'system', content: 'مساعد عربي حذر، يذكر حدود الأدلة ولا يختلق المراجع.'),
          ChatMessage(role: 'user', content: prompt),
        ],
        template: 'chatml',
        maxTokens: maxTokens.clamp(32, 1024).toInt(),
        temperature: 0.25,
        topP: 0.9,
      ).timeout(const Duration(seconds: 120))) {
        buffer.write(token);
      }
      final answer = buffer.toString().trim();
      if (answer.isEmpty) throw StateError('أعاد النموذج إجابة فارغة.');
      _status = 'اكتمل الاستدلال المحلي.';
      return answer;
    } catch (error) {
      _status = 'فشل الاستدلال المحلي: $error';
      rethrow;
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  Future<void> stopGeneration() async {
    await _controller?.stop();
  }

  Future<void> unloadModel() async {
    if (_busy || _generating) {
      throw StateError('أوقف العملية الحالية قبل تحرير النموذج.');
    }
    final controller = _controller;
    _controller = null;
    _loaded = false;
    _loadedPath = null;
    try {
      if (controller != null) await controller.dispose();
      _status = 'تم إيقاف النموذج وتحرير موارده.';
    } catch (error) {
      _status = 'تم فصل النموذج عن الواجهة، لكن تحرير المورد الأصلي أبلغ عن خطأ: $error';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Chooses a conservative KV-cache context from available system RAM.
  /// This is only a heuristic: free RAM can change and does not guarantee
  /// that a large model will fit. The caller may request a smaller context.
  @visibleForTesting
  static int recommendedContextSize({
    required int freeRamBytes,
    int requestedContextSize = 2048,
  }) {
    final requested = requestedContextSize.clamp(512, 4096).toInt();
    if (freeRamBytes <= 0) return math.min(requested, 1024);
    const gib = 1024 * 1024 * 1024;
    if (freeRamBytes < 3 * gib) return 512;
    if (freeRamBytes < 5 * gib) return math.min(requested, 1024);
    return requested;
  }

  /// Checks the fixed GGUF v2/v3 header before any large native allocation.
  /// This is an early structural check, not a substitute for llama.cpp loading
  /// the complete model and validating its metadata/tensor payload.
  @visibleForTesting
  static bool isGgufHeaderValid(List<int> header, int fileLength) {
    if (fileLength < 24 || header.length < 24) return false;
    if (header[0] != 0x47 ||
        header[1] != 0x47 ||
        header[2] != 0x55 ||
        header[3] != 0x46) {
      return false;
    }
    final bytes = Uint8List.fromList(header.take(24).toList(growable: false));
    final data = ByteData.sublistView(bytes);
    final version = data.getUint32(4, Endian.little);
    if (version != 2 && version != 3) return false;
    final tensorCount = data.getUint64(8, Endian.little);
    final metadataCount = data.getUint64(16, Endian.little);
    return tensorCount > 0 &&
        tensorCount <= 1000000 &&
        metadataCount > 0 &&
        metadataCount <= 100000;
  }

  Future<bool> _isValidGguf(File file) async {
    try {
      final length = await file.length();
      if (!await file.exists() || length < _minimumGgufBytes) return false;
      final handle = await file.open();
      try {
        final header = await handle.read(24);
        return isGgufHeaderValid(header, length);
      } finally {
        await handle.close();
      }
    } catch (_) {
      return false;
    }
  }

  void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('محرك llama_flutter_android متاح على Android فقط.');
    }
  }
}
