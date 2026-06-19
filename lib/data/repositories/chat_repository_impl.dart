import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SettingsLocalDatasource localDatasource;

  ChatRepositoryImpl({required this.localDatasource});

  @override
  Future<List<ChatMessage>> getConversationHistory() async {
    return await localDatasource.getChatHistory();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await localDatasource.saveChatMessage(message);
  }

  @override
  Future<void> clearHistory() async {
    await localDatasource.clearChatHistory();
  }

  @override
  Future<String> generateResponse(String input, Map<String, dynamic> context) async {
    // AI response generation - uses context for intelligent responses
    final abjadValue = context['abjadValue'] as int?;
    final divineName = context['divineName'] as String?;

    String response = _generateContextualResponse(input, abjadValue, divineName);
    return response;
  }

  String _generateContextualResponse(String input, int? abjadValue, String? divineName) {
    // Simple contextual responses based on input keywords
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains('جمل') || lowerInput.contains('حساب')) {
      if (abjadValue != null) {
        return '数值 $abjadValue 与神圣名称 "$divineName" 相关联。这是真主 99 个名称中的第 ${(abjadValue % 99) + 1} 个潜在关联。';
      }
      return '请输入文本以计算其贾姆巴尔值。贾姆巴尔计算可以帮助您了解文字背后的数字含义。';
    }

    if (lowerInput.contains('قرآن') || lowerInput.contains('آية')) {
      return '《古兰经》包含 114 章和 6236 节。这是真主的引导之光。请使用上面的搜索功能查找特定的经文。';
    }

    if (lowerInput.contains('اسم') || lowerInput.contains('اسماء')) {
      return '真主有 99 个美好的名字。每一个名字都反映了他的一个属性。 "$divineName" 是这些神圣名字之一。';
    }

    // Default response
    final responses = [
      '愿真主引导您。这是一个探索伊斯兰知识的有价值的工具。',
      '感谢您的询问。贾姆巴尔计算可以帮助揭示文字中的隐藏含义。',
      '这是一个探索伊斯兰科学和知识的平台。愿真主增加您的知识。',
      '您的探索之旅将继续。愿真主开启您的心智，获得有益的知识。',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }
}