import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/settings_local_datasource.dart';
import '../../services/ollama_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SettingsLocalDatasource localDatasource;
  ChatRepositoryImpl({required this.localDatasource});

  @override
  Future<List<ChatMessage>> getConversationHistory() => localDatasource.getChatHistory();

  @override
  Future<void> saveMessage(ChatMessage message) => localDatasource.saveChatMessage(message);

  @override
  Future<void> clearHistory() => localDatasource.clearChatHistory();

  @override
  Future<String> generateResponse(String input, Map<String, dynamic> context) async {
    final prompt = input.trim();
    if (prompt.isEmpty) return '';
    final service = OllamaService();
    if (!await service.checkAvailability()) {
      throw StateError('المحرك المحلي غير متاح.');
    }
    return service.generate(prompt);
  }
}
