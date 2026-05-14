import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  // المفتاح يُقرأ من متغير بيئة أو ملف منفصل - لا يُخزن في الكود
  static const String _apiKey = 'YOUR_OPENROUTER_API_KEY'; // استبدل هذا
  
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  
  static Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen/qwen-2.5-7b-instruct:free',
          'messages': [
            {'role': 'system', 'content': 'أنت مُدَبِّر، مساعد قرآني متخصص. أجب بالعربية.'},
            {'role': 'user', 'content': message}
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      return 'عذراً، لم أستطع معالجة طلبك.';
    } catch (e) {
      return 'خطأ في الاتصال. تأكد من الإنترنت.';
    }
  }
}
