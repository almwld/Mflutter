import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  static String exportConversation(List<dynamic> messages) {
    final buffer = StringBuffer();
    buffer.writeln('مُدَبِّر الْأَسْرَارِ الْعُلْيَا');
    buffer.writeln('تقرير المحادثة');
    buffer.writeln('═' * 30);

    for (final msg in messages) {
      final isUser = msg.isUser ?? false;
      final content = msg.content ?? '';
      final time = msg.timestamp?.toString() ?? '';
      buffer.writeln('');
      buffer.writeln(isUser ? 'أنت (' + time + '):' : 'مُدَبِّر (' + time + '):');
      buffer.writeln(content);
      buffer.writeln('─' * 20);
    }
    return buffer.toString();
  }

  static String exportBookmarks(List<Map<String, dynamic>> bookmarks) {
    final buffer = StringBuffer();
    buffer.writeln('مُدَبِّر - الآيات المفضلة');
    buffer.writeln('═' * 30);
    for (final b in bookmarks) {
      buffer.writeln('الآية: ' + (b['text'] ?? '').toString());
      buffer.writeln(
        'الموضع: سورة ' + (b['surah'] ?? '').toString() +
        ' - آية ' + (b['ayah'] ?? '').toString(),
      );
      buffer.writeln('─' * 20);
    }
    return buffer.toString();
  }

  /// ينشئ ملف PDF حقيقياً داخل مجلد الملفات المؤقتة للتطبيق.
  /// يستخدم خط أميري المضمّن حتى لا تتكسر العربية في الملف الناتج.
  static Future<File> writeTextPdf({
    required String title,
    required String body,
    String fileName = 'mudabbir-export.pdf',
  }) async {
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final font = pw.Font.ttf(fontData.buffer.asByteData());
    final boldFont = pw.Font.ttf(boldData.buffer.asByteData());

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Text(
              title,
              style: pw.TextStyle(font: boldFont, fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Text(
              body,
              style: pw.TextStyle(font: font, fontSize: 13),
            ),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final file = File(directory.path + '/' + safeName);
    await file.writeAsBytes(await document.save(), flush: true);
    return file;
  }

  static Future<File> exportConversationPdf(
    List<dynamic> messages, {
    String fileName = 'mudabbir-conversation.pdf',
  }) {
    return writeTextPdf(
      title: 'مُدَبِّر — تقرير المحادثة',
      body: exportConversation(messages),
      fileName: fileName,
    );
  }

  static Future<File> exportBookmarksPdf(
    List<Map<String, dynamic>> bookmarks, {
    String fileName = 'mudabbir-bookmarks.pdf',
  }) {
    return writeTextPdf(
      title: 'مُدَبِّر — الآيات المفضلة',
      body: exportBookmarks(bookmarks),
      fileName: fileName,
    );
  }
}
