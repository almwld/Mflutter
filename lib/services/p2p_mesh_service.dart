import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

/// Local Nearby Connections lifecycle. Every connection request requires
/// explicit approval and allows the user to compare the authentication token
/// before accepting; no peer is silently trusted.
class P2PMeshService extends ChangeNotifier {
  P2PMeshService._();

  static final instance = P2PMeshService._();

  final Nearby _nearby = Nearby();
  final Map<String, String> _peers = {};
  final Map<String, ConnectionInfo> _pendingConnections = {};
  bool _advertising = false;
  bool _discovering = false;

  Map<String, String> get peers => Map.unmodifiable(_peers);
  Map<String, ConnectionInfo> get pendingConnections =>
      Map.unmodifiable(_pendingConnections);
  bool get isAdvertising => _advertising;
  bool get isDiscovering => _discovering;

  Future<bool> advertise({
    required String deviceName,
    String serviceId = 'com.mudabbir.alasrar.mesh',
  }) async {
    try {
      final ok = await _nearby.startAdvertising(
        deviceName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
        serviceId: serviceId,
      );
      _advertising = ok;
      notifyListeners();
      return ok;
    } catch (_) {
      _advertising = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> discover({
    String serviceId = 'com.mudabbir.alasrar.mesh',
  }) async {
    try {
      final ok = await _nearby.startDiscovery(
        serviceId,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (id, name, foundServiceId) {
          _peers[id] = name;
          notifyListeners();
        },
        onEndpointLost: (id) {
          _peers.remove(id);
          notifyListeners();
        },
      );
      _discovering = ok;
      notifyListeners();
      return ok;
    } catch (_) {
      _discovering = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> connect(String endpointId) async {
    try {
      return await _nearby.requestConnection(
        'مُدَبِّر',
        endpointId,
        onConnectionInitiated: _handleConnectionInitiated,
        onConnectionResult: _handleConnectionResult,
        onDisconnected: _handleDisconnected,
      );
    } catch (_) {
      return false;
    }
  }

  void _handleConnectionInitiated(String endpointId, ConnectionInfo info) {
    _peers[endpointId] = info.endpointName;
    // Both endpoints must explicitly approve the request. The UI exposes the
    // authentication token so users can compare it out-of-band first.
    _pendingConnections[endpointId] = info;
    notifyListeners();
  }

  Future<bool> _acceptConnection(String endpointId) async {
    try {
      return await _nearby.acceptConnection(
        endpointId,
        onPayLoadRecieved: (receivedEndpointId, payload) {
          // Payloads are not interpreted or executed by this service.
        },
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> acceptPendingConnection(String endpointId) async {
    if (!_pendingConnections.containsKey(endpointId)) return false;
    final accepted = await _acceptConnection(endpointId);
    if (accepted) {
      _pendingConnections.remove(endpointId);
      notifyListeners();
    }
    return accepted;
  }

  Future<bool> rejectPendingConnection(String endpointId) async {
    if (!_pendingConnections.containsKey(endpointId)) return false;
    try {
      final rejected = await _nearby.rejectConnection(endpointId);
      if (rejected) {
        _pendingConnections.remove(endpointId);
        notifyListeners();
      }
      return rejected;
    } catch (_) {
      return false;
    }
  }

  void _handleConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _peers[endpointId] = _peers[endpointId] ?? endpointId;
      _pendingConnections.remove(endpointId);
    } else {
      _pendingConnections.remove(endpointId);
    }
    notifyListeners();
  }

  void _handleDisconnected(String endpointId) {
    _peers.remove(endpointId);
    _pendingConnections.remove(endpointId);
    notifyListeners();
  }

  Future<bool> sendJson(String endpointId, Map<String, dynamic> data) async {
    try {
      await _nearby.sendBytesPayload(
        endpointId,
        Uint8List.fromList(utf8.encode(jsonEncode(data))),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _nearby.stopDiscovery();
    } finally {
      _discovering = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _nearby.stopAdvertising();
    } catch (_) {}
    try {
      await _nearby.stopDiscovery();
    } catch (_) {}
    _advertising = false;
    _discovering = false;
    notifyListeners();
  }
}
