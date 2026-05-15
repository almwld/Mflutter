import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;

  void sendMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: true));
    _loading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      final abjadResult = AbjadResult(major: 382, minor: 38, middle: 182, energy: 0.38);
      _messages.add(ChatMessage(
        text: '📖 قال تعالى: "اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ" (النور:35)\n\n🔢 جمل الآية: 287\n🔬 العلوم: فلك، فيزياء\n🕌 الصفات: النور، العليم',
        isUser: false,
        surahRef: 'النور:35',
        abjadResult: abjadResult,
        energy: 0.87,
      ));
      _loading = false;
      notifyListeners();
    });
  }
}
