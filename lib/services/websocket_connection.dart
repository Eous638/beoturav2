import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../classes/protest_alert_class.dart';
import '../classes/organiser_location_class.dart';
import '../classes/protest_location_class.dart';
import 'package:beotura/services/ble_mesh_service.dart'; // Import BLE mesh service
import 'package:shared_preferences/shared_preferences.dart';

class ProtestWebSocketService {
  late WebSocketChannel channel;
  final WidgetRef ref;
  Function(OrganizerNotification) onNewNotification;
  Function(ProtestAlert) onNewAlert;
  final Function(String, ProtestAlert) onYourAlert;
  final Function(String) onAlertStopped;
  final Function(List<OrganizerNotification>, Map<String, ProtestAlert>, int)
      onStateUpdate;
  final Function(String, ProtestLocation) onLocationUpdate;
  final Function(int) onUserCountUpdate;
  final Function(String) onUserDisconnected;
  final Function() onOrganizerRegistered;
  final Function(String) onError;
  final BluetoothMeshService _bleMeshService =
      BluetoothMeshService(); // Initialize BLE mesh service

  Function(bool)? onConnectionStatusChanged;
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;
  bool _disposed = false;

  ProtestWebSocketService({
    required this.ref,
    required this.onNewNotification,
    required this.onNewAlert,
    required this.onYourAlert,
    required this.onAlertStopped,
    required this.onStateUpdate,
    required this.onLocationUpdate,
    required this.onUserCountUpdate,
    required this.onUserDisconnected,
    required this.onOrganizerRegistered,
    required this.onError,
  });

  void connect() async {
    if (_disposed) return;

    debugPrint('WebSocketService: Attempting to connect to WebSocket');
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://api2.gladni.rs/api/beotura/protest'),
      );

      debugPrint('WebSocketService: WebSocket connection established');
      _updateConnectionStatus(true);

      // Send raw UUID from shared_preferences as the first message
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('device_uuid') ?? '';
      if (uuid.isNotEmpty) {
        channel.sink.add(jsonEncode({'protest_id': uuid}));
        debugPrint('WebSocketService: Sent UUID: $uuid');
      } else {
        debugPrint('WebSocketService: UUID not found in shared_preferences');
      }

      _streamSubscription = channel.stream.listen(
        (message) {
          debugPrint('WebSocketService: Received message: $message');
          if (!_disposed) {
            _handleWebSocketMessage(message);
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _updateConnectionStatus(false);
          onError('WebSocket error: $error');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 5), connect);
          }
        },
        onDone: () {
          debugPrint('WebSocketService: Connection closed');
          _updateConnectionStatus(false);
          onError('WebSocket connection closed');
          if (!_disposed) {
            Future.delayed(const Duration(seconds: 5), connect);
          }
        },
      );

      _requestInitialState();
    } on WebSocketChannelException catch (e) {
      debugPrint('WebSocketService: WebSocketChannelException: $e');
      _updateConnectionStatus(false);
      onError('WebSocket connection failed: $e');
      if (!_disposed) {
        Future.delayed(const Duration(seconds: 5), connect);
      }
    } catch (e) {
      debugPrint('WebSocketService: Connection error: $e');
      _updateConnectionStatus(false);
      onError('WebSocket connection failed: $e');
      if (!_disposed) {
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    _isConnected = isConnected;
    onConnectionStatusChanged?.call(isConnected);
  }

  bool get isConnected => _isConnected;

  void sendAlert(String type, LatLng location) {
    if (_isConnected) {
      try {
        channel.sink.add(jsonEncode({'type': type, 'location': location}));
        debugPrint('WebSocketService: Alert sent successfully');
      } catch (e) {
        debugPrint('WebSocketService: Error sending alert: $e');
        _bleMeshService.broadcastMessage('alert', {'type': type, 'location': location});
      }
    } else {
      debugPrint('WebSocketService: WebSocket not connected, using BLE mesh');
      _bleMeshService.broadcastMessage('alert', {'type': type, 'location': location});
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

    if (_isConnected) {
      try {
        channel.sink.add(jsonEncode({'notification': notification}));
      } catch (e) {
        debugPrint('WebSocketService: Error sending notification: $e');
        _bleMeshService.broadcastMessage('notification', notification);
      }
    } else {
      debugPrint('WebSocketService: WebSocket not connected, using BLE mesh');
      _bleMeshService.broadcastMessage('notification', notification);
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    final data = jsonDecode(message);

    switch (data['type']) {
      case 'notification':
        final notification =
            OrganizerNotification.fromJson(data['notification']);
        onNewNotification(notification);
        break;

      case 'new_alert':
        final alert = ProtestAlert.fromJson(data['alert']);
        onNewAlert(alert);
        break;

      case 'your_alert':
        final alert = ProtestAlert.fromJson(data['alert']);
        onYourAlert(alert.id, alert);
        break;

      case 'alert_stopped':
        onAlertStopped(data['alert_id']);
        break;

      case 'state_update':
        final notifications = (data['notifications'] as List)
            .map((n) => OrganizerNotification.fromJson(n))
            .toList();
        final alerts = Map<String, ProtestAlert>.fromEntries(
            (data['alerts'] as List).map((a) =>
                MapEntry(a['owner'] as String, ProtestAlert.fromJson(a))));
        onStateUpdate(notifications, alerts, data['user_count']);
        break;

      case 'location_update':
        final userId = data['user_id'];
        final location = ProtestLocation.fromJson(data['location']);
        onLocationUpdate(userId, location);
        break;

      case 'user_count_update':
        onUserCountUpdate(data['count']);
        break;

      case 'user_disconnected':
        onUserDisconnected(data['user_id']);
        break;

      case 'registration':
        if (data['status'] == 'organizer_registered') {
          onOrganizerRegistered();
        }
        break;

      case 'error':
        onError(data['message']);
        break;
    }
  }

  void _requestInitialState() {
    channel.sink.add(jsonEncode({'request_state': true}));
  }

  void sendToken(String token) {
    if (_isConnected) {
      try {
        channel.sink.add(jsonEncode({'token': token}));
      } catch (e) {
        debugPrint('WebSocketService: Error sending token: $e');
      }
    }
  }

  void registerAsOrganizer() {
    if (_isConnected) {
      try {
        channel.sink.add(jsonEncode({'register_organizer': true}));
      } catch (e) {
        debugPrint('WebSocketService: Error registering as organizer: $e');
      }
    }
  }

  void startInForeground() {
    connect();
  }

  void dispose() {
    debugPrint('WebSocketService: Disposing...');
    _disposed = true;

    // Cancel stream subscription first
    _streamSubscription?.cancel();

    // Send disconnect message if connected
    if (_isConnected) {
      try {
        debugPrint('WebSocketService: Sending disconnect message');
        channel.sink.add(jsonEncode({'type': 'disconnect'}));
      } catch (e) {
        debugPrint('WebSocketService: Error sending disconnect message: $e');
      }
    }

    // Close the channel
    try {
      debugPrint('WebSocketService: Closing WebSocket channel');
      channel.sink.close();
    } catch (e) {
      debugPrint('WebSocketService: Error closing WebSocket channel: $e');
    }

    _updateConnectionStatus(false);
  }
}
