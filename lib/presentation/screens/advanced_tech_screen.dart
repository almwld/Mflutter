import 'dart:async';

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
  final GeospatialInsightService _geo = GeospatialInsightService.instance;

  late Future<List<Map<String, dynamic>>> _capsulesFuture;
  bool _savingCapsule = false;
  bool _locationLoading = false;
  String _locationStatus = 'لم يُطلب إذن الموقع بعد.';
  String? _audioError;

  @override
  void initState() {
    super.initState();
    _capsulesFuture = TimeCapsuleService.getCapsules();
    _geo.addListener(_onGeoChanged);
  }

  @override
  void dispose() {
    _capsuleController.dispose();
    _geo.removeListener(_onGeoChanged);
    unawaited(_geo.stop());
    unawaited(BinauralEngineService.stop().catchError((_) {}));
    super.dispose();
  }

  void _onGeoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _saveCapsule() async {
    final text = _capsuleController.text.trim();
    if (text.isEmpty || _savingCapsule) return;
    setState(() => _savingCapsule = true);
    try {
      await TimeCapsuleService.sealCapsule(
        text,
        DateTime.now().add(const Duration(days: 30)),
      );
      if (!mounted) return;
      _capsuleController.clear();
      setState(() => _capsulesFuture = TimeCapsuleService.getCapsules());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حُفظت الرسالة محليًا لتظهر بعد 30 يومًا. التخزين غير مشفّر.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ الكبسولة: $error')),
      );
    } finally {
      if (mounted) setState(() => _savingCapsule = false);
    }
  }

  Future<void> _openCapsule(int index) async {
    final capsule = await TimeCapsuleService.tryUnlock(index);
    if (!mounted) return;
    if (capsule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يحِن موعد فتح هذه الكبسولة بعد.')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('كبسولة زمنية'),
        content: SelectableText(
          (capsule['content'] ?? '').toString(),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _runAudio(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      setState(() => _audioError = null);
    } catch (error) {
      if (!mounted) return;
      setState(() => _audioError = 'تعذر تشغيل الصوت: $error');
    }
  }

  Future<void> _startGeospatial() async {
    setState(() => _locationLoading = true);
    try {
      final started = await _geo.start();
      if (!mounted) return;
      setState(() {
        _locationStatus = started
            ? 'تم الحصول على موقع الجهاز.'
            : 'الموقع غير متاح أو لم يُمنح الإذن.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _locationStatus = 'تعذر قراءة الموقع: $error');
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _geo.position;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تقنيات متقدمة',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.surface,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'الكبسولات محفوظة محليًا دون تشفير. النغمات التالية هي أصوات ثنائية القناة وليست علاجًا مثبتًا أو ضمانًا لتحسين التركيز. بيانات الموقع تُعرض فقط بعد طلب الإذن من النظام.',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'كبسولة زمنية',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _capsuleController,
                    textDirection: TextDirection.rtl,
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة لنفسك في المستقبل...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savingCapsule ? null : _saveCapsule,
                      child: Text(
                        _savingCapsule ? 'جارٍ الحفظ…' : 'حفظ لمدة 30 يومًا',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _capsulesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Text(
                              'تعذر تحميل الكبسولات: ${snapshot.error}',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _capsulesFuture = TimeCapsuleService.getCapsules(),
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }
                      final capsules = snapshot.data!;
                      if (capsules.isEmpty) {
                        return const Text(
                          'لا توجد كبسولات محفوظة.',
                          style: TextStyle(color: Colors.white54),
                        );
                      }
                      return Column(
                        children: capsules.asMap().entries.map((entry) {
                          final index = entry.key;
                          final capsule = entry.value;
                          final unlock = DateTime.tryParse(
                            (capsule['unlockDate'] ?? '').toString(),
                          );
                          final locked = unlock == null ||
                              DateTime.now().isBefore(unlock);
                          final unlockText = unlock == null
                              ? 'موعد الفتح غير صالح'
                              : '${unlock.year}-${unlock.month.toString().padLeft(2, '0')}-${unlock.day.toString().padLeft(2, '0')}';
                          return ListTile(
                            leading: Icon(
                              locked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                              color: AppColors.primaryGold,
                            ),
                            title: Text(
                              locked
                                  ? 'رسالة مؤجلة حتى $unlockText'
                                  : (capsule['content'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            subtitle: Text(
                              locked ? 'النص مخفي حتى موعد الفتح' : 'جاهزة للعرض',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                            onTap: () => _openCapsule(index),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'صوت ثنائي القناة',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFreqButton('سكينة', BinauralEngineService.playTranquility),
                      _buildFreqButton('تركيز', BinauralEngineService.playFocus),
                      _buildFreqButton('تأمل', BinauralEngineService.playDeepMeditation),
                      _buildFreqButton('إيقاف', BinauralEngineService.stop),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    BinauralEngineService.playing
                        ? 'النغمة تعمل • فرق القناتين: ${BinauralEngineService.frequency.toStringAsFixed(2)} Hz'
                        : 'الصوت متوقف',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  if (_audioError != null)
                    Text(
                      _audioError!,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'البيانات الجغرافية',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (position == null)
                    Text(
                      _locationStatus,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white54),
                    )
                  else ...[
                    Text(
                      'خط العرض: ${position.latitude.toStringAsFixed(5)} • خط الطول: ${position.longitude.toStringAsFixed(5)}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'الارتفاع: ${position.altitude.toStringAsFixed(1)} متر',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'تصنيف تضاريس تقريبي حسب الارتفاع: ${_geo.getTopography()}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _locationLoading ? null : _startGeospatial,
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(_locationLoading ? 'جارٍ تحديد الموقع…' : 'طلب الموقع وتحديثه'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreqButton(String label, Future<void> Function() action) {
    return ElevatedButton(
      onPressed: () => _runAudio(action),
      child: Text(label),
    );
  }
}
