import '../../core/constants/app_enums.dart';

/// =============================================================================
/// ChatMessage - كيان رسالة المحادثة
/// =============================================================================

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final ChatMetadata? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  /// هل رسالة مستخدم؟
  bool get isUser => type == MessageType.user;

  /// هل رسالة مساعد؟
  bool get isAssistant => type == MessageType.assistant;

  /// هل رسالة نظام؟
  bool get isSystem => type == MessageType.system;

  /// اسم المرسل
  String get senderName {
    switch (type) {
      case MessageType.user:
        return 'أنت';
      case MessageType.assistant:
        return 'المُدَبِّر';
      case MessageType.system:
        return 'النظام';
    }
  }

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata?.toMap(),
  };

  /// إنشاء من Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'] ?? '',
    content: map['content'] ?? '',
    type: MessageType.values[map['type'] ?? 1],
    timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    metadata: map['metadata'] != null
        ? ChatMetadata.fromMap(map['metadata'])
        : null,
  );

  /// إنشاء رسالة مستخدم
  factory ChatMessage.user(String content) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content,
    type: MessageType.user,
    timestamp: DateTime.now(),
  );

  /// إنشاء رسالة مساعد
  factory ChatMessage.assistant(String content, {ChatMetadata? metadata}) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

  /// إنشاء رسالة نظام
  factory ChatMessage.system(String content) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: content,
    type: MessageType.system,
    timestamp: DateTime.now(),
  );
}

/// =============================================================================
/// ChatMetadata - بيانات رسالة المحادثة
/// =============================================================================

class ChatMetadata {
  final List<String>? relatedVerses;
  final AbjadResultData? abjadResult;
  final List<String>? sciences;
  final List<String>? divineNames;
  final String? insightQuestion;
  final int? modelConfidence;

  const ChatMetadata({
    this.relatedVerses,
    this.abjadResult,
    this.sciences,
    this.divineNames,
    this.insightQuestion,
    this.modelConfidence,
  });

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'related_verses': relatedVerses,
    'abjad_result': abjadResult?.toMap(),
    'sciences': sciences,
    'divine_names': divineNames,
    'insight_question': insightQuestion,
    'model_confidence': modelConfidence,
  };

  /// إنشاء من Map
  factory ChatMetadata.fromMap(Map<String, dynamic> map) => ChatMetadata(
    relatedVerses: List<String>.from(map['related_verses'] ?? []),
    abjadResult: map['abjad_result'] != null
        ? AbjadResultData.fromMap(map['abjad_result'])
        : null,
    sciences: List<String>.from(map['sciences'] ?? []),
    divineNames: List<String>.from(map['divine_names'] ?? []),
    insightQuestion: map['insight_question'],
    modelConfidence: map['model_confidence'],
  );
}

/// =============================================================================
/// AbjadResultData - بيانات نتيجة الجمل
/// =============================================================================

class AbjadResultData {
  final int kabir;
  final String element;
  final String planet;
  final String divineName;

  const AbjadResultData({
    required this.kabir,
    required this.element,
    required this.planet,
    required this.divineName,
  });

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'kabir': kabir,
    'element': element,
    'planet': planet,
    'divine_name': divineName,
  };

  /// إنشاء من Map
  factory AbjadResultData.fromMap(Map<String, dynamic> map) =>
      AbjadResultData(
        kabir: map['kabir'] ?? 0,
        element: map['element'] ?? '',
        planet: map['planet'] ?? '',
        divineName: map['divine_name'] ?? '',
      );
}

/// =============================================================================
/// ChatConversation - محادثة
/// =============================================================================

class ChatConversation {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool isFavorite;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    this.isFavorite = false,
  });

  /// عدد الرسائل
  int get messageCount => messages.length;

  /// آخر رسالة
  ChatMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  /// هل فارغة؟
  bool get isEmpty => messages.isEmpty;
}