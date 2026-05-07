import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';

/// =============================================================================
/// ChatProvider - مزود المحادثة
/// =============================================================================

class ChatProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;

  /// إرسال رسالة
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    notifyListeners();

    // محاكاة الرد
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // إنشاء الرد
    final response = _generateResponse(content);
    final assistantMessage = ChatMessage.assistant(
      response['content']!,
      metadata: _createMetadata(response),
    );

    _messages.add(assistantMessage);
    _isLoading = false;
    notifyListeners();
  }

  /// توليد الرد
  Map<String, dynamic> _generateResponse(String query) {
    // محاكاة استجابة ذكية
    return {
      'content': 'بارك الله فيك على سؤالك. '
          'القرآن الكريم هو المصدر الأول للعلم والمعرفة. '
          'في سؤالك إشارة إلى أسرار عظيمة. '
          'دعني أوضح لك بعض الدلالات...',
    };
  }

  /// إنشاء البيانات الوصفية
  ChatMetadata _createMetadata(Map<String, dynamic> response) {
    return const ChatMetadata(
      abjadResult: AbjadResult(
        kabir: 786,
        element: 'نور',
        planet: 'شمس',
        divineName: 'النور',
      ),
      divineNames: ['الله', 'النور', 'الحق'],
      insightQuestion: 'ما هو السر المكتوم في سؤالك؟',
    );
  }

  /// حذف المحادثة
  void clearConversation() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  /// حذف رسالة
  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// =============================================================================
/// AbjadResult - بيانات نتيجة الجمل
/// =============================================================================

class AbjadResult {
  final int kabir;
  final String element;
  final String planet;
  final String divineName;

  const AbjadResult({
    required this.kabir,
    required this.element,
    required this.planet,
    required this.divineName,
  });
}