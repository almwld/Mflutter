import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../models/abjad_result.dart';
import '../widgets/chat_bubble.dart';

/// =============================================================================
/// ChatProvider - مزود حالة المحادثة
/// =============================================================================

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  String? get error => _error;

  /// إرسال رسالة
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    final userMessage = ChatMessage.user(text);
    _messages.add(userMessage);
    notifyListeners();

    // إظهار حالة الكتابة
    _isTyping = true;
    _error = null;
    notifyListeners();

    try {
      // معالجة الاستعلام
      final response = await _chatService.processQuery(text);

      // بناء البيانات الوصفية
      final metadata = {
        'abjadValue': response.abjadResult.kabir,
        'divineName': response.abjadResult.divineName,
        'element': response.abjadResult.element,
        'planet': response.abjadResult.planet,
        'zodiac': response.abjadResult.zodiac,
        'frequency': response.abjadResult.frequency,
      };

      // إضافة رسالة التطبيق
      final appMessage = ChatMessage.app(response.text, metadata: metadata);
      _messages.add(appMessage);
    } catch (e) {
      _error = 'حدث خطأ في معالجة طلبك';
      _messages.add(ChatMessage.app('عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.'));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// مسح المحادثة
  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  /// حذف رسالة
  void deleteMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// الحصول على سياق المحادثة
  Map<String, dynamic> getConversationContext() {
    if (_messages.isEmpty) return {};

    final lastUserMessage = _messages.lastWhere(
      (m) => m.isFromUser,
      orElse: () => _messages.first,
    );

    return _chatService.buildContext(
      query: lastUserMessage.text,
      abjad: AbjadResult(
        kabir: lastUserMessage.metadata?['abjadValue'] ?? 0,
        saghir: 0,
        wasat: 0,
        element: lastUserMessage.metadata?['element'] ?? '',
        planet: lastUserMessage.metadata?['planet'] ?? '',
        zodiac: lastUserMessage.metadata?['zodiac'] ?? '',
        divineName: lastUserMessage.metadata?['divineName'] ?? '',
        frequency: lastUserMessage.metadata?['frequency'] ?? 0.0,
        color: 0xFFFFD700,
        letterResults: [],
      ),
    );
  }
}

/// =============================================================================
/// AbjadResult - نسخة مبسطة
/// =============================================================================

class AbjadResult {
  final int kabir;
  final int saghir;
  final int wasat;
  final String element;
  final String planet;
  final String zodiac;
  final String divineName;
  final double frequency;
  final int color;
  final List<LetterResult> letterResults;

  AbjadResult({
    required this.kabir,
    required this.saghir,
    required this.wasat,
    required this.element,
    required this.planet,
    required this.zodiac,
    required this.divineName,
    required this.frequency,
    required this.color,
    required this.letterResults,
  });
}

/// =============================================================================
/// LetterResult - نتيجة الحرف
/// =============================================================================

class LetterResult {
  final String letter;
  final int value;

  LetterResult({required this.letter, required this.value});
}