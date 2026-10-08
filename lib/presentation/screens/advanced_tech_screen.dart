import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/time_capsule_service.dart';
import '../../services/binaural_engine_service.dart';
import '../../services/geospatial_insight_service.dart';

class AdvancedTechScreen extends StatefulWidget {
  const AdvancedTechScreen({super.key});
  @override
  State<AdvancedTechScreen> createState() => _AdvancedTechScreenState();
}

class _AdvancedTechScreenState extends State<AdvancedTechScreen> {
  final TextEditingController _capsuleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('تقنيات متقدمة', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: EdgeInsets.all(16), children: [
        // الكبسولة الزمنية
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('⏳ كبسولة زمنية', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(controller: _capsuleController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'اكتب رسالة لنفسك في المستقبل...', hintStyle: TextStyle(color: Colors.white38))),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () { TimeCapsuleService.sealCapsule(_capsuleController.text, DateTime.now().add(Duration(days: 30))); _capsuleController.clear(); setState(() {}); }, child: Text('ختم الكبسولة لمدة ٣٠ يوماً')),
          SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: TimeCapsuleService.getCapsules(),
            builder: (context, snapshot) {
              final capsules = snapshot.data ?? const <Map<String, dynamic>>[];
              return Column(children: capsules.map((c) {
                final content = (c['content'] ?? '').toString();
                final unlock = (c['unlockDate'] ?? '').toString();
                return ListTile(
                  title: Text(content.length > 40 ? content.substring(0, 40) : content, style: const TextStyle(color: Colors.white54)),
                  subtitle: Text(unlock.length > 16 ? unlock.substring(0, 16) : unlock, style: const TextStyle(color: Colors.white24)),
                );
              }).toList());
            },
          ),
        ]))),
        // الترددات الصوتية
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🎵 صوت ثنائي القناة', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildFreqButton('سكينة', BinauralEngineService.playTranquility),
            _buildFreqButton('تركيز', BinauralEngineService.playFocus),
            _buildFreqButton('تأمل', BinauralEngineService.playDeepMeditation),
            _buildFreqButton('إيقاف', BinauralEngineService.stop),
          ]),
          SizedBox(height: 8),
          Text(BinauralEngineService.playing ? 'النمط الحالي: ${BinauralEngineService.currentMode}' : 'متوقف', style: TextStyle(color: Colors.white54)),
        ]))),
        // الاستنباط الجغرافي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🌍 استنباط جغرافي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('التضاريس: ${GeospatialInsightService.instance.getTopography()}', style: TextStyle(color: Colors.white70)),
          Text('الارتفاع: ${GeospatialInsightService.instance.altitude}m', style: TextStyle(color: Colors.white54)),
          SizedBox(height: 8),

        ]))),
      ]),
    );
  }

  Widget _buildFreqButton(String label, VoidCallback onTap) {
    return ElevatedButton(onPressed: () { onTap(); setState(() {}); }, child: Text(label));
  }
}
