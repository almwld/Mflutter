import 'abjad_result.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? surahRef;
  final AbjadResult? abjadResult;
  final double? energy;

  bool get isFromUser => isUser;
  Map<String, dynamic> get metadata => {
    if (surahRef != null) 'surahRef': surahRef,
    if (abjadResult != null) 'abjadResult': abjadResult!.toMap(),
    if (energy != null) 'energy': energy,
  };

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.surahRef,
    this.abjadResult,
    this.energy,
  }) : timestamp = timestamp ?? DateTime.now();
}
