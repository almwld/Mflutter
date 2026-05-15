class P2PMeshService {
  static final List<Map<String, String>> _peers = [];
  static bool _isScanning = false;

  static bool get isScanning => _isScanning;

  static Future<List<Map<String, String>>> scanNearbyPeers() async {
    _isScanning = true;
    await Future.delayed(Duration(seconds: 3));
    _peers.clear();
    _peers.addAll([
      {'name': 'مُدَبِّر_أحمد', 'device': 'Galaxy S24', 'distance': '5m'},
      {'name': 'مُدَبِّر_فاطمة', 'device': 'Pixel 9', 'distance': '12m'},
    ]);
    _isScanning = false;
    return _peers;
  }

  static Future<String> shareInsight(Map<String, String> insight) async {
    return 'تمت مشاركة البصيرة مع ${_peers.length} أجهزة قريبة';
  }
}
