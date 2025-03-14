import 'dart:async';
// Import dart:io to check platform
import 'package:beotura/classes/organiser_location_class.dart';
import 'package:beotura/classes/protest_alert_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beotura/services/combined_communication_service.dart';
import '../providers/current_protest_provider.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  static CombinedCommunicationService? _communicationService;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('ForegroundTaskService: onStart');
    // Don't initialize a new connection, just start the service
    _communicationService?.startInForeground();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
    _communicationService?.dispose();
  }

  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }

  static void initializeCommunicationService(WidgetRef ref) {
    // Only initialize if not already initialized
    if (_communicationService == null) {
      debugPrint('ForegroundTaskService: Initializing communication service');
      _communicationService = CombinedCommunicationService(
        ref: ref,
        onNewNotification: (notification) {},
        onNewAlert: (alert) {},
        onYourAlert: (id, alert) {},
        onAlertStopped: (alertId) {},
        onStateUpdate: (newNotifications, newAlerts, count) {},
      );
    }
  }

  static void sendAlert({required String type, required LatLng location}) {
    print(
        'MyTaskHandler.sendAlert called with type: $type, location: $location');
    _communicationService?.sendAlert(type: type, location: location);
  }

  static void sendNotification({
    required String title,
    required String content,
    required String severity,
    LatLng? location,
  }) {
    _communicationService?.sendNotification(
      title: title,
      content: content,
      severity: severity,
      location: location,
    );
  }

  static void sendLocationUpdate(Position position) {
    _communicationService?.sendLocationUpdate(position);
  }

  static void stopAlert(String alertId) {
    _communicationService?.stopAlert(alertId);
  }

  static void receiveAlert(Function(ProtestAlert) onNewAlert) {
    _communicationService?.onNewAlert = onNewAlert;
  }

  static void receiveNotification(
      Function(OrganizerNotification) onNewNotification) {
    _communicationService?.onNewNotification = onNewNotification;
  }

  static void terminateConnections() {
    _communicationService?.terminateConnections();
  }
}

class ForegroundTaskService {
  static Future<void> startForegroundTask(WidgetRef ref) async {
    // Check if there is an active protest
    final protest = await ref.read(currentProtestProvider.future);
    if (protest.status != 'active') {
      debugPrint('ForegroundTaskService: No active protest, not starting service');
      return;
    }

    FlutterForegroundTask.startService(
      notificationTitle: 'Active Protest',
      notificationText: 'Communicating with other users',
      callback: startCallback,
    );
  }

  static void stopForegroundTask() {
    FlutterForegroundTask.stopService();
    MyTaskHandler.terminateConnections();
  }

  static Future<void> sendAlert(
      {required String type, required LatLng location}) async {
    print(
        'ForegroundTaskService.sendAlert called with type: $type, location: $location');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ForegroundTaskService.sendAlert post frame callback');
      MyTaskHandler.sendAlert(type: type, location: location);
    });
  }

  static void sendNotification({
    required String title,
    required String content,
    required String severity,
    LatLng? location,
  }) {
    MyTaskHandler.sendNotification(
      title: title,
      content: content,
      severity: severity,
      location: location,
    );
  }

  static void sendLocationUpdate(Position position) {
    // Remove this method or modify to use CombinedCommunicationService instead
    // of sending directly
    debugPrint(
        'ForegroundTaskService: Location updates should go through CombinedCommunicationService');
  }

  static void stopAlert(String alertId) {
    MyTaskHandler.stopAlert(alertId);
  }

  static void receiveAlert(Function(ProtestAlert) onNewAlert) {
    MyTaskHandler.receiveAlert(onNewAlert);
  }

  static void receiveNotification(
      Function(OrganizerNotification) onNewNotification) {
    MyTaskHandler.receiveNotification(onNewNotification);
  }
}
