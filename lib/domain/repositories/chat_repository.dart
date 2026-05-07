import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getConversationHistory();
  Future<void> saveMessage(ChatMessage message);
  Future<void> clearHistory();
  Future<String> generateResponse(String input, Map<String, dynamic> context);
}