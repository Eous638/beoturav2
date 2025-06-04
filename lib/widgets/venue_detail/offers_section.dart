import 'package:flutter/material.dart';

class OffersSection extends StatelessWidget {
  final String venueName;
  const OffersSection({super.key, required this.venueName});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Special Offers at $venueName',
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
            leading:
                const Icon(Icons.local_offer_outlined, color: Colors.amber),
            title: const Text('Happy Hour: 5-7 PM',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('2-for-1 on select drinks',
                style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Show offer details
            },
          ),
        ),
        Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu_outlined,
                color: Colors.lightGreenAccent),
            title: const Text('Lunch Special: Daily Menu',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text(
                'Check out our affordable and delicious lunch options!',
                style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Show menu or offer details
            },
          ),
        ),
      ],
    );
  }
}
