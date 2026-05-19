import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OllamaService {
  static final OllamaService _instance = OllamaService._();
  factory OllamaService() => _instance;
  OllamaService._();

  bool _isRunning = false;
  Process? _ollamaProcess;
  
  bool get isRunning => _isRunning;

  /// تشغيل خادم Ollama تلقائياً
  Future<bool> startServer() async {
    if (_isRunning) return true;

    try {
      // أولاً: جرب الاتصال — يمكن الخادم شغال من قبل
      final testResponse = await http.get(
        Uri.parse('http://localhost:11434/api/tags'),
      ).timeout(const Duration(seconds: 2));
      
      if (testResponse.statusCode == 200) {
        _isRunning = true;
        debugPrint('✅ Ollama كان شغال مسبقاً');
        return true;
      }
    } catch (_) {
      // الخادم مش شغال — نشغله
    }

    try {
      // تشغيل ollama serve
      _ollamaProcess = await Process.start(
        '/data/data/com.termux/files/usr/bin/ollama',
        ['serve'],
        environment: {
          'HOME': '/data/data/com.termux/files/home',
          'PATH': '/data/data/com.termux/files/usr/bin',
          'OLLAMA_HOST': '0.0.0.0:11434',
        },
      );

      // انتظر 3 ثواني للتحقق من التشغيل
      await Future.delayed(const Duration(seconds: 3));
      
      // تأكد أنه شغال
      for (int i = 0; i < 5; i++) {
        try {
          final testResponse = await http.get(
            Uri.parse('http://localhost:11434/api/tags'),
          ).timeout(const Duration(seconds: 2));
          
          if (testResponse.statusCode == 200) {
            _isRunning = true;
            debugPrint('✅ تم تشغيل Ollama بنجاح');
            return true;
          }
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      debugPrint('❌ فشل تشغيل Ollama');
      return false;
    } catch (e) {
      debugPrint('❌ خطأ: $e');
      return false;
    }
  }

  /// إيقاف الخادم
  void stopServer() {
    _ollamaProcess?.kill();
    _isRunning = false;
  }

  /// التحقق من وجود النموذج
  Future<bool> hasModel(String modelName) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:11434/api/tags'),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = response.body;
        return data.contains(modelName);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
