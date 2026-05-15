import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/dream_journal_service.dart';
import '../../services/quantum_entanglement_service.dart';
import '../../services/biorhythm_service.dart';
import '../../services/celestial_sync_service.dart';

class CosmicServicesScreen extends StatefulWidget {
  const CosmicServicesScreen({super.key});
  @override
  State<CosmicServicesScreen> createState() => _CosmicServicesScreenState();
}

class _CosmicServicesScreenState extends State<CosmicServicesScreen> {
  final TextEditingController _dreamController = TextEditingController();
  final TextEditingController _emotionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bio = BiorhythmService.calculate(DateTime(1990, 1, 1));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('الخدمات الكونية', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: EdgeInsets.all(16), children: [
        // مذكرات الأحلام
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🌙 مذكرات الأحلام', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _dreamController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'صف حلمك...', hintStyle: TextStyle(color: Colors.white38))),
          SizedBox(height: 8),
          TextField(controller: _emotionController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'المشاعر المصاحبة...', hintStyle: TextStyle(color: Colors.white38))),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () { DreamJournalService.addDream(_dreamController.text, _emotionController.text); _dreamController.clear(); _emotionController.clear(); setState(() {}); }, child: Text('حفظ الحلم')),
          SizedBox(height: 8),
          ...DreamJournalService.dreams.map((d) => ListTile(title: Text('💭 ${d['dream']}'.substring(0, 40), style: TextStyle(color: Colors.white54)), subtitle: Text('📖 ${d['verse']}'.substring(0, 40), style: TextStyle(color: AppColors.primaryGold)))),
        ]))),
        // التشابك الكمي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🔮 التشابك الكمي الدلالي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('آية اليوم المتشابكة:', style: TextStyle(color: Colors.white54)),
          Text(QuantumEntanglementService.getRandomVerse(), style: TextStyle(color: AppColors.primaryGold, fontSize: 16, fontFamily: 'Amiri')),
        ]))),
        // الإيقاع الحيوي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🔄 الإيقاع الحيوي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildBioBar('جسدي', bio['physical'] ?? 0),
          _buildBioBar('عاطفي', bio['emotional'] ?? 0),
          _buildBioBar('فكري', bio['intellectual'] ?? 0),
          _buildBioBar('روحاني', bio['spiritual'] ?? 0, isGold: true),
          SizedBox(height: 8),
          Text(BiorhythmService.interpretBiorhythm(bio), style: TextStyle(color: Colors.white70)),
        ]))),
        // المزامنة الفلكية
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🌌 المزامنة الفلكية', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(CelestialSyncService.getCurrentCelestialPhase(), style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 8),
          Text(CelestialSyncService.getVerseForPhase(), style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontFamily: 'Amiri')),
        ]))),
      ]),
    );
  }

  Widget _buildBioBar(String label, double value, {bool isGold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.white54))),
        Expanded(child: LinearProgressIndicator(value: (value + 1) / 2, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation<Color>(isGold ? AppColors.primaryGold : AppColors.primaryNavyLight))),
        SizedBox(width: 8),
        Text('${(value * 100).toStringAsFixed(0)}%', style: TextStyle(color: isGold ? AppColors.primaryGold : Colors.white54, fontSize: 12)),
      ]),
    );
  }
}
