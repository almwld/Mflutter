import 'package:flutter/material.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _checkingModel = true;
  bool _modelAvailable = false;
  late final ChatProvider _chat;

  static const _quickReplies = [
    'ما هو موضوع هذه الآية؟',
    'ابحث عن آية عن الصبر',
    'اشرح لي معنى الرحمة',
    'أعطني تدبراً مختصراً',
  ];

  @override
  void initState() {
    super.initState();
    _chat = ChatProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _chat.checkLocalModel().then((available) {
        if (!mounted) return;
        setState(() {
          _modelAvailable = available;
          _checkingModel = false;
        });
      });
    });
  }

  Future<void> _checkModel() async {
    if (!mounted) return;
    final available = await _chat.checkLocalModel();
    if (!mounted) return;
    setState(() {
      _modelAvailable = available;
      _checkingModel = false;
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _chat.sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chat,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF0B1117),
        appBar: AppBar(
          title: const Text('مُدَبِّر'),
          backgroundColor: const Color(0xFF10201E),
          actions: [
            IconButton(
              tooltip: 'فحص النموذج المحلي',
              icon: _checkingModel
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_modelAvailable ? Icons.cloud_done : Icons.cloud_off),
              onPressed: _checkingModel ? null : _checkModel,
            ),
            IconButton(
              tooltip: 'مسح المحادثة',
              icon: const Icon(Icons.delete_outline),
              onPressed: _chat.loading ? null : _chat.clearChat,
            ),
          ],
        ),
        body: Column(
          children: [
            _modelBanner(),
            Expanded(
              child: _chat.messages.isEmpty
                  ? _emptyState(_chat.loading)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      itemCount: _chat.messages.length,
                      itemBuilder: (_, i) {
                        final msg = _chat.messages[i];
                        return _buildBubble(msg.text, msg.isUser);
                      },
                    ),
            ),
            if (_chat.loading) const LinearProgressIndicator(minHeight: 2),
            _inputBar(_chat.loading),
          ],
        ),
      ),
    );
  }
  Widget _modelBanner() {
    final text = _checkingModel
        ? 'جارٍ فحص النموذج المحلي…'
        : _modelAvailable
            ? 'النموذج المحلي متصل • mudabbir'
            : 'النموذج المحلي غير متصل • 127.0.0.1:11434';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF101A1A),
      child: Row(
        children: [
          Icon(
            _modelAvailable ? Icons.check_circle : Icons.info_outline,
            size: 18,
            color: _modelAvailable ? const Color(0xFF36C7A5) : Colors.white54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool loading) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 58,
              color: Color(0xFF36C7A5),
            ),
            const SizedBox(height: 14),
            const Text(
              'محادثة محلية بالكامل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يحتاج الحوار إلى OpenRouter أو خدمة ذكاء اصطناعي خارجية.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, height: 1.5),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _quickReplies
                  .map(
                    (item) => ActionChip(
                      label: Text(item, textDirection: TextDirection.rtl),
                      onPressed: loading ? null : () {
                        _controller.text = item;
                        _sendMessage();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar(bool loading) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !loading,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'اسأل النموذج المحلي…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF151D22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF263A3A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF263A3A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF36C7A5)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'إرسال',
              onPressed: loading ? null : _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF0D8274)
              : const Color(0xFF182522),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
