import 'package:flutter/material.dart';

class EventsSection extends StatelessWidget {
  final String venueName;
  const EventsSection({super.key, required this.venueName});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Events at $venueName',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white70),
          ),
        ),
        Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined,
                color: Colors.pinkAccent),
            title: const Text('Live Music Night',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Friday, 9 PM - Acoustic Set',
                style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Show event details
            },
          ),
        ),
        Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.celebration_outlined,
                color: Colors.yellowAccent),
            title: const Text('Special Theme Party',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Next Saturday - Details coming soon!',
                style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Show event details
            },
          ),
        ),
      ],
    );
  }
}
