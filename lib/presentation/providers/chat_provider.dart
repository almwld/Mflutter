import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  
  // Ollama API — يعمل محلياً
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  static const String _modelName = 'mudabbir';
  
  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;

  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessage(text: text, isUser: true));
    _loading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_ollamaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _modelName,
          'prompt': 'المستخدم: $text\n\nمُدَبِّر:',
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_k': 40,
            'top_p': 0.9,
            'num_predict': 300,
          }
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['response'] ?? 'عذراً، لم أستطع توليد رد.';
        
        _messages.add(ChatMessage(
          text: reply.trim(),
          isUser: false,
        ));
      } else {
        _messages.add(ChatMessage(
          text: '⚠️ خطأ في الاتصال بـ Ollama: ${response.statusCode}',
          isUser: false,
        ));
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: '❌ تأكد من تشغيل Ollama في Termux:\n'
              '1. افتح Termux\n'
              '2. شغّل: ollama serve\n'
              '3. عد للتطبيق وحاول مجدداً',
        isUser: false,
      ));
    }

    _loading = false;
    notifyListeners();
  }
  
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
