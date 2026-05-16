import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/quran_provider.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.surahs.length,
            itemBuilder: (context, index) {
              final surah = provider.surahs[index];
              return Card(
                color: AppColors.surface,
                child: ListTile(
                  title: Text('${surah['name']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  subtitle: Text('${surah['versesCount']} آية', style: const TextStyle(color: Colors.white54)),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold,
                    child: Text('${surah['number']}', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => provider.loadVersesBySurah(surah['number']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
