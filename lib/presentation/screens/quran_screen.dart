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
  int? _selectedSurah;

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
        title: Text('القرآن الكريم', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
          }
          if (_selectedSurah != null) {
            return _buildVersesList(provider);
          }
          return _buildSurahsList(provider);
        },
      ),
    );
  }

  Widget _buildSurahsList(QuranProvider provider) {
    return ListView.builder(
      itemCount: provider.surahs.length,
      itemBuilder: (context, index) {
        final s = provider.surahs[index];
        final num = s['surah'] ?? index + 1;
        final name = s['surah_name'] ?? 'سورة $num';
        return ListTile(
          onTap: () {
            setState(() => _selectedSurah = num);
            provider.loadVersesBySurah(num);
          },
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryNavy,
            child: Text('$num', style: TextStyle(color: AppColors.primaryGold)),
          ),
          title: Text(name, style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildVersesList(QuranProvider provider) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: AppColors.primaryNavy,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryGold),
                onPressed: () => setState(() => _selectedSurah = null),
              ),
              Text('سورة $_selectedSurah', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.verses.length,
            itemBuilder: (context, index) {
              final v = provider.verses[index];
              return Card(
                margin: EdgeInsets.all(8),
                color: AppColors.surface,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(v.text, style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Amiri')),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
