import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../services/ollama_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final OllamaService _localAi = OllamaService();

  bool _loading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> checkLocalModel() => _localAi.checkAvailability();

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _loading) return;

    _messages.add(ChatMessage(text: cleanText, isUser: true));
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final reply = await _localAi.generate(
        'أنت مُدَبِّر الْأَسْرَارِ الْعُلْيَا، مساعد معرفي محلي. '
        'أجب بالعربية الفصحى بدقة ووضوح، ولا تدّعِ امتلاك مصادر غير متاحة محلياً.\n\n'
        'المستخدم: $cleanText\n\nمُدَبِّر:',
      );

      _messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _error = e.toString();
      _messages.add(ChatMessage(
        text: 'تعذر الوصول إلى النموذج المحلي. '
            'تحقق من تشغيل خادم النموذج المحلي ومن اسم النموذج ثم أعد المحاولة.',
        isUser: false,
      ));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
