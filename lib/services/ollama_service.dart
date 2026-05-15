import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434/api';
  static const String _model = 'mudabbir-llm';

  static Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'أنت مُدَبِّر، مساعد قرآني متخصص. أجب بالعربية الفصحى.'
            },
            {'role': 'user', 'content': message}
          ],
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message']['content'];
      }
      return 'عذراً، لم أستطع معالجة طلبك.';
    } catch (e) {
      return 'تأكد أن Ollama يعمل. نفذ: ollama serve';
    }
  }
}
