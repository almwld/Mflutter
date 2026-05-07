import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/quran_provider.dart';
import '../widgets/quran/verse_card.dart';
import '../widgets/common/loading_indicator.dart';

/// =============================================================================
/// QuranBrowserScreen - شاشة متصفح القرآن
/// =============================================================================

class QuranBrowserScreen extends StatefulWidget {
  const QuranBrowserScreen({super.key});

  @override
  State<QuranBrowserScreen> createState() => _QuranBrowserScreenState();
}

class _QuranBrowserScreenState extends State<QuranBrowserScreen> {
  int? _selectedSurah;
  final TextEditingController _searchController = TextEditingController();

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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.surahs.isEmpty) {
            return const LoadingIndicator(
              message: 'جاري تحميل القرآن الكريم...',
            );
          }

          return Column(
            children: [
              // شريط البحث
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primaryNavy.withOpacity(0.05),
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'بحث في القرآن...',
                    hintStyle: const TextStyle(fontFamily: 'Cairo'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    provider.search(value);
                  },
                ),
              ),
              // قائمة السور أو الآيات
              Expanded(
                child: _selectedSurah != null
                    ? _buildVersesList(provider)
                    : _buildSurahsList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSurahsList(QuranProvider provider) {
    return ListView.builder(
      itemCount: provider.surahs.length,
      itemBuilder: (context, index) {
        final surah = provider.surahs[index];
        return ListTile(
          onTap: () {
            setState(() {
              _selectedSurah = surah.number;
            });
            provider.loadSurahVerses(surah.number);
          },
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryNavy,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${surah.number}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ),
          title: Text(
            surah.name,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              color: AppColors.primaryNavy,
            ),
          ),
          subtitle: Text(
            surah.info,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Text(
            '${surah.ayahCount} آية',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersesList(QuranProvider provider) {
    return Column(
      children: [
        // شريط عنوان السورة
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primaryNavy,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
                onPressed: () {
                  setState(() {
                    _selectedSurah = null;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'سورة ${_selectedSurah}',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        // قائمة الآيات
        Expanded(
          child: provider.isLoading
              ? const LoadingIndicator()
              : ListView.builder(
                  itemCount: provider.currentVerses.length,
                  itemBuilder: (context, index) {
                    final verse = provider.currentVerses[index];
                    return VerseCard(
                      verse: verse,
                      showSurahName: false,
                      onTap: () => _showVerseDetails(verse),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showVerseDetails(dynamic verse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'سورة ${verse.surahNumber} - آية ${verse.ayahNumber}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.textWithDiacritics,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 28,
                  color: AppColors.primaryNavy,
                  height: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChip('الجزء ${verse.juzNumber}'),
                const SizedBox(width: 12),
                _buildChip(verse.isMakki ? 'مكية' : 'مدنية'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'بحث في القرآن',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'أدخل كلمة البحث...',
            hintStyle: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<QuranProvider>().search(_searchController.text);
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }
}