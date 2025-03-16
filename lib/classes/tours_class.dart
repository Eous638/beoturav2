// ignore_for_file: non_constant_identifier_names

import 'card_item.dart';
import 'loactions_class.dart';
import 'document_content.dart';

class Tour extends CardItem {
  final List<Location> locations;
  final int order; // Display order
  final String title_en;
  final String title_rs;
  final String description_en;
  final String description_rs;
  final dynamic frontPageContent_en; // Store document as-is
  final dynamic frontPageContent_sr; // Store document as-is

  Tour({
    required super.id,
    required super.title,
    required this.title_en,
    required this.title_rs,
    required super.description,
    required this.description_en,
    required this.description_rs,
    required super.imageUrl,
    required this.locations,
    required this.order,
    required this.frontPageContent_en,
    required this.frontPageContent_sr,
  }) {
    locations.sort((a, b) => a.order.compareTo(b.order));
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['_id'],
      title: json['title'],
      title_en: json['title_en'],
      title_rs: json['title_rs'],
      description: json['description'],
      description_en: json['description_en'],
      description_rs: json['description_rs'],
      imageUrl: json['image'].isNotEmpty
          ? json['image']
          : json['headerImageUrl'], // Use image or fallback to headerImageUrl
      locations: json['Place']
          .map<Location>((json) => Location.fromGraphQL(json))
          .toList(),
      order: json['order'], // Parse the order field
      frontPageContent_en: json['frontPageContent_en'],
      frontPageContent_sr: json['frontPageContent_sr'],
    );
  }

  factory Tour.fromGraphQL(Map<String, dynamic> data) {
    final image =
        data['image']?['image']?['url'] ?? ''; // Safely handle null image
    final headerImageUrl = data['headerImageUrl'] ?? '';

    return Tour(
      id: data['id'],
      title: data['title_en'], // Use English title as default
      title_en: data['title_en'],
      title_rs: data['title_sr'],
      description: data['content_en'] ??
          data['description_outdated_en'], // Fallback to outdated description
      description_en: data['content_en'] ?? data['description_outdated_en'],
      description_rs: data['content_sr'] ?? data['description_outdated_sr'],
      imageUrl: image.isNotEmpty
          ? image
          : headerImageUrl, // Use image URL or fallback to headerImageUrl
      locations: (data['locations'] as List<dynamic>?)
              ?.map((locationData) => Location.fromGraphQL(locationData))
              .toList() ??
          [], // Map locations using Location.fromGraphQL
      order: data['order'] ?? 0,
      frontPageContent_en: data['frontPageContent_en']?['document'] ?? [],
      frontPageContent_sr: data['frontPageContent_sr']?['document'] ?? [],
    );
  }
}
