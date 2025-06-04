import 'package:flutter/foundation.dart';
import '../enums/story_type_enum.dart'; // Import the new enum

class Blog {
  final String id;
  final String titleEn;
  final String titleSr;
  final Map<String, dynamic> contentEn;
  final Map<String, dynamic> contentSr;
  final String? imageUrl;
  final DateTime? createdAt;
  final StoryType storyType; // Added storyType field

  Blog({
    required this.id,
    required this.titleEn,
    required this.titleSr,
    required this.contentEn,
    required this.contentSr,
    this.imageUrl,
    this.createdAt,
    required this.storyType, // Added to constructor
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

    // Determine StoryType
    StoryType storyType = StoryType.GENERAL_STORY; // Default value
    if (json['storyType'] != null && json['storyType'] is String) {
      try {
        storyType = StoryType.values.firstWhere(
          (e) =>
              e.toString().split('.').last.toLowerCase() ==
              (json['storyType'] as String).toLowerCase(),
          orElse: () => StoryType.GENERAL_STORY,
        );
      } catch (e) {
        debugPrint('Error parsing storyType: $e. Defaulting to GENERAL_STORY.');
        storyType = StoryType.GENERAL_STORY;
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
      storyType: storyType, // Assign storyType
    );
  }
}
