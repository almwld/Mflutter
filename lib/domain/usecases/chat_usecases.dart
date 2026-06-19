import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetConversationHistoryUseCase {
  final ChatRepository repository;

  GetConversationHistoryUseCase(this.repository);

  Future<List<ChatMessage>> call() async {
    return await repository.getConversationHistory();
  }
}

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(ChatMessage message) async {
    await repository.saveMessage(message);
  }
}

class GenerateResponseUseCase {
  final ChatRepository repository;

  GenerateResponseUseCase(this.repository);

  Future<String> call(String input, Map<String, dynamic> context) async {
    return await repository.generateResponse(input, context);
  }
}

class ClearHistoryUseCase {
  final ChatRepository repository;

  ClearHistoryUseCase(this.repository);

  Future<void> call() async {
    await repository.clearHistory();
  }
}