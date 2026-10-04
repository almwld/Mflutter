import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';

class P2PMeshService {
  P2PMeshService._();
  static final instance = P2PMeshService._();
  final Nearby _nearby = Nearby();
  final Map<String, String> _peers = {};
  bool _advertising = false, _discovering = false;
  Map<String, String> get peers => Map.unmodifiable(_peers);
  bool get isAdvertising => _advertising;
  bool get isDiscovering => _discovering;

  Future<bool> advertise({required String deviceName, String serviceId='com.mudabbir.alasrar.mesh'}) async {
    try {
      final ok = await _nearby.startAdvertising(deviceName, Strategy.P2P_CLUSTER,
        onConnectionInitiated: (id, info) async => _nearby.acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {}),
        onConnectionResult: (id, status) { if (status == Status.CONNECTED) _peers[id] = deviceName; },
        onDisconnected: (id) => _peers.remove(id), serviceId: serviceId);
      _advertising = ok; return ok;
    } catch (_) { return false; }
  }

  Future<bool> discover({String serviceId='com.mudabbir.alasrar.mesh'}) async {
    try {
      final ok = await _nearby.startDiscovery(serviceId, Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, serviceId) => _peers[id] = name,
        onEndpointLost: (id) => _peers.remove(id));
      _discovering = ok; return ok;
    } catch (_) { return false; }
  }

  Future<bool> connect(String endpointId) async {
    try {
      return await _nearby.requestConnection('مُدَبِّر', endpointId,
        onConnectionInitiated: (id, info) async => _nearby.acceptConnection(id, onPayLoadRecieved: (endpointId, payload) {}),
        onConnectionResult: (id, status) { if (status == Status.CONNECTED) _peers[id] = _peers[id] ?? id; },
        onDisconnected: (id) => _peers.remove(id));
    } catch (_) { return false; }
  }

  Future<bool> sendJson(String endpointId, Map<String, dynamic> data) async {
    try { await _nearby.sendBytesPayload(endpointId, Uint8List.fromList(utf8.encode(jsonEncode(data)))); return true; }
    catch (_) { return false; }
  }
  Future<void> stop() async {
    try { await _nearby.stopAdvertising(); } catch (_) {}
    try { await _nearby.stopDiscovery(); } catch (_) {}
    _advertising = false; _discovering = false;
  }
}
