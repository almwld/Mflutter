import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

/// Local Nearby Connections lifecycle. Every connection request requires
/// explicit approval and allows the user to compare the authentication token
/// before accepting; no peer is silently trusted.
class P2PMeshService extends ChangeNotifier {
  P2PMeshService._();

  static final instance = P2PMeshService._();

  final Nearby _nearby = Nearby();
  final Map<String, String> _peers = {};
  final Map<String, ConnectionInfo> _pendingConnections = {};
  final Set<String> _connectedPeers = <String>{};
  bool _advertising = false;
  bool _discovering = false;

  Map<String, String> get peers => Map.unmodifiable(_peers);
  Map<String, ConnectionInfo> get pendingConnections =>
      Map.unmodifiable(_pendingConnections);
  Set<String> get connectedPeers => Set.unmodifiable(_connectedPeers);
  bool get isAdvertising => _advertising;
  bool get isDiscovering => _discovering;

  Future<bool> _ensureNearbyPermissions() async {
    final statuses = await <Permission>[
      Permission.locationWhenInUse,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    final legacyBluetooth = statuses[Permission.bluetooth]?.isGranted == true;
    final scan = statuses[Permission.bluetoothScan]?.isGranted == true;
    final connect = statuses[Permission.bluetoothConnect]?.isGranted == true;
    final advertise = statuses[Permission.bluetoothAdvertise]?.isGranted == true;
    final location = statuses[Permission.locationWhenInUse]?.isGranted == true;
    return (scan || legacyBluetooth) &&
        (connect || legacyBluetooth) &&
        (advertise || legacyBluetooth) &&
        location;
  }

  Future<bool> advertise({
    required String deviceName,
    String serviceId = 'com.mudabbir.alasrar.mesh',
  }) async {
    try {
      if (!await _ensureNearbyPermissions()) {
        _advertising = false;
        notifyListeners();
        return false;
      }
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
      if (!await _ensureNearbyPermissions()) {
        _discovering = false;
        notifyListeners();
        return false;
      }
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
      if (!await _ensureNearbyPermissions()) return false;
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
      _connectedPeers.add(endpointId);
    } else {
      _connectedPeers.remove(endpointId);
    }
    _pendingConnections.remove(endpointId);
    notifyListeners();
  }

  void _handleDisconnected(String endpointId) {
    _peers.remove(endpointId);
    _pendingConnections.remove(endpointId);
    _connectedPeers.remove(endpointId);
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

  Future<void> stopAdvertising() async {
    try {
      await _nearby.stopAdvertising();
    } finally {
      _advertising = false;
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
