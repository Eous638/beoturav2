import 'loactions_class.dart';

class TourPage {
  final String type;
  final String? locationId;
  final Location? location;
  final int order;
  final dynamic content_en;
  final dynamic content_sr;

  TourPage({
    required this.type,
    this.locationId,
    this.location,
    required this.order,
    this.content_en,
    this.content_sr,
  });

  factory TourPage.fromJson(Map<String, dynamic> json) {
    // Handle location data safely
    Location? locationData;
    try {
      if (json['location'] != null) {
        locationData = Location.fromJson(json['location']);
      }
    } catch (e) {
      print('Error parsing location in tour page: $e');
    }

    return TourPage(
      type: json['type'] ?? 'unknown',
      locationId:
          json['locationId'] ?? json['location_id'] ?? json['location']?['id'],
      location: locationData,
      order: json['order'] != null
          ? int.tryParse(json['order'].toString()) ?? 0
          : 0,
      content_en: json['content_en'] ?? [],
      content_sr: json['content_sr'] ?? [],
    );
  }

  factory TourPage.fromGraphQL(Map<String, dynamic> data) {
    // Handle location data safely
    Location? locationData;
    try {
      if (data['location'] != null) {
        locationData = Location.fromGraphQL(data['location']);
      }
    } catch (e) {
      print('Error parsing location in tour page: $e');
    }

    return TourPage(
      type: data['type'] ?? 'unknown',
      locationId: data['location']?['id'],
      location: locationData,
      order: data['order'] ?? 0,
      content_en: data['content_en']?['document'] ?? [],
      content_sr: data['content_sr']?['document'] ?? [],
    );
  }
}
