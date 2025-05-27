// ignore_for_file: non_constant_identifier_names

import 'card_item.dart';
import 'loactions_class.dart';
import 'tour_page.dart';

class Tour extends CardItem {
  final List<Location> locations;
  final int order; // Display order
  @override
  final String title_en;
  final String title_rs;
  @override
  final String description_en;
  final String description_rs;
  final dynamic frontPageContent_en; // Store document as-is
  final dynamic frontPageContent_sr; // Store document as-is
  final DateTime? createdAt; // Add createdAt field
  final List<TourPage> pages; // Add pages field

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
    this.createdAt, // Add to constructor
    required this.pages,
    required String category_en, // Add to constructor
  }) {
    pages.sort((a, b) => a.order.compareTo(b.order)); // Sort pages by order
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    // Handle the new JSON API format from api.beotura.rs
    return Tour(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      title_en: json['title_en'] ?? json['name_en'] ?? json['title'] ?? '',
      title_rs: json['title_rs'] ?? json['name_rs'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      description_en: json['description_en'] ?? json['description'] ?? '',
      description_rs: json['description_rs'] ?? json['description'] ?? '',
      imageUrl: _extractImageUrl(json),
      locations: _extractLocations(json),
      order: json['order'] != null
          ? int.tryParse(json['order'].toString()) ?? 0
          : 0,
      frontPageContent_en:
          json['frontPageContent_en'] ?? json['content_en'] ?? [],
      frontPageContent_sr:
          json['frontPageContent_sr'] ?? json['content_rs'] ?? [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      pages: _extractPages(json),
      category_en: '',
    );
  }

  // Helper method to extract image URL from various possible JSON structures
  static String _extractImageUrl(Map<String, dynamic> json) {
    if (json['image'] != null) {
      if (json['image'] is String) {
        return json['image'];
      } else if (json['image'] is Map && json['image']['url'] != null) {
        return json['image']['url'];
      } else if (json['image'] is Map &&
          json['image']['image'] != null &&
          json['image']['image']['url'] != null) {
        return json['image']['image']['url'];
      }
    }

    return json['headerImageUrl'] ?? json['imageUrl'] ?? '';
  }

  // Helper method to extract locations from various possible JSON structures
  static List<Location> _extractLocations(Map<String, dynamic> json) {
    if (json['locations'] != null && json['locations'] is List) {
      return (json['locations'] as List)
          .map<Location>((locationData) => Location.fromJson(locationData))
          .toList();
    } else if (json['Place'] != null && json['Place'] is List) {
      return (json['Place'] as List)
          .map<Location>((locationData) => Location.fromJson(locationData))
          .toList();
    }
    return [];
  }

  // Helper method to extract pages from JSON
  static List<TourPage> _extractPages(Map<String, dynamic> json) {
    if (json['pages'] != null && json['pages'] is List) {
      return (json['pages'] as List)
          .map<TourPage>((pageData) => TourPage.fromJson(pageData))
          .toList();
    }
    return [];
  }

  // Keep the fromGraphQL method for backward compatibility
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
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      pages: (data['pages'] as List<dynamic>?)
              ?.map<TourPage>((pageData) => TourPage.fromGraphQL(pageData))
              .toList() ??
          [],
      category_en: '',
    );
  }
}
