
import 'package:beotura/classes/organiser_location_class.dart';
import 'package:beotura/services/combined_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ProtestNotificationsService {
  final CombinedCommunicationService webSocketService;
  final BuildContext context;
  final List<OrganizerNotification> notifications = [];

  ProtestNotificationsService({
    required this.webSocketService,
    required this.context,
  });

  Future<void> sendNotification({
    required String title,
    required String content,
    required String severity,
    LatLng? location,
  }) async {
    webSocketService.sendNotification(
      title: title,
      content: content,
      severity: severity,
      location: location,
    );
  }

  void showNotification(String message, {String severity = 'info'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getSeverityColor(severity),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'urgent':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void addNotification(OrganizerNotification notification) {
    notifications.insert(0, notification);
  }

  void clearNotifications() {
    notifications.clear();
  }
}
