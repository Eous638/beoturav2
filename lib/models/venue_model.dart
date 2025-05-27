import 'package:beotura/enums/venue_type.dart';
import 'package:beotura/enums/venue_vibe.dart';
import 'package:beotura/enums/venue_area.dart'; // Added

class Venue {
  final String id;
  final String name;
  final VenueType type;
  final String imageUrl;
  final String description;
  final VenueVibe vibe;
  final VenueArea area; // Changed to VenueArea enum

  Venue({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.vibe,
    required this.area, // Changed to VenueArea enum
  });
}
