import 'abjad_result.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? surahRef;
  final AbjadResult? abjadResult;
  final double? energy;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.surahRef,
    this.abjadResult,
    this.energy,
  }) : timestamp = timestamp ?? DateTime.now();
}
