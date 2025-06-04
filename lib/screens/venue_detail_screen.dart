import 'package:beotura/models/venue_model.dart';
import 'package:beotura/widgets/venue_detail/stories_section.dart';
import 'package:beotura/widgets/venue_detail/offers_section.dart';
import 'package:beotura/widgets/venue_detail/ticket_section.dart';
import 'package:beotura/widgets/venue_detail/associated_tours_section.dart';
import 'package:beotura/widgets/venue_detail/events_section.dart';
import 'package:beotura/enums/venue_type.dart';
import 'package:flutter/material.dart';

class VenueDetailScreen extends StatelessWidget {
  final Venue venue;

  const VenueDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(venue.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensure back button is visible
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Hero image (optional, but nice for transitions)
            Hero(
              tag: 'venue-image-${venue.id}',
              child: Image.network(
                venue.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        venue.type.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const Text('  •  ',
                          style: TextStyle(color: Colors.white70)),
                      Text(
                        venue.area.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    venue.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white.withOpacity(0.85)),
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  // Conditionally display sections based on venue type
                  StoriesSection(venueName: venue.name),
                  const Divider(color: Colors.white24, height: 32),
                  if (venue.type == VenueType.RESTAURANT ||
                      venue.type == VenueType.CAFE)
                    OffersSection(venueName: venue.name),
                  if (venue.type == VenueType.MUSEUM ||
                      venue.type == VenueType.SHOW)
                    TicketSection(
                        venueName: venue.name,
                        isMuseum: venue.type == VenueType.MUSEUM),
                  if (venue.type == VenueType.MUSEUM ||
                      venue.type == VenueType.BAR)
                    AssociatedToursSection(
                      venueName: venue.name,
                      tourType: venue.type == VenueType.MUSEUM
                          ? 'Museum Tours'
                          : 'Pub Crawls & District Tours',
                    ),
                  // Potentially add EventsSection here, perhaps with a condition like venue.hasEvents
                  // For now, let's assume all might have events for demonstration
                  EventsSection(venueName: venue.name),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
