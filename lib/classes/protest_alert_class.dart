import 'package:beotura/classes/organiser_location_class.dart';
import 'package:beotura/classes/protest_location_class.dart';
import 'package:flutter/material.dart';

class ProtestAlert {
  final String id; // Add id to track alert
  final String owner;
  final ProtestLocation location;
  final String type;
  final IconData icon;

  ProtestAlert({
    required this.id,
    required this.owner,
    required this.location,
    required this.type,
    required this.icon,
  });

  factory ProtestAlert.fromJson(Map<String, dynamic> json) {
    return ProtestAlert(
      id: json['id'], // Parse id from JSON
      owner: json['owner'],
      location: ProtestLocation.fromJson(json['location']),
      type: json['type'],
      icon: _getIconData(json['icon']), // Map icon name to IconData
    );
  }
  void _showNotificationScreen(
      BuildContext context, List<OrganizerNotification> notifications) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.map((notification) {
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.content),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_police':
        return Icons.local_police;
      case 'medical_services':
        return Icons.medical_services;
      case 'warning':
        return Icons.warning;
      case 'help':
        return Icons.emergency_share;
      default:
        return Icons.help; // Default icon if no match is found
    }
  }
}