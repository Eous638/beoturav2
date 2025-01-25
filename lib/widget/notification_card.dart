import 'package:beotura/classes/organiser_location_class.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final OrganizerNotification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getCardColor(notification.severity),
      child: ListTile(
        leading: Icon(
          notification.severity == 'urgent'
              ? Icons.warning
              : notification.severity == 'warning'
                  ? Icons.info
                  : Icons.notification_important,
          color: _getSeverityColor(notification.severity),
        ),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.content),
            Text(
              timeago.format(notification.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (notification.location != null)
              Text(
                'Location: ${notification.location!.lat}, ${notification.location!.lng}',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
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

  Color _getCardColor(String severity) {
    switch (severity) {
      case 'urgent':
        return Colors.red.withOpacity(0.1);
      case 'warning':
        return Colors.orange.withOpacity(0.1);
      default:
        return Colors.blue.withOpacity(0.1);
    }
  }
}

