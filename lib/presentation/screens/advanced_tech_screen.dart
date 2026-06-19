import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/time_capsule_service.dart';
import '../../services/binaural_engine_service.dart';
import '../../services/gaze_tracking_service.dart';
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
          ...TimeCapsuleService.capsules.map((c) => ListTile(title: Text('📦 ${c['content']}'.substring(0, 40), style: TextStyle(color: Colors.white54)), subtitle: Text('تفتح: ${c['unlockDate']}'.substring(0, 16), style: TextStyle(color: Colors.white24)))),
        ]))),
        // الترددات الصوتية
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🎵 ترددات صوتية', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
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
        // تتبع العين
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('👁️ تتبع العين', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SwitchListTile(value: GazeTrackingService.isWatching, activeColor: AppColors.primaryGold, title: Text('تفعيل', style: TextStyle(color: Colors.white)), onChanged: (v) { v ? GazeTrackingService.startWatching() : GazeTrackingService.stopWatching(); setState(() {}); }),
          if (GazeTrackingService.focusedWord.isNotEmpty) Text('التركيز على: ${GazeTrackingService.focusedWord}', style: TextStyle(color: Colors.white54)),
        ]))),
        // الاستنباط الجغرافي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🌍 استنباط جغرافي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('التضاريس: ${GeospatialInsightService.topography}', style: TextStyle(color: Colors.white70)),
          Text('الارتفاع: ${GeospatialInsightService.altitude}m', style: TextStyle(color: Colors.white54)),
          SizedBox(height: 8),
          Text('📖 ${GeospatialInsightService.getVerseForTopography()}', style: TextStyle(color: AppColors.primaryGold, fontFamily: 'Amiri')),
        ]))),
      ]),
    );
  }

  Widget _buildFreqButton(String label, VoidCallback onTap) {
    return ElevatedButton(onPressed: () { onTap(); setState(() {}); }, child: Text(label));
  }
}
