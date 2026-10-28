import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/quran_loader_service.dart';

/// Minimal audio contract keeps the screen testable without a native audio
/// plugin; the production adapter below delegates to audioplayers.
abstract interface class RecitationAudioEngine {
  Stream<void> get onPlayerComplete;
  Future<void> setReleaseMode(ReleaseMode mode);
  Future<void> stop();
  Future<void> playUrl(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}

class AudioplayersRecitationEngine implements RecitationAudioEngine {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  @override
  Future<void> setReleaseMode(ReleaseMode mode) => _player.setReleaseMode(mode);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> playUrl(String url) => _player.play(UrlSource(url));

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> dispose() => _player.dispose();
}

class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key, this.audioEngineFactory});

  final RecitationAudioEngine Function()? audioEngineFactory;

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  List<({String name, int number, int ayahs})> _surahs = [];
  bool _loadingSurahList = true;
  String? _surahListError;

  late final RecitationAudioEngine _player;
  StreamSubscription<void>? _completionSubscription;
  int? _currentIndex;
  int _currentAyah = 1;
  int _generation = 0;
  bool _playing = false;
  bool _paused = false;
  bool _loading = false;
  bool _stoppedByUser = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = widget.audioEngineFactory?.call() ?? AudioplayersRecitationEngine();
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
    unawaited(_loadSurahs());
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      if (!_stoppedByUser && _playing && !_paused) unawaited(_playNextAyah());
    });
  }

  Future<void> _loadSurahs() async {
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      final names = <int, String>{};
      final counts = <int, int>{};
      for (final ayah in ayahs) {
        names.putIfAbsent(ayah.surahNumber, () => ayah.surahName);
        counts.update(ayah.surahNumber, (count) => count + 1, ifAbsent: () => 1);
      }
      final numbers = names.keys.toList()..sort();
      final loaded = numbers
          .map((number) => (
                name: names[number]!,
                number: number,
                ayahs: counts[number]!,
              ))
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _surahs = loaded;
        _loadingSurahList = false;
        _surahListError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingSurahList = false;
        _surahListError = 'تعذر تحميل قائمة السور من فهرس القرآن المحلي: $error';
      });
    }
  }

  String _ayahUrl(int surahNumber, int ayahNumber) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$surah$ayah.mp3';
  }

  Future<void> _selectSurah(int index) async {
    final generation = ++_generation;
    _stoppedByUser = false;
    _error = null;
    setState(() {
      _currentIndex = index;
      _currentAyah = 1;
      _playing = false;
      _paused = false;
      _loading = true;
    });
    try {
      await _player.stop();
      if (!mounted || generation != _generation) return;
      await _playCurrentAyah(generation);
    } catch (error) {
      _showPlaybackError(error, generation: generation);
    }
  }

  Future<void> _playCurrentAyah(int generation) async {
    final index = _currentIndex;
    if (index == null || generation != _generation || !mounted) return;
    final surah = _surahs[index];
    setState(() { _loading = true; _error = null; });
    try {
      await _player.playUrl(_ayahUrl(surah.number, _currentAyah));
      if (!mounted || generation != _generation) return;
      setState(() { _loading = false; _playing = true; _paused = false; });
    } catch (error) {
      _showPlaybackError(error, generation: generation);
    }
  }

  Future<void> _playNextAyah() async {
    // A completion event can arrive close to a user stop/pause action. Do not
    // advance the playlist after playback has been cancelled or paused.
    final index = _currentIndex;
    if (index == null ||
        !mounted ||
        _stoppedByUser ||
        !_playing ||
        _paused) {
      return;
    }
    if (_currentAyah >= _surahs[index].ayahs) {
      setState(() { _playing = false; _paused = false; _loading = false; });
      return;
    }
    setState(() => _currentAyah++);
    await _playCurrentAyah(_generation);
  }

  void _showPlaybackError(Object error, {int? generation}) {
    debugPrint('Recitation playback failed: $error');
    if (!mounted || (generation != null && generation != _generation)) return;
    setState(() {
      _playing = false;
      _paused = false;
      _loading = false;
      _error = 'تعذر تشغيل التلاوة. تحقق من اتصال الإنترنت ثم أعد المحاولة.';
    });
  }

  Future<void> _togglePause() async {
    final generation = _generation;
    try {
      if (_paused) {
        await _player.resume();
        if (mounted && generation == _generation) setState(() => _paused = false);
      } else {
        await _player.pause();
        if (mounted && generation == _generation) setState(() => _paused = true);
      }
    } catch (error) {
      _showPlaybackError(error, generation: generation);
    }
  }

  Future<void> _stopPlayback() async {
    _stoppedByUser = true;
    _generation++;
    try { await _player.stop(); } catch (_) {}
    if (!mounted) return;
    setState(() { _playing = false; _paused = false; _loading = false; });
  }

  @override
  void dispose() {
    _generation++;
    _completionSubscription?.cancel();
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex == null ? null : _surahs[_currentIndex!];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('التلاوة الصوتية'), backgroundColor: AppColors.primaryNavy),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryGold.withOpacity(.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('تلاوة مشاري العفاسي', textDirection: TextDirection.rtl,
                    style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('تشغيل متصل آيةً بعد آية للسور المختارة. يلزم اتصال بالإنترنت؛ لا يتم تنزيل الملفات أو حفظها تلقائياً.',
                    textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white70, height: 1.5)),
                  SizedBox(height: 6),
                  Text('المصدر الصوتي: EveryAyah.com', textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: Colors.red.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
                  title: Text(_error!, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    tooltip: 'إعادة المحاولة',
                    onPressed: _currentIndex == null ? null : () => _selectSurah(_currentIndex!),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          Expanded(
            child: _loadingSurahList
                ? const Center(child: CircularProgressIndicator())
                : _surahListError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _surahListError!,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _loadingSurahList = true;
                                    _surahListError = null;
                                  });
                                  unawaited(_loadSurahs());
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _surahs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final surah = _surahs[index];
                final selected = index == _currentIndex;
                return Material(
                  color: selected ? AppColors.primaryGold.withOpacity(.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: selected ? AppColors.primaryGold.withOpacity(.55) : Colors.white10),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryNavy,
                      child: Text('${surah.number}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(surah.name, textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text('${surah.ayahs} آيات', textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white60)),
                    trailing: selected && _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(selected && _playing && !_paused ? Icons.graphic_eq_rounded : Icons.play_circle_outline_rounded,
                            color: AppColors.primaryGold, size: 28),
                    onTap: () => _selectSurah(index),
                  ),
                );
              },
            ),
          ),
          if (current != null)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.primaryGold.withOpacity(.25))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(current.name, textDirection: TextDirection.rtl,
                            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('الآية $_currentAyah من ${current.ayahs}', textDirection: TextDirection.rtl,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _paused ? 'استئناف' : 'إيقاف مؤقت',
                      onPressed: _loading || !_playing ? null : _togglePause,
                      icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 30),
                    ),
                    IconButton(
                      tooltip: 'إيقاف التلاوة',
                      onPressed: _playing || _loading ? _stopPlayback : null,
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
