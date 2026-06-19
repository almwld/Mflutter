import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <Map<String, dynamic>>[];
  bool _loading = false;

  // نماذج الرد السريع (بدون إنترنت)
  final _quickReplies = {
    'قرآن': 'القرآن الكريم هو كلام الله المنزل على محمد ﷺ، 114 سورة، 6236 آية.',
    'توحيد': 'التوحيد هو إفراد الله بالعبادة والربوبية والأسماء والصفات.',
    'صبر': 'الصبر هو حبس النفس عن الجزع، قال تعالى: إنما يوفى الصابرون أجرهم بغير حساب.',
    'رحمة': 'الرحمة هي الرقة والعطف، قال تعالى: ورحمتي وسعت كل شيء.',
    'نور': 'الله نور السماوات والأرض، نور على نور يهدي الله لنوره من يشاء.',
    'حكمة': 'الحكمة هي وضع الشيء في موضعه، ومن يؤت الحكمة فقد أوتي خيراً كثيراً.',
  };

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _controller.clear();

    // محاولة الاتصال بـ Ollama محلياً
    try {
      final response = await http.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'qwen2.5:0.5b',
          'prompt': 'أجب بالعربية: $text',
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({'role': 'assistant', 'text': data['response'] ?? '...'});
          _loading = false;
        });
      } else {
        _fallbackReply(text);
      }
    } catch (_) {
      _fallbackReply(text);
    }

    _scrollToBottom();
  }

  void _fallbackReply(String text) {
    String reply = 'لم أجد إجابة مباشرة. جرب سؤالاً آخر.';

    for (final keyword in _quickReplies.keys) {
      if (text.contains(keyword)) {
        reply = _quickReplies[keyword]!;
        break;
      }
    }

    setState(() {
      _messages.add({'role': 'assistant', 'text': reply});
      _loading = false;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 8),
            Text('مُدَبِّر', style: TextStyle(color: Color(0xFFFFD700))),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFFFD700)),
            onPressed: () => setState(() => _messages.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════
          // منطقة الرسائل
          // ═══════════════════════════════════
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        const Text(
                          'اسأل مُدَبِّر عن القرآن وعلومه',
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickReplies.keys.map((kw) {
                            return GestureDetector(
                              onTap: () {
                                _controller.text = kw;
                                _sendMessage();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                                ),
                                child: Text(kw, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isUser = msg['role'] == 'user';
                      return _buildBubble(msg['text'] ?? '', isUser);
                    },
                  ),
          ),

          // ═══════════════════════════════════
          // شريط الإدخال
          // ═══════════════════════════════════
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1A237E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'اسأل عن القرآن...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0A0E27),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                          strokeWidth: 2,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: const Color(0xFFFFD700),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF1A237E), size: 18),
                          onPressed: _sendMessage,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFFFD700).withOpacity(0.15)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.white12,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? const Color(0xFFFFD700) : Colors.white,
            fontSize: 15,
            height: 1.6,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
