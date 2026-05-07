import 'abjad_result.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AbjadResult? abjadResult;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.abjadResult,
  });
}
