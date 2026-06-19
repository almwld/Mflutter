class PdfExportService {
  static String exportConversation(List<dynamic> messages) {
    final buffer = StringBuffer();
    buffer.writeln('مُدَبِّر الْأَسْرَارِ الْعُلْيَا');
    buffer.writeln('تقرير المحادثة');
    buffer.writeln('═' * 30);
    
    for (final msg in messages) {
      final isUser = msg.isUser ?? false;
      final content = msg.content ?? '';
      final time = msg.timestamp?.toString()?.substring(0, 16) ?? '';
      
      buffer.writeln('');
      buffer.writeln(isUser ? '👤 أنت ($time):' : '🤖 مُدَبِّر ($time):');
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
      buffer.writeln('📖 ${b['text']}');
      buffer.writeln('📍 سورة ${b['surah']} - آية ${b['ayah']}');
      buffer.writeln('─' * 20);
    }
    
    return buffer.toString();
  }
}
