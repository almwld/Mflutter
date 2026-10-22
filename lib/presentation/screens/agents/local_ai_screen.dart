import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/local_gguf_service.dart';

class LocalAiScreen extends StatefulWidget {
  const LocalAiScreen({super.key});

  @override
  State<LocalAiScreen> createState() => _LocalAiScreenState();
}

class _LocalAiScreenState extends State<LocalAiScreen> {
  final _service = LocalGgufService.instance;
  final _prompt = TextEditingController();
  final _scroll = ScrollController();
  final List<_LocalMessage> _messages = [];
  StreamSubscription<String>? _generation;
  bool _busy = false;
  bool _loadingSaved = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreModel();
  }

  Future<void> _restoreModel() async {
    try {
      await _service.loadSavedModel();
    } catch (error) {
      _error = 'تعذر تحميل النموذج المحفوظ: $error';
    }
    if (mounted) setState(() => _loadingSaved = false);
  }

  Future<void> _importModel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gguf'],
        allowMultiple: false,
        withData: false,
      );
      if (result == null) return;
      final path = result.files.single.path;
      if (path == null || path.isEmpty) {
        throw StateError('تعذر الوصول إلى مسار الملف المختار.');
      }
      setState(() { _busy = true; _error = null; });
      final name = await _service.importModel(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحميل النموذج المحلي: $name')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final prompt = _prompt.text.trim();
    if (prompt.isEmpty || _busy) return;
    if (!_service.isLoaded) {
      setState(() => _error = 'استورد ملف GGUF محلياً أولاً.');
      return;
    }
    _prompt.clear();
    setState(() {
      _busy = true;
      _error = null;
      _messages.add(_LocalMessage(prompt, isUser: true));
      _messages.add(_LocalMessage('', isUser: false));
    });
    _scrollToBottom();
    try {
      final index = _messages.length - 1;
      _generation = _service.generateChat(
        systemPrompt: 'أنت مساعد محلي داخل تطبيق مُدَبِّر. أجب بالعربية بوضوح. '
            'لا تدّعِ أنك تحققت من مصادر أو نفذت أدوات لم تُستخدم. '
            'عند الأسئلة القرآنية، لا تخترع نص آية أو نسبة تفسير؛ صرّح بعدم اليقين عند الحاجة.',
        userPrompt: prompt,
        maxTokens: 512,
        temperature: 0.65,
      ).listen(
        (token) {
          if (!mounted) return;
          setState(() => _messages[index].text += token);
          _scrollToBottom();
        },
        onError: (Object error) {
          if (mounted) setState(() => _error = 'فشل التوليد المحلي: $error');
        },
        onDone: () {
          if (mounted) setState(() => _busy = false);
        },
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      if (mounted) setState(() => _busy = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _stop() async {
    await _service.stop();
    await _generation?.cancel();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _unload() async {
    await _service.unloadModel();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _generation?.cancel();
    _prompt.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaded = _service.isLoaded;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الذكاء المحلي — GGUF'),
        actions: [
          if (loaded)
            IconButton(
              tooltip: 'تفريغ النموذج من الذاكرة',
              onPressed: _unload,
              icon: const Icon(Icons.memory_rounded),
            ),
        ],
      ),
      body: _loadingSaved
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: [
                            Icon(
                              loaded ? Icons.check_circle : Icons.memory_rounded,
                              color: loaded ? Colors.green : AppColors.primaryGold,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loaded ? (_service.modelName ?? 'نموذج GGUF محمّل') : 'لا يوجد نموذج محلي محمّل',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          const Text(
                            'الاستدلال يعمل على الجهاز عبر llama.cpp؛ لا يوجد اتصال بـ OpenRouter أو خدمة سحابية. اختر ملف .gguf من مساحة التخزين.',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(color: Colors.white70, height: 1.45, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _importModel,
                              icon: const Icon(Icons.file_open_rounded),
                              label: const Text('استيراد / تحميل نموذج GGUF'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(_error!, textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 620),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser ? AppColors.primaryNavy : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            message.text.isEmpty && _busy ? 'يكتب النموذج المحلي…' : message.text,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(color: Colors.white, height: 1.6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton.filled(
                          onPressed: _busy ? _stop : _send,
                          icon: Icon(_busy ? Icons.stop_rounded : Icons.send_rounded),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _prompt,
                            minLines: 1,
                            maxLines: 5,
                            textDirection: TextDirection.rtl,
                            decoration: const InputDecoration(
                              hintText: 'اكتب سؤالك للنموذج المحلي…',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) { if (!_busy) _send(); },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LocalMessage {
  _LocalMessage(this.text, {required this.isUser});
  String text;
  final bool isUser;
}
