// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'card_item.dart';

class Location extends CardItem {
  @override
  final String id;
  final String icon;
  final double latitude;
  final double longitude;
  final int order;
  final String title_en;
  final String title_sr;
  final String description_en;
  final String description_sr;
  final dynamic content_en; // Store content as-is
  final dynamic content_sr; // Store content as-is

  Location({
    required this.id,
    required super.title,
    required this.title_en,
    required this.title_sr,
    required super.description,
    required this.description_en,
    required this.description_sr,
    required super.imageUrl,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.order,
    required this.content_en,
    required this.content_sr,
  }) : super(
          id: id,
        );

  factory Location.fromGraphQL(Map<String, dynamic> data) {
    final image =
        data['image']?['image']?['url'] ?? ''; // Safely handle null image
    final headerImageUrl = data['headerImageUrl'] ?? '';

    // Parse coordinates field
    final coordinates = data['coordinates'] as Map<String, dynamic>? ?? {};
    final latitude = (coordinates['lat'] as num?)?.toDouble() ?? 0.0;
    final longitude = (coordinates['lng'] as num?)?.toDouble() ?? 0.0;

    return Location(
      id: data['id'],
      title: data['title_en'], // Use English title as default
      title_en: data['title_en'],
      title_sr: data['title_sr'],
      description: data['description_outdated_en'] ?? '',
      description_en: data['description_outdated_en'] ?? '',
      description_sr: data['description_outdated_sr'] ?? '',
      imageUrl: image.isNotEmpty
          ? image
          : headerImageUrl, // Use image URL or fallback to headerImageUrl
      icon: data['icon'] ?? '',
      latitude: latitude, // Use parsed latitude
      longitude: longitude, // Use parsed longitude
      order: data['order'] ?? 0,
      content_en: data['content_en']?['document'] ?? [], // Store content as-is
      content_sr: data['content_sr']?['document'] ?? [], // Store content as-is
    );
  }
}
