import 'package:flutter/material.dart';

class TicketSection extends StatelessWidget {
  final String venueName;
  final bool
      isMuseum; // To differentiate between museum and show tickets if needed

  const TicketSection(
      {super.key, required this.venueName, this.isMuseum = false});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            isMuseum ? 'Tickets & Exhibitions' : 'Tickets for $venueName',
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
            leading: const Icon(Icons.confirmation_number_outlined,
                color: Colors.lightBlueAccent),
            title: Text(isMuseum ? 'General Admission' : 'Standard Ticket',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Entry to all main areas/show',
                style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent),
              onPressed: () {
                // Navigate to ticket purchasing flow
              },
              child: const Text('Buy Tickets',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        if (isMuseum)
          Card(
            color: Colors.grey[800],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.event_note_outlined,
                  color: Colors.orangeAccent),
              title: const Text('Special Exhibition: Ancient Artifacts',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Limited time only. Separate ticket required.',
                  style: TextStyle(color: Colors.white70)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  // Navigate to ticket purchasing flow for special exhibition
                },
                child: const Text('Book Now',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }
}
