import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/local_embeddings_service.dart';
import '../../services/tafsir_generator_service.dart';
import '../../services/quranic_search_engine.dart';
import '../../services/model_finetuning_service.dart';

class AIAdvancedScreen extends StatefulWidget {
  const AIAdvancedScreen({super.key});
  @override
  State<AIAdvancedScreen> createState() => _AIAdvancedScreenState();
}

class _AIAdvancedScreenState extends State<AIAdvancedScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // فهرسة آيات تجريبية
    QuranicSearchEngine.indexVerses([
      {'text': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', 'surah': 'النور', 'ayah': '35'},
      {'text': 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ', 'surah': 'الذاريات', 'ayah': '47'},
      {'text': 'وَالْجِبَالَ أَوْتَادًا', 'surah': 'النبأ', 'ayah': '7'},
      {'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'surah': 'الإخلاص', 'ayah': '1'},
    ]);
    LocalEmbeddingsService.indexVerse('1', 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ');
    LocalEmbeddingsService.indexVerse('2', 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('ذكاء اصطناعي متقدم', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: EdgeInsets.all(16), children: [
        // البحث الدلالي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🔍 بحث دلالي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _searchController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'ابحث بالمعنى...', hintStyle: TextStyle(color: Colors.white38))),
          SizedBox(height: 8),
          ElevatedButton(onPressed: () { setState(() => _searchResults = LocalEmbeddingsService.searchSimilar(_searchController.text)); }, child: Text('بحث')),
          ..._searchResults.map((r) => ListTile(title: Text(r, style: TextStyle(color: Colors.white70)))),
        ]))),
        // مولد التفاسير
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('📖 مولد التفاسير', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(TafsirGeneratorService.generate('الفاتحة', 1), style: TextStyle(color: Colors.white70)),
          SizedBox(height: 4),
          Text(TafsirGeneratorService.generate('البقرة', 255), style: TextStyle(color: Colors.white70)),
          SizedBox(height: 4),
          Text(TafsirGeneratorService.generate('الإخلاص', 1), style: TextStyle(color: Colors.white70)),
        ]))),
        // إحصائيات البحث
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('📊 إحصائيات', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...QuranicSearchEngine.getWordFrequency().entries.take(5).map((e) => Text('${e.key}: ${e.value} مرة', style: TextStyle(color: Colors.white54))),
        ]))),
        // ضبط النموذج
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🧠 ضبط النموذج', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: ModelFineTuningService.isTraining ? null : () async {
              await ModelFineTuningService.startFineTuning(['آية 1', 'آية 2']);
              setState(() {});
            },
            child: Text(ModelFineTuningService.isTraining ? 'جاري التدريب...' : 'بدء الضبط الدقيق'),
          ),
          if (ModelFineTuningService.epochs > 0) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(value: ModelFineTuningService.epochs / 10, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
            SizedBox(height: 4),
            Text('Epoch ${ModelFineTuningService.epochs}/10 - Loss: ${ModelFineTuningService.loss.toStringAsFixed(4)}', style: TextStyle(color: Colors.white54)),
          ],
        ]))),
      ]),
    );
  }
}
