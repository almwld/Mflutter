import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void sendMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();
    
    Future.delayed(Duration(seconds: 1), () {
      _messages.add(ChatMessage(
        text: 'بسم الله الرحمن الرحيم\n\nتم استلام سؤالك: $text',
        isUser: false,
        abjadResult: AbjadResult.fromText(text),
      ));
      _isLoading = false;
      notifyListeners();
    });
  }
}
