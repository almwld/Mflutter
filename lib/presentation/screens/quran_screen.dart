import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/verse.dart';
import '../../services/quran_loader_service.dart';
import '../../services/sensor_service.dart';
import '../painters/ayah_visual_painter.dart';
import '../painters/gold_fluid_sim.dart';
import '../painters/nebula_particles.dart';
import '../painters/kinetic_resonance.dart';
import '../painters/gravitational_lensing.dart';
import '../painters/mesh_pulse.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with TickerProviderStateMixin {
  List<Ayah> _ayahs = [];
  Map<int, List<Ayah>> _bySurah = {};
  int _selectedSurah = 1;
  int _currentPage = 0;
  bool _loading = true;

  final SensorService _sensor = SensorService();
  late AnimationController _breathController;
  double _scrollVelocity = 0.0;

  // الأنظمة البصرية
  final GoldFluidSimulation _fluidSim = GoldFluidSimulation();
  final NebulaParticleSystem _nebulaSystem = NebulaParticleSystem();
  final KineticResonanceSystem _resonanceSystem = KineticResonanceSystem();
  final GravitationalLensingEffect _lensingEffect = GravitationalLensingEffect();
  final MeshPulseSystem _meshPulseSystem = MeshPulseSystem();

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _sensor.startListening();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    _bySurah = await QuranLoaderService.loadBySurah();
    _ayahs = await QuranLoaderService.loadAllAyahs();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _sensor.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)));
    }

    final surahs = _bySurah.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.list, color: AppColors.primaryGold),
            onSelected: (surahNum) => setState(() { _selectedSurah = surahNum; _currentPage = 0; }),
            itemBuilder: (_) => surahs.map((s) {
              final verses = _bySurah[s]!;
              return PopupMenuItem(value: s, child: Text('${verses.first.surahName} (${verses.length} آية)', style: const TextStyle(color: Colors.white)));
            }).toList(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _breathController,
        builder: (context, _) {
          final currentAyahs = _bySurah[_selectedSurah] ?? [];
          if (currentAyahs.isEmpty) return const Center(child: Text('لا توجد آيات', style: TextStyle(color: Colors.white54)));

          return PageView.builder(
            itemCount: currentAyahs.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) => _buildAyahCard(currentAyahs[index]),
          );
        },
      ),
      bottomNavigationBar: _bySurah[_selectedSurah] != null
          ? Container(padding: const EdgeInsets.all(8), color: AppColors.surface,
              child: Text('${_currentPage + 1} / ${_bySurah[_selectedSurah]!.length}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primaryGold)))
          : null,
    );
  }

  Widget _buildAyahCard(Ayah ayah) {
    // تحديث تأثير الجاذبية للآيات الثقيلة
    _lensingEffect.setMassCenter(Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2), ayah.jummal.toDouble());

    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: AyahVisualPainter(
                ayahText: ayah.text,
                jummal: ayah.jummal,
                axisType: ayah.axisType,
                energyLevel: ayah.energyLevel,
                pitch: _sensor.pitch,
                roll: _sensor.roll,
                breathPhase: _breathController.value * 2 * 3.14159,
                scrollVelocity: _scrollVelocity,
                ambientLight: 0.5,
                longPressPosition: null,
                relatedWordPositions: null,
                voiceAmplitude: 0.0,
                voiceFrequency: 440.0,
                fluidSim: _fluidSim,
                nebulaSystem: _nebulaSystem,
                resonanceSystem: _resonanceSystem,
                lensingEffect: _lensingEffect,
                meshPulseSystem: _meshPulseSystem,
              ),
              size: Size.infinite,
            ),
          ),
          Positioned(
            bottom: 16, right: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${ayah.surahName} - ${ayah.ayahNumber}', style: const TextStyle(color: AppColors.primaryGold, fontSize: 14)),
              Text('جمل: ${ayah.jummal} | محور: ${ayah.axisType == 'cosmic' ? '🌌 كوني' : ayah.axisType == 'tranquil' ? '🌙 سكينة' : '📐 حساب'}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ),
          Positioned(
            top: 12, left: 12,
            child: Container(width: 4, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.white.withAlpha(20)),
              child: Align(alignment: Alignment.bottomCenter,
                child: Container(height: 100 * ayah.energyLevel, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [AppColors.primaryGold, Colors.orange]))))),
          ),
        ],
      ),
    );
  }
}
