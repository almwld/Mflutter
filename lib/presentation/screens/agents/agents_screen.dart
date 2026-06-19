import 'package:flutter/material.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('🧠 الوكلاء', style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        children: [
          _agentCard('📖 التفسير', 'يفسر القرآن بالقرآن', '127 وكيل نشط', Icons.menu_book),
          _agentCard('🌌 الفلك', 'آيات النجوم والكواكب', '202 آية', Icons.stars),
          _agentCard('🧘 النفس', 'القلب والروح', '346 آية', Icons.psychology),
          _agentCard('🌱 الحياة', 'خلق الإنسان', '565 آية', Icons.eco),
          _agentCard('📜 التاريخ', 'قصص الأنبياء', '1057 آية', Icons.history),
          _agentCard('⚖️ الفقه', 'الأحكام', '59 آية', Icons.gavel),
          _agentCard('💎 الأخلاق', 'القيم', '164 آية', Icons.diamond),
          _agentCard('🔢 الجمل', 'حساب الجمل', '183 آية', Icons.calculate),
          _agentCard('🗣️ البلاغة', 'أساليب البيان', '6236 آية', Icons.format_quote),
          _agentCard('🔮 الأسرار', 'الحروف المقطعة', '29 سورة', Icons.vpn_key),
          _agentCard('🌙 الليل', 'آيات السكون', '92 آية', Icons.nights_stay),
          _agentCard('☀️ النهار', 'آيات المعاش', '57 آية', Icons.wb_sunny),
        ],
      ),
    );
  }

  Widget _agentCard(String title, String desc, String stats, IconData icon) {
    return Card(
      color: const Color(0xFF1A237E).withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFFD700), width: 0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(stats, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
