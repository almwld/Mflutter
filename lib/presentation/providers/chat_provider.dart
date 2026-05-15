import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void sendMessage(String text) {
    _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      final abjad = AbjadResult.fromText(text);
      _messages.add(ChatMessage(
        content: 'بسم الله الرحمن الرحيم\n\n🔢 جمل السؤال: ${abjad.kabir}\n📖 ﴿أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ﴾ (النساء:82)',
        isUser: false,
        timestamp: DateTime.now(),
        abjadResult: abjad,
      ));
      _isLoading = false;
      notifyListeners();
    });
  }
}
