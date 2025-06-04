import 'package:flutter/material.dart';

/// Base class for all tour page types
abstract class TourPage {
  final String id;
  final String type;
  final UnlockCondition unlock;
  bool isUnlocked;

  TourPage({
    required this.id,
    required this.type,
    required this.unlock,
    this.isUnlocked = false,
  });

  factory TourPage.fromJson(Map<String, dynamic> json) {
    final String pageType = json['type'] ?? 'content';

    switch (pageType) {
      case 'nav':
        return NavigationPage.fromJson(json);
      case 'title':
        return TitlePage.fromJson(json);
      case 'content':
      default:
        return ContentPage.fromJson(json);
    }
  }
}

/// Navigation page with either an image and instructions or a map with instructions
class NavigationPage extends TourPage {
  final String? imageUrl;
  final String instructions;
  final bool showMap;
  final List<MapMarker>? mapMarkers;
  final double? targetLatitude;
  final double? targetLongitude;

  NavigationPage({
    required super.id,
    required super.unlock,
    super.isUnlocked = false,
    this.imageUrl,
    required this.instructions,
    required this.showMap,
    this.mapMarkers,
    this.targetLatitude,
    this.targetLongitude,
  }) : super(type: 'nav');

  factory NavigationPage.fromJson(Map<String, dynamic> json) {
    List<MapMarker>? markers;

    if (json['mapMarkers'] != null) {
      markers = (json['mapMarkers'] as List)
          .map((marker) => MapMarker.fromJson(marker))
          .toList();
    }

    return NavigationPage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? {'mode': 'immediate'}),
      imageUrl: json['imageUrl'],
      instructions: json['instructions'] ?? '',
      showMap: json['showMap'] ?? false,
      mapMarkers: markers,
      targetLatitude: json['targetLatitude'] != null
          ? double.tryParse(json['targetLatitude'].toString())
          : null,
      targetLongitude: json['targetLongitude'] != null
          ? double.tryParse(json['targetLongitude'].toString())
          : null,
    );
  }
}

/// Title page that serves as an introduction/cover for the tour
class TitlePage extends TourPage {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? authorName;
  final String? description;
  final bool showStartButton;

  TitlePage({
    required super.id,
    required super.unlock,
    super.isUnlocked = false,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.authorName,
    this.description,
    this.showStartButton = true,
  }) : super(type: 'title');

  factory TitlePage.fromJson(Map<String, dynamic> json) {
    return TitlePage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? {'mode': 'immediate'}),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'],
      authorName: json['authorName'],
      description: json['description'],
      showStartButton: json['showStartButton'] ?? true,
    );
  }
}

/// Content page with rich scrollable content
class ContentPage extends TourPage {
  final List<ContentComponent> content;
  final String? backgroundImageUrl;
  final String? backgroundAudioUrl;

  ContentPage({
    required super.id,
    required super.unlock,
    super.isUnlocked = false,
    required this.content,
    this.backgroundImageUrl,
    this.backgroundAudioUrl,
  }) : super(type: 'content');

  factory ContentPage.fromJson(Map<String, dynamic> json) {
    final List<ContentComponent> contentItems = [];

    if (json['content'] != null) {
      for (var component in json['content']) {
        contentItems.add(ContentComponent.fromJson(component));
      }
    }

    final background = json['background'];

    return ContentPage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? {'mode': 'immediate'}),
      content: contentItems,
      backgroundImageUrl: background?['image'],
      backgroundAudioUrl: background?['audio'],
    );
  }
}

/// Component for rich content pages
class ContentComponent {
  final String component;
  final String? text;
  final String? src;
  final String? caption;
  final bool? autoplay;
  final bool? loop;
  final String? action;
  final List<MapMarker>? markers;

  ContentComponent({
    required this.component,
    this.text,
    this.src,
    this.caption,
    this.autoplay,
    this.loop,
    this.action,
    this.markers,
  });

  factory ContentComponent.fromJson(Map<String, dynamic> json) {
    List<MapMarker>? markers;

    if (json['markers'] != null) {
      markers = (json['markers'] as List)
          .map((marker) => MapMarker.fromJson(marker))
          .toList();
    }

    return ContentComponent(
      component: json['component'] ?? 'paragraph',
      text: json['text'],
      src: json['src'],
      caption: json['caption'],
      autoplay: json['autoplay'],
      loop: json['loop'],
      action: json['action'],
      markers: markers,
    );
  }
}

/// Model for map markers
class MapMarker {
  final double lat;
  final double lng;
  final String label;
  final String? description;
  final String? icon;

  MapMarker({
    required this.lat,
    required this.lng,
    required this.label,
    this.description,
    this.icon,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      lat: json['lat'] ?? 0.0,
      lng: json['lng'] ?? 0.0,
      label: json['label'] ?? '',
      description: json['description'],
      icon: json['icon'],
    );
  }
}

/// Model for unlock conditions
class UnlockCondition {
  final bool isImmediate;
  final bool isWalk;
  final double? distanceMeters;
  final String? message;
  final double progress;

  UnlockCondition({
    this.isImmediate = false,
    this.isWalk = false,
    this.distanceMeters,
    this.message,
    this.progress = 0.0,
  });

  factory UnlockCondition.fromJson(Map<String, dynamic> json) {
    if (json['mode'] == 'immediate') {
      return UnlockCondition(isImmediate: true);
    }

    if (json['mode'] == 'walk') {
      return UnlockCondition(
        isWalk: true,
        distanceMeters: json['distance_meters'] != null
            ? double.parse(json['distance_meters'].toString())
            : 100.0,
        message: json['message'] ?? 'Walk to destination to continue',
      );
    }

    return UnlockCondition(isImmediate: true);
  }
}

/// Model for the entire immersive tour structure
class ImmersiveTour {
  final String id;
  final String title;
  final ThemeData theme;
  final List<TourPage> pages;

  ImmersiveTour({
    required this.id,
    required this.title,
    required this.theme,
    required this.pages,
  });

  factory ImmersiveTour.fromJson(Map<String, dynamic> json) {
    final themeJson = json['theme'] ?? {};
    final primaryColorHex = themeJson['primaryColor'] ?? '#111111';
    final accentColorHex = themeJson['accentColor'] ?? '#E63946';

    // Parse theme colors from hex
    final primaryColor = _hexToColor(primaryColorHex);
    final accentColor = _hexToColor(accentColorHex);

    // Create custom theme
    final theme = ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
      ),
      fontFamily: themeJson['font'] ?? 'serif',
    );

    // Parse pages
    final List<TourPage> tourPages = [];
    if (json['pages'] != null) {
      for (var pageJson in json['pages']) {
        tourPages.add(TourPage.fromJson(pageJson));
      }
    }

    return ImmersiveTour(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      theme: theme,
      pages: tourPages,
    );
  }

  // Helper to convert hex color string to Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
