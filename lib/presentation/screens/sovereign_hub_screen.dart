import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/iot_sanctuary_service.dart';
import '../../services/p2p_mesh_service.dart';

class SovereignHubScreen extends StatefulWidget {
  const SovereignHubScreen({super.key});

  @override
  State<SovereignHubScreen> createState() => _SovereignHubScreenState();
}

class _SovereignHubScreenState extends State<SovereignHubScreen> {
  final P2PMeshService _mesh = P2PMeshService.instance;
  Map<String, String> _peers = {};
  bool _scanning = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _peers = Map<String, String>.from(_mesh.peers);
    _mesh.addListener(_onMeshChanged);
  }

  @override
  void dispose() {
    _mesh.removeListener(_onMeshChanged);
    super.dispose();
  }

  void _onMeshChanged() {
    if (!mounted) return;
    setState(() => _peers = Map<String, String>.from(_mesh.peers));
  }

  Future<void> _toggleDiscovery() async {
    if (_mesh.isDiscovering) {
      try {
        await _mesh.stopDiscovery();
        if (!mounted) return;
        setState(() => _status = 'تم إيقاف البحث عن الأجهزة القريبة.');
      } catch (error) {
        if (!mounted) return;
        setState(() => _status = 'تعذر إيقاف البحث: $error');
      }
      return;
    }
    await _discoverPeers();
  }

  Future<void> _discoverPeers() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _status = '';
    });
    try {
      final started = await _mesh.discover();
      if (!mounted) return;
      setState(() {
        _peers = Map<String, String>.from(_mesh.peers);
        _status = started
            ? 'البحث مستمر؛ ستظهر الأجهزة عند اكتشافها.'
            : 'تعذر بدء اكتشاف الأجهزة. تحقق من الأذونات ودعم الجهاز.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'تعذر اكتشاف أجهزة الشبكة المحلية: $error');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _connectPeer(String endpointId, String deviceName) async {
    setState(() => _status = 'جار إرسال طلب الاتصال إلى $deviceName…');
    final accepted = await _mesh.connect(endpointId);
    if (!mounted) return;
    setState(() {
      _status = accepted
          ? 'أُرسل طلب الاتصال إلى $deviceName؛ انتظر نتيجة الاتصال من الجهاز الآخر.'
          : 'تعذر إرسال طلب الاتصال إلى $deviceName.';
    });
  }

  Future<void> _discoverIoT() async {
    if (!IoTSanctuaryService.instance.isConfigured) {
      setState(() => _status = 'لم يتم إعداد نقطة اتصال إنترنت الأشياء بعد.');
      return;
    }
    try {
      final result = await IoTSanctuaryService.instance.discover();
      if (!mounted) return;
      setState(() => _status =
          'تم اكتشاف أجهزة إنترنت الأشياء: ${result['devices'] ?? result.length}');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'تعذر اكتشاف أجهزة إنترنت الأشياء: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final discovering = _mesh.isDiscovering;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'مركز السيادة',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            'شبكة P2P المحلية',
            _scanning
                ? 'جار بدء البحث…'
                : discovering
                    ? 'البحث مستمر • ${_peers.length} أجهزة مكتشفة'
                    : '${_peers.length} أجهزة قريبة',
            Icons.hub_rounded,
            _toggleDiscovery,
            trailing: Icon(
              discovering ? Icons.stop_circle_outlined : Icons.search_rounded,
              color: discovering ? Colors.redAccent : AppColors.primaryGold,
            ),
          ),
          if (_peers.isEmpty && discovering)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'بانتظار إعلانات الأجهزة القريبة…',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ..._peers.entries.map(
            (peer) => Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.devices_rounded,
                    color: AppColors.primaryGold),
                title: Text(peer.value,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'معرّف الطرف: ${peer.key}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                trailing: const Icon(Icons.link_rounded,
                    color: AppColors.primaryGold),
                onTap: () => _connectPeer(peer.key, peer.value),
              ),
            ),
          ),
          _buildCard(
            'التحقق الصوتي',
            'غير مهيأ — لا يوجد محرك بصمة صوتية فعّال',
            Icons.fingerprint_rounded,
            () => setState(() => _status =
                'التحقق الصوتي غير متاح حتى يُدمج محرك بصمة صوتية حقيقي ويُهيأ.'),
          ),
          _buildCard(
            'إنترنت الأشياء',
            IoTSanctuaryService.instance.isConfigured
                ? 'مهيأ'
                : 'غير مهيأ',
            Icons.home_outlined,
            _discoverIoT,
          ),
          if (_status.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _status,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGold),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}
