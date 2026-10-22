import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';

class GgufDownloadProgress {
  final int receivedBytes;
  final int? totalBytes;

  const GgufDownloadProgress(this.receivedBytes, this.totalBytes);

  double? get fraction {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (receivedBytes / total).clamp(0.0, 1.0);
  }
}

/// Private-storage GGUF lifecycle and llama.cpp runtime for Android.
///
/// A downloaded/imported file is not treated as a loaded model until its GGUF
/// header is checked and llama.cpp successfully loads it.
class LocalGgufRuntimeService extends ChangeNotifier {
  LocalGgufRuntimeService._();
  static final LocalGgufRuntimeService instance = LocalGgufRuntimeService._();

  static const modelFileName = '3arabLM-4B-islamic-v2.Q4_K_M.gguf';
  static const modelUrl =
      'https://huggingface.co/mradermacher/3arabLM-4B-islamic-v2-GGUF/resolve/main/3arabLM-4B-islamic-v2.Q4_K_M.gguf';
  static const _minimumGgufBytes = 1024 * 1024;
  static const _minimumDefaultModelBytes = 2650000000;

  LlamaController? _controller;
  String _status = 'لم يتم تثبيت نموذج GGUF محلي';
  bool _busy = false;
  bool _generating = false;
  bool _loaded = false;
  double? _downloadProgress;
  String? _loadedPath;

  String get status => _status;
  bool get isBusy => _busy;
  bool get isGenerating => _generating;
  bool get isLoaded => _loaded;
  double? get downloadProgress => _downloadProgress;
  String? get loadedPath => _loadedPath;

  Future<Directory> _modelDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/mudabbir_models');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<File> modelFile() async {
    final directory = await _modelDirectory();
    return File('${directory.path}/$modelFileName');
  }

  Future<bool> hasValidModel() async {
    try {
      final file = await modelFile();
      return await _isValidDefaultModel(file);
    } catch (_) {
      return false;
    }
  }

  Future<File> downloadDefaultModel({
    void Function(GgufDownloadProgress progress)? onProgress,
    int maxAttempts = 5,
  }) async {
    _ensureAndroid();
    if (_busy || _generating || _loaded) {
      throw StateError('أوقف التوليد وأفرغ النموذج قبل استبدال ملف GGUF.');
    }
    if (maxAttempts < 1 || maxAttempts > 10) {
      throw ArgumentError('عدد محاولات التنزيل يجب أن يكون بين 1 و10.');
    }
    _busy = true;
    _downloadProgress = 0;
    _status = 'جارٍ تنزيل النموذج مع دعم الاستئناف...';
    notifyListeners();

    Object? lastError;
    try {
      // Keep all filesystem setup inside try/finally so a storage exception
      // cannot leave the service permanently marked busy.
      final directory = await _modelDirectory();
      final target = File('${directory.path}/$modelFileName');
      final partial = File('${target.path}.part');
      if (await _isValidDefaultModel(target)) {
        _status = 'النموذج موجود وموقّع ببنية GGUF صحيحة.';
        return target;
      }

      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 30)
          ..idleTimeout = const Duration(seconds: 60);
        RandomAccessFile? output;
        try {
          var offset = await partial.exists() ? await partial.length() : 0;
          final request = await client.getUrl(Uri.parse(modelUrl));
          request.headers.set(HttpHeaders.userAgentHeader, 'Mudabbir-Mflutter/2.0');
          request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
          if (offset > 0) {
            request.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
          }

          final response = await request.close().timeout(const Duration(minutes: 2));
          if (response.statusCode != HttpStatus.ok &&
              response.statusCode != HttpStatus.partialContent) {
            final statusCode = response.statusCode;
            await response.drain<void>();
            if (statusCode == HttpStatus.requestedRangeNotSatisfiable &&
                await partial.exists()) {
              await partial.delete();
            }
            throw HttpException('خادم النموذج أعاد HTTP $statusCode.');
          }

          if (offset > 0 && response.statusCode == HttpStatus.ok) {
            // The server ignored Range. Restart from byte zero rather than
            // appending a complete response to an old partial file.
            offset = 0;
          } else if (response.statusCode == HttpStatus.partialContent) {
            final range = response.headers.value(HttpHeaders.contentRangeHeader);
            final match = range == null
                ? null
                : RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(range);
            if (match == null || int.parse(match.group(1)!) != offset) {
              await response.drain<void>();
              await partial.delete().catchError((_) => partial);
              throw HttpException('استجابة Range غير متوافقة؛ أُزيل الجزء غير القابل للاستئناف.');
            }
          }

          final totalBytes = _responseTotalBytes(response);
          output = await partial.open(
            mode: offset > 0 && response.statusCode == HttpStatus.partialContent
                ? FileMode.append
                : FileMode.write,
          );
          var received = offset;
          _downloadProgress = totalBytes != null && totalBytes > 0
              ? (received / totalBytes).clamp(0.0, 1.0).toDouble()
              : null;
          onProgress?.call(GgufDownloadProgress(received, totalBytes));
          notifyListeners();
          var lastNotifiedProgress = _downloadProgress ?? -1.0;
          var lastProgressNotification = DateTime.now();

          await for (final chunk in response.timeout(const Duration(seconds: 90))) {
            await output.writeFrom(chunk);
            received += chunk.length;
            final progress = totalBytes != null && totalBytes > 0
                ? (received / totalBytes).clamp(0.0, 1.0).toDouble()
                : null;
            final now = DateTime.now();
            final shouldNotify = progress == null
                ? _downloadProgress != null
                : progress >= 1 ||
                    lastNotifiedProgress < 0 ||
                    progress - lastNotifiedProgress >= 0.005 ||
                    now.difference(lastProgressNotification) >=
                        const Duration(milliseconds: 500);
            if (shouldNotify) {
              _downloadProgress = progress;
              lastNotifiedProgress = progress ?? -1.0;
              lastProgressNotification = now;
              notifyListeners();
            }
            onProgress?.call(GgufDownloadProgress(received, totalBytes));
          }
          await output.flush();
          await output.close();
          output = null;

          final actualBytes = await partial.length();
          if (totalBytes != null && actualBytes != totalBytes) {
            throw HttpException('اكتمل الاتصال قبل اكتمال الملف: $actualBytes من $totalBytes بايت.');
          }
          if (!await _isValidDefaultModel(partial)) {
            throw const FormatException('الملف المكتمل لا يحتوي ترويسة GGUF صالحة أو حجمه غير كافٍ.');
          }

          if (await target.exists()) await target.delete();
          await partial.rename(target.path);
          _downloadProgress = 1;
          _status = 'اكتمل التنزيل والتحقق البنيوي من GGUF.';
          return target;
        } catch (error) {
          lastError = error;
          // A full-sized file with an invalid GGUF magic is corrupt, not a
          // resumable partial. Remove it so retries do not loop at EOF.
          if (await partial.exists() &&
              await partial.length() >= _minimumDefaultModelBytes &&
              !await _isValidGguf(partial)) {
            await partial.delete();
          }
          _status = 'انقطع التنزيل؛ الاحتفاظ بالجزء الصالح لاستئنافه (محاولة $attempt/$maxAttempts).';
          notifyListeners();
          if (attempt < maxAttempts) {
            await Future<void>.delayed(Duration(seconds: math.min(attempt * 3, 15)));
          }
        } finally {
          try {
            await output?.close();
          } catch (_) {}
          client.close(force: true);
        }
      }
      throw StateError('تعذر إكمال تنزيل GGUF بعد $maxAttempts محاولات: $lastError');
    } catch (error) {
      _status = 'فشل تنزيل النموذج: $error';
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
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
      if (sourceName != modelFileName) {
        throw FormatException('اختر الملف $modelFileName؛ هذه الشاشة مهيأة لهذا النموذج تحديدًا.');
      }
      if (!await _isValidDefaultModel(source)) {
        throw const FormatException(
          'ملف 3arabLM غير مكتمل أو لا يحتوي ترويسة GGUF صالحة. '
          'أكمل التنزيل قبل الاستيراد.',
        );
      }
      final target = await modelFile();
      if (source.absolute.path == target.absolute.path) {
        _status = 'النموذج موجود في مجلد التطبيق.';
        return target;
      }
      final temp = File('${target.path}.importing');
      if (await temp.exists()) await temp.delete();
      await source.openRead().pipe(temp.openWrite());
      if (!await _isValidDefaultModel(temp)) {
        await temp.delete();
        throw const FormatException('فشل التحقق من نسخة النموذج بعد الاستيراد.');
      }
      if (await target.exists()) await target.delete();
      await temp.rename(target.path);
      _status = 'تم استيراد GGUF إلى مساحة التطبيق الخاصة.';
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
      if (!await _isValidDefaultModel(file)) {
        throw StateError('لم يُعثر على ملف 3arabLM GGUF مكتمل وصالح في مساحة التطبيق.');
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
      try {
        await controller.loadModel(
          modelPath: file.path,
          threads: threads.clamp(1, 8).toInt(),
          contextSize: contextSize.clamp(512, 4096).toInt(),
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
      _status = 'تم تحميل النموذج محليًا؛ الاستدلال يعمل على الجهاز دون خادم.';
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

  Future<bool> _isValidDefaultModel(File file) async {
    try {
      return await file.length() >= _minimumDefaultModelBytes &&
          await _isValidGguf(file);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isValidGguf(File file) async {
    try {
      if (!await file.exists() || await file.length() < _minimumGgufBytes) return false;
      final handle = await file.open();
      try {
        final header = await handle.read(8);
        if (header.length != 8 ||
            header[0] != 0x47 ||
            header[1] != 0x47 ||
            header[2] != 0x55 ||
            header[3] != 0x46) {
          return false;
        }
        final version = header[4] |
            (header[5] << 8) |
            (header[6] << 16) |
            (header[7] << 24);
        return version == 2 || version == 3;
      } finally {
        await handle.close();
      }
    } catch (_) {
      return false;
    }
  }

  int? _responseTotalBytes(HttpClientResponse response) {
    final range = response.headers.value(HttpHeaders.contentRangeHeader);
    if (range != null) {
      final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(range);
      if (match != null) return int.tryParse(match.group(3)!);
    }
    return response.contentLength > 0 ? response.contentLength : null;
  }

  void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('محرك llama_flutter_android متاح على Android فقط.');
    }
  }
}
