import 'package:flutter/foundation.dart';

class Blog {
  final String id;
  final String titleEn;
  final String titleSr;
  final Map<String, dynamic> contentEn;
  final Map<String, dynamic> contentSr;
  final String? imageUrl;
  final DateTime? createdAt;

  Blog({
    required this.id,
    required this.titleEn,
    required this.titleSr,
    required this.contentEn,
    required this.contentSr,
    this.imageUrl,
    this.createdAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    // Extract image URL from nested structure if available
    String? imageUrl;
    if (json['image'] != null && 
        json['image']['image'] != null && 
        json['image']['image']['url'] != null &&
        json['image']['image']['url'] != '') {
      imageUrl = json['image']['image']['url'];
    }

    // Handle either createdAt or publishedAt field
    DateTime? dateTime;
    if (json['createdAt'] != null) {
      try {
        dateTime = DateTime.parse(json['createdAt']);
      } catch (e) {
        debugPrint('Error parsing createdAt date: $e');
      }
    } else if (json['publishedAt'] != null) {
      try {
        dateTime = DateTime.parse(json['publishedAt']);
      } catch (e) {
        debugPrint('Error parsing publishedAt date: $e');
      }
    }

    return Blog(
      id: json['id'] ?? '',
      titleEn: json['title_en'] ?? '',
      titleSr: json['title_sr'] ?? '',
      contentEn: json['content_en'] ?? {'document': []},
      contentSr: json['content_sr'] ?? {'document': []},
      imageUrl: imageUrl, // Could be null
      createdAt: dateTime, // Could be null
    );
  }
}
