import 'dart:convert';
import 'package:beotura/classes/organiser_location_class.dart';
import 'package:beotura/classes/protest_alert_class.dart';
import 'package:beotura/classes/protest_location_class.dart';
import 'package:beotura/services/ble_mesh_service.dart';
import 'package:beotura/services/websocket_connection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CombinedCommunicationService {
  final BluetoothMeshService _bleMeshService;
  final ProtestWebSocketService _webSocketService;
  bool _isWebSocketConnected = true;
  bool _disposed = false;

  DateTime? _lastLocationUpdate;
  static const Duration _locationUpdateThrottle = Duration(seconds: 4);

  CombinedCommunicationService({
    required WidgetRef ref,
    required Function(OrganizerNotification) onNewNotification,
    required Function(ProtestAlert) onNewAlert,
    required Function(String, ProtestAlert) onYourAlert,
    required Function(String) onAlertStopped,
    required Function(
            List<OrganizerNotification>, Map<String, ProtestAlert>, int)
        onStateUpdate,
  })  : _bleMeshService = BluetoothMeshService(),
        _webSocketService = ProtestWebSocketService(
          ref: ref,
          onNewNotification: onNewNotification,
          onNewAlert: onNewAlert,
          onYourAlert: onYourAlert,
          onAlertStopped: onAlertStopped,
          onStateUpdate: onStateUpdate,
          onLocationUpdate: (String id, ProtestLocation location) {},
          onUserCountUpdate: (int count) {},
          onUserDisconnected: (String id) {},
          onOrganizerRegistered: () {},
          onError: (String error) {},
        ) {
    _initialize();
  }

  void _initialize() {
    // Start BLE mesh service
    _bleMeshService.startService();

    // Initialize WebSocket connection
    _webSocketService.connect();

    // Monitor WebSocket connection status through the service
    _webSocketService.onConnectionStatusChanged = (bool isConnected) {
      _updateConnectionStatus(isConnected);
    };
  }

  void startInForeground() {
    debugPrint('CombinedCommunicationService: Starting foreground service');
    // Only initialize WebSocket if not already connected
    if (!_isWebSocketConnected) {
      _webSocketService.connect();
    }
    _bleMeshService.startService();
  }

  void sendAlert({required String type, required LatLng location}) {
    debugPrint(
        'CombinedCommunicationService: Sending alert - Type: $type, Location: $location');
    debugPrint(
        'CombinedCommunicationService: WebSocket connected: $_isWebSocketConnected');

    final alertData = {
      'type': type,
      'location': {
        'lat': location.latitude,
        'lng': location.longitude,
      },
    };

    bool webSocketSent = false;

    // Try WebSocket first
    if (_isWebSocketConnected) {
      try {
        debugPrint('CombinedCommunicationService: Sending via WebSocket');
        _webSocketService.sendAlert(type: type, location: location);
        webSocketSent = true;
        debugPrint(
            'CombinedCommunicationService: Successfully sent via WebSocket');
      } catch (e) {
        debugPrint('CombinedCommunicationService: WebSocket send failed: $e');
        _isWebSocketConnected = false; // Mark as disconnected on error
      }
    } else {
      debugPrint('CombinedCommunicationService: WebSocket not connected');
    }

    // Always send through BLE mesh as backup
    try {
      debugPrint('CombinedCommunicationService: Sending via BLE mesh');
      _bleMeshService.broadcastMessage('alert', alertData);
    } catch (e) {
      debugPrint('CombinedCommunicationService: BLE mesh send failed: $e');
      if (!webSocketSent) {
        // If both methods failed, throw error
        throw Exception('Failed to send alert through any channel');
      }
    }
  }

  void sendNotification({
    required String title,
    required String content,
    required String severity,
    LatLng? location,
  }) {
    final notification = {
      'title': title,
      'content': content,
      'severity': severity,
      if (location != null)
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
    };

    if (_isWebSocketConnected) {
      _webSocketService.sendNotification(
        title: title,
        content: content,
        severity: severity,
        location: location,
      );
    }
    _bleMeshService.broadcastMessage('notification', notification);
  }

  void sendLocationUpdate(Position position) {
    // Throttle updates to prevent rapid firing
    final now = DateTime.now();
    if (_lastLocationUpdate != null &&
        now.difference(_lastLocationUpdate!) < _locationUpdateThrottle) {
      return;
    }
    _lastLocationUpdate = now;

    final locationData = {
      'location': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
    };

    if (_isWebSocketConnected) {
      try {
        debugPrint('CombinedCommunicationService: Sending location update');
        _webSocketService.channel.sink.add(jsonEncode(locationData));
      } catch (e) {
        debugPrint(
            'CombinedCommunicationService: Error sending location update: $e');
      }
    }

    // Send through BLE mesh as backup
    try {
      _bleMeshService.broadcastMessage('location', locationData['location']!);
    } catch (e) {
      debugPrint(
          'CombinedCommunicationService: Error sending location via BLE: $e');
    }
  }

  void stopAlert(String alertId) {
    if (_isWebSocketConnected) {
      _webSocketService.channel.sink.add(jsonEncode({
        "stop_alert": true,
        "alert_id": alertId,
      }));
    }
    // Send through BLE mesh as backup
    _bleMeshService.broadcastMessage('stop_alert', {
      'alert_id': alertId,
    });
  }

  void sendToken(String token) {
    if (_isWebSocketConnected) {
      debugPrint('CombinedCommunicationService: Sending auth token');
      _webSocketService.sendToken(token);
    }
  }

  void registerAsOrganizer() {
    if (_isWebSocketConnected) {
      debugPrint('CombinedCommunicationService: Registering as organizer');
      _webSocketService.registerAsOrganizer();
    }
  }

  void dispose() {
    debugPrint('CombinedCommunicationService: Disposing...');
    _disposed = true;
    // First stop the BLE service
    _bleMeshService.dispose();
    
    // Then close WebSocket connection
    if (_isWebSocketConnected) {
      debugPrint('CombinedCommunicationService: Closing WebSocket connection');
      _webSocketService.dispose();
    }
    
    _isWebSocketConnected = false;
  }

  void _updateConnectionStatus(bool isConnected) {
    if (!_disposed) {
      _isWebSocketConnected = isConnected;
    }
  }

  set onNewAlert(Function(ProtestAlert) handler) {
    _webSocketService.onNewAlert = handler;
  }

  set onNewNotification(Function(OrganizerNotification) handler) {
    _webSocketService.onNewNotification = handler;
  }
}
