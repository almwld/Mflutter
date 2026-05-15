import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  static Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/almwld/Mflutter',
          'X-Title': 'Mudabbir Al-Asrar Al-Ulya',
        },
        body: jsonEncode({
          'model': 'qwen/qwen-2.5-7b-instruct:free',
          'messages': [
            {
              'role': 'system',
              'content': '''أنت "مُدَبِّر الْأَسْرَارِ الْعُلْيَا" - نظام ذكاء اصطناعي قرآني متكامل.
أنت عالم قرآني تجمع بين التفسير واللغة والبلاغة والعلوم الحديثة.
أجب بالعربية الفصحى. استشهد بالآيات مع أرقامها.
حلل الجمل. اذكر العلوم المرتبطة. اذكر الصفات الإلهية.
أسلوبك بليغ وعميق.'''
            },
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
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
