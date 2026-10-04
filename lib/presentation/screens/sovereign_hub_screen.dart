import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/p2p_mesh_service.dart';
import '../../services/iot_sanctuary_service.dart';

class SovereignHubScreen extends StatefulWidget {
  const SovereignHubScreen({super.key});
  @override
  State<SovereignHubScreen> createState() => _SovereignHubScreenState();
}

class _SovereignHubScreenState extends State<SovereignHubScreen> {
  Map<String, String> _peers = {};
  bool _scanning = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('مركز السيادة', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: EdgeInsets.all(16), children: [
        _buildCard('🌐 شبكة P2P', _scanning ? 'جاري المسح...' : '${_peers.length} أجهزة قريبة', Icons.hub, () async {
          setState(() => _scanning = true);
          await P2PMeshService.instance.discover();
          _peers = Map<String, String>.from(P2PMeshService.instance.peers);
          setState(() => _scanning = false);
        }),
        _buildCard('🔐 التحقق الصوتي', 'غير مهيأ', Icons.fingerprint, () {
          setState(() => _status = 'التحقق الصوتي يحتاج محرك بصمة صوتية حقيقي مهيأ.');
        }),
        _buildCard('🏠 إنترنت الأشياء', IoTSanctuaryService.instance.isConfigured ? 'مهيأ' : 'غير مهيأ', Icons.home, () async {
          if (!IoTSanctuaryService.instance.isConfigured) {
            setState(() => _status = 'لم يتم إعداد نقطة اتصال إنترنت الأشياء بعد.');
            return;
          }
          try {
            final result = await IoTSanctuaryService.instance.discover();
            setState(() => _status = 'تم اكتشاف أجهزة إنترنت الأشياء: ${result['devices'] ?? result.length}');
          } catch (e) {
            setState(() => _status = 'تعذر اكتشاف أجهزة إنترنت الأشياء: $e');
          }
        }),
        if (_status.isNotEmpty) Container(margin: EdgeInsets.only(top: 16), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: Text(_status, style: TextStyle(color: Colors.white70))),
      ]),
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGold),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white54)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}
