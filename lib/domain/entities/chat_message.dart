import 'abjad_result.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? surahRef;
  final AbjadResult? abjadResult;
  final double? energy;

  const ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.surahRef,
    this.abjadResult,
    this.energy,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'text': text,
    'isUser': isUser ? 1 : 0,
    'timestamp': timestamp.toIso8601String(),
    'surahRef': surahRef,
    'abjadResult': abjadResult?.toMap(),
    'energy': energy,
  };
}
