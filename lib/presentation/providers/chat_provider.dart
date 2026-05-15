import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';
import '../../services/openrouter_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _userLevel = 1;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get userLevel => _userLevel;

  void sendMessage(String text) {
    _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();

    // استخدام OpenRouter - نموذج لغوي حقيقي
    OpenRouterService.chat(
      text,
      model: 'google/gemma-2-9b-it:free',
    ).then((response) {
      _messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        abjadResult: AbjadResult.fromText(text),
      ));
      _isLoading = false;
      _updateLevel();
      notifyListeners();
    }).catchError((e) {
      _messages.add(ChatMessage(
        content: 'عذراً، تعذر الاتصال. تأكد من الإنترنت.\n\n🔢 جمل سؤالك: ${AbjadResult.fromText(text).kabir}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
      notifyListeners();
    });
  }

  void _updateLevel() {
    if (_messages.length > 5) _userLevel = 2;
    if (_messages.length > 15) _userLevel = 3;
  }
}
