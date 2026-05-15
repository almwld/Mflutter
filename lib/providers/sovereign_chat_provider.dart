import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SovereignChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _insight = "";

  bool get isLoading => _isLoading;
  String get insight => _insight;

  Future<void> fetchInsight({
    required String query,
    required double focus,
    required String topography,
    required int abjad,
  }) async {
    _isLoading = true;
    notifyListeners();
    const url = "https://openrouter.ai/api/v1/chat/completions";
    const key = "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";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $key", "Content-Type": "application/json"},
        body: jsonEncode({
          "model": "qwen/qwen-2.5-7b-instruct:free",
          "messages": [
            {"role": "system", "content": "أنت مُدَبِّر. أجب بالعربية. تركيز المستخدم: $focus. البيئة: $topography. الرنين: $abjad."},
            {"role": "user", "content": query}
          ],
          "temperature": 0.618,
        }),
      );
      if (response.statusCode == 200) {
        _insight = jsonDecode(response.body)['choices'][0]['message']['content'];
      } else {
        _insight = "تعذر الاتصال بالنواة.";
      }
    } catch (_) {
      _insight = "انقطع التدفق المعرفي.";
    }
    _isLoading = false;
    notifyListeners();
  }
}
