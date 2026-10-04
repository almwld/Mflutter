import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _quickReplies = [
    'القرآن',
    'توحيد',
    'صبر',
    'رحمة',
    'نور',
    'حكمة',
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          appBar: AppBar(
            title: const Text('مُدَبِّر'),
            backgroundColor: const Color(0xFF1A237E),
            actions: [
              IconButton(
                tooltip: 'مسح المحادثة',
                icon: const Icon(Icons.delete_outline),
                onPressed: chat.loading ? null : chat.clearChat,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: chat.messages.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: chat.messages.length,
                        itemBuilder: (_, i) {
                          final msg = chat.messages[i];
                          return _buildBubble(msg.text, msg.isUser);
                        },
                      ),
              ),
              if (chat.loading)
                const LinearProgressIndicator(minHeight: 2),
              _inputBar(chat.loading),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _quickReplies.map((item) {
            return ActionChip(
              label: Text(item),
              onPressed: () {
                _controller.text = item;
                _sendMessage();
              },
            );
          }).toList(),
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
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'اسأل النموذج المحلي...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF151A35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
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
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF31406F)
              : const Color(0xFF20263F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.6,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
