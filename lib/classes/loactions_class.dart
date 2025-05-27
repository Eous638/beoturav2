// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'card_item.dart';

class Location extends CardItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? title_en;
  @override
  final String description;
  @override
  final String? description_en;
  @override
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String? icon;

  final String? category;
  final String? categoryId; // Add categoryId to link to Tour ID
  final int order; // Add order property for sorting on Locations screen

  // Add content fields for future use
  final dynamic content_en;
  final dynamic content_sr;

  Location({
    required this.id,
    required this.title,
    this.title_en,
    required this.description,
    this.description_en,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.icon,
    this.category,
    this.categoryId, // Add to constructor
    this.order = 0, // Default to 0 if not specified
    this.content_en,
    this.content_sr,
  }) : super(
          id: id,
          title: title,
          description: description,
        );

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id_field']?.toString() ??
          json['id'] ??
          json['_id'] ??
          '', // Prioritize id_field
      title: json['title'] ?? json['name'] ?? '',
      title_en: json['title_en'] ?? json['name_en'],
      description: json['description'] ?? '',
      description_en: json['description_en'],
      imageUrl: _extractImageUrl(json),
      latitude: _extractCoordinate(json, 'latitude'),
      longitude: _extractCoordinate(json, 'longitude'),
      icon: json['icon'],
      category: json['category'] ??
          json['tour_title'], // Can use tour_title as category name
      categoryId: json['tour']?.toString() ??
          json['categoryId'] ??
          json['tour_id'], // Prioritize tour
      order: json['order'] != null
          ? int.tryParse(json['order'].toString()) ?? 0
          : 0,
      content_en: json['content_en'],
      content_sr: json['content_sr'],
    );
  }

  // Helper method to extract image URL from various possible JSON structures
  static String? _extractImageUrl(Map<String, dynamic> json) {
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

    return json['headerImageUrl'] ?? json['imageUrl'];
  }

  // Helper method to extract coordinate values
  static double _extractCoordinate(Map<String, dynamic> json, String key) {
    // First try direct access
    if (json[key] != null) {
      if (json[key] is num) {
        return json[key].toDouble();
      }
      return double.tryParse(json[key].toString()) ?? 0.0;
    }

    // Then try coordinates object if it exists
    if (json['coordinates'] != null) {
      final coordinates = json['coordinates'];
      if (coordinates is Map) {
        if (key == 'latitude' && coordinates['lat'] != null) {
          if (coordinates['lat'] is num) {
            return coordinates['lat'].toDouble();
          }
          return double.tryParse(coordinates['lat'].toString()) ?? 0.0;
        }
        if (key == 'longitude' && coordinates['lng'] != null) {
          if (coordinates['lng'] is num) {
            return coordinates['lng'].toDouble();
          }
          return double.tryParse(coordinates['lng'].toString()) ?? 0.0;
        }
      }
      // If coordinates is an array [lng, lat]
      if (coordinates is List && coordinates.length >= 2) {
        if (key == 'longitude') {
          if (coordinates[0] is num) {
            return coordinates[0].toDouble();
          }
          return double.tryParse(coordinates[0].toString()) ?? 0.0;
        }
        if (key == 'latitude') {
          if (coordinates[1] is num) {
            return coordinates[1].toDouble();
          }
          return double.tryParse(coordinates[1].toString()) ?? 0.0;
        }
      }
    }

    return 0.0;
  }

  // Keep the fromGraphQL method for backward compatibility
  factory Location.fromGraphQL(Map<String, dynamic> data) {
    final String? imageUrl = data['image'] != null &&
            data['image']['image'] != null &&
            data['image']['image']['url'] != null
        ? data['image']['image']['url']
        : data['headerImageUrl'];

    double latitude = 0.0;
    double longitude = 0.0;

    if (data['coordinates'] != null) {
      try {
        final coordinates = data['coordinates'];
        if (coordinates.length == 2) {
          latitude = coordinates['lat'];
          print(latitude);
          longitude = coordinates['lng'];
          print(longitude);
        }
      } catch (e) {
        // In case of any parsing error, default to 0
        print(e);
      }
    }

    if (latitude == 0.0 && data['latitude'] != null) {
      latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
    }

    if (longitude == 0.0 && data['longitude'] != null) {
      longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
    }

    // Parse order property, default to 0 if not present or not a valid number
    int order = 0;
    if (data['order'] != null) {
      try {
        if (data['order'] is int) {
          order = data['order'];
        } else {
          order = int.tryParse(data['order'].toString()) ?? 0;
        }
      } catch (e) {
        // In case of any parsing error, default to 0
      }
    }

    return Location(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      title_en: data['title_en'],
      description: data['description'] ?? data['description_outdated_sr'] ?? '',
      description_en: data['description_en'] ?? data['description_outdated_en'],
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      icon: data['icon'],
      category: data['category'],
      categoryId: data['categoryId'], // Add categoryId
      order: order,
      // Add content fields but continuing to use descriptions for now
      content_en: data['content_en'],
      content_sr: data['content_sr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_en': title_en,
      'description': description,
      'description_en': description_en,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'icon': icon,
      'category': category,
      'categoryId': categoryId,
      'order': order,
      'content_en': content_en,
      'content_sr': content_sr,
    };
  }
}
