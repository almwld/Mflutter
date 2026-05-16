import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/verse.dart';
import '../../services/quran_loader_service.dart';
import '../../services/sensor_service.dart';

/// شاشة القرآن الكريم — نسخة مبسطة بدون تأثيرات خارجية
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with TickerProviderStateMixin {
  Map<int, List<Ayah>> _bySurah = {};
  int _selectedSurah = 1, _currentPage = 0;
  bool _loading = true;
  final _sensor = SensorService();
  late final _breathCtrl = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();

  @override
  void initState() {
    super.initState();
    _sensor.startListening();
    _load();
  }

  Future<void> _load() async {
    _bySurah = await QuranLoaderService.loadBySurah();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _sensor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)));

    final surahs = _bySurah.keys.toList()..sort();
    final ayahs = _bySurah[_selectedSurah] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.list, color: AppColors.primaryGold),
            onSelected: (s) => setState(() { _selectedSurah = s; _currentPage = 0; }),
            itemBuilder: (_) => surahs.map((s) => PopupMenuItem(value: s, child: Text('${_bySurah[s]!.first.surahName} (${_bySurah[s]!.length})', style: const TextStyle(color: Colors.white)))).toList(),
          ),
        ],
      ),
      body: ayahs.isEmpty
          ? const Center(child: Text('لا توجد آيات', style: TextStyle(color: Colors.white54)))
          : PageView.builder(
              itemCount: ayahs.length,
              onPageChanged: (p) => _currentPage = p,
              itemBuilder: (_, i) {
                final a = ayahs[i];
                return _buildVerseCard(a);
              },
            ),
      bottomNavigationBar: Container(padding: const EdgeInsets.all(8), color: AppColors.surface, child: Text('${_currentPage + 1} / ${ayahs.length}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primaryGold))),
    );
  }

  Widget _buildVerseCard(Ayah a) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    a.text,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Amiri', fontWeight: FontWeight.bold, height: 1.8),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('${a.surahName} - الآية ${a.ayahNumber}', style: const TextStyle(color: AppColors.primaryGold, fontSize: 14)),
            Text('جمل: ${a.jummal} | محور: ${a.axisType == 'cosmic' ? '🌌 كوني' : a.axisType == 'tranquil' ? '🌙 سكينة' : '📐 حساب'}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
