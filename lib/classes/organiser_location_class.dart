import 'package:beotura/classes/protest_location_class.dart';

class OrganizerNotification {
  final String title;
  final String content;
  final String severity;
  final DateTime timestamp;
  final ProtestLocation? location;

  OrganizerNotification({
    required this.title,
    required this.content,
    required this.severity,
    required this.timestamp,
    this.location,
  });

  factory OrganizerNotification.fromJson(Map<String, dynamic> json) {
    return OrganizerNotification(
      title: json['title'],
      content: json['content'],
      severity: json['severity'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] != null
          ? ProtestLocation.fromJson(json['location'])
          : null,
    );
  }
}
