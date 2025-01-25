import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class BluetoothMeshService {
  final List<BluetoothDevice> _connectedDevices = [];
  bool _isScanning = false;
  final Map<String, Function(dynamic)> messageHandlers = {};

  BluetoothMeshService() {
    _initialize();
  }

  /// Initializes the Bluetooth service
  void _initialize() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        startService();
      } else {
        stopScanning();
      }
    });
  }

  /// Starts scanning for nearby devices
  Future<void> _startScanning() async {
    if (_isScanning) return;

    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          _connectToDevice(result.device);
        }
      });
    } catch (e) {
      debugPrint('Error during BLE scan: $e');
    } finally {
      _isScanning = false;
    }
  }

  /// Add a method to start the BLE mesh service
  Future<void> startService() async {
    try {
      // Start scanning with updated settings
      await _startScanning();
    } catch (e) {
      debugPrint('Error starting BLE service: $e');
    }
  }

  /// Connects to a specific Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connectedDevices.contains(device)) return;

    try {
      // Connect without auto-connect and MTU settings
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false, // Disable auto-connect
      );

      _connectedDevices.add(device);

      // After connection is established, discover services
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        // Handle service discovery
        _handleService(service);
      }
    } catch (e) {
      debugPrint('Failed to connect to ${device.name}: $e');
    }
  }

  void _handleService(BluetoothService service) {
    // Handle service discovery and characteristic setup
    // Implementation depends on your mesh protocol
  }

  /// Handles incoming data from the mesh network
  void _handleIncomingData(Uint8List data, BluetoothDevice device) {
    final message = utf8.decode(data);
    print('Message received from ${device.platformName}: $message');

    try {
      final jsonData = jsonDecode(message);
      final type = jsonData['type'];

      // Route the message to the appropriate handler
      if (messageHandlers.containsKey(type)) {
        messageHandlers[type]?.call(jsonData);
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  /// Broadcasts a message to all connected devices
  Future<void> broadcastMessage(String type, Map<String, dynamic> data) async {
    final message = jsonEncode({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    for (var device in _connectedDevices) {
      try {
        // Send message to connected device
        // Implementation depends on your mesh protocol
      } catch (e) {
        debugPrint('Error broadcasting to ${device.name}: $e');
      }
    }
  }

  /// Sends an alert to the network
  void sendAlert({required String type, required LatLng location}) {
    broadcastMessage('alert', {
      'type': type,
      'location': {'lat': location.latitude, 'lng': location.longitude},
    });
  }

  /// Sends a notification to the network
  void sendNotification({
    required String title,
    required String content,
    required String severity,
    LatLng? location,
  }) {
    broadcastMessage('notification', {
      'title': title,
      'content': content,
      'severity': severity,
      if (location != null)
        'location': {'lat': location.latitude, 'lng': location.longitude},
    });
  }

  /// Registers a handler for incoming messages
  void registerMessageHandler(String type, Function(dynamic) handler) {
    messageHandlers[type] = handler;
  }

  /// Stops scanning and disconnects all devices
  void stopScanning() {
    FlutterBluePlus.stopScan();
    for (var device in _connectedDevices) {
      device.disconnect();
    }
    _connectedDevices.clear();
  }

  Future<void> dispose() async {
    for (var device in _connectedDevices) {
      await device.disconnect();
    }
    _connectedDevices.clear();
    await FlutterBluePlus.stopScan();
  }

  int get connectedDeviceCount => _connectedDevices.length;
}
