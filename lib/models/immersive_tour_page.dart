import 'package:flutter/material.dart';
import '../widgets/tour_components/map_component.dart' as map_component;

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

  Map<String, dynamic> toJson();
}

/// Navigation page with either an image and instructions or a map with instructions
class NavigationPage extends TourPage {
  final String? imageUrl;
  final String instructions;
  final bool showMap;
  final List<map_component.MapMarker>? mapMarkers;
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
    List<map_component.MapMarker>? markers;

    if (json['mapMarkers'] != null) {
      markers = (json['mapMarkers'] as List)
          .map((marker) => map_component.MapMarker(
                lat: marker['lat'] ?? 0.0,
                lng: marker['lng'] ?? 0.0,
                label: marker['label'] ?? '',
                description: marker['description'],
              ))
          .toList();
    }

    return NavigationPage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? 'immediate'),
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'unlock': unlock.toJson(),
      'isUnlocked': isUnlocked,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'instructions': instructions,
      'showMap': showMap,
      if (mapMarkers != null)
        'mapMarkers': mapMarkers!
            .map((m) => {
                  'lat': m.lat,
                  'lng': m.lng,
                  'label': m.label,
                  if (m.description != null) 'description': m.description,
                })
            .toList(),
      if (targetLatitude != null) 'targetLatitude': targetLatitude,
      if (targetLongitude != null) 'targetLongitude': targetLongitude,
    };
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
  final String? suggestedTime;
  final Map<String, dynamic>? startLocation;

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
    this.suggestedTime,
    this.startLocation,
  }) : super(type: 'title');

  factory TitlePage.fromJson(Map<String, dynamic> json) {
    return TitlePage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? 'immediate'),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'],
      authorName: json['authorName'],
      description: json['description'],
      showStartButton: json['showStartButton'] ?? true,
      suggestedTime: json['suggestedTime'],
      startLocation: json['startLocation'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'unlock': unlock.toJson(),
      'isUnlocked': isUnlocked,
      'title': title,
      'subtitle': subtitle,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (authorName != null) 'authorName': authorName,
      if (description != null) 'description': description,
      'showStartButton': showStartButton,
      if (suggestedTime != null) 'suggestedTime': suggestedTime,
      if (startLocation != null) 'startLocation': startLocation,
    };
  }
}

/// Content page with rich scrollable content
class ContentPage extends TourPage {
  final List<ContentComponent> content;
  final PageBackground? background;

  ContentPage({
    required super.id,
    required super.unlock,
    super.isUnlocked = false,
    required this.content,
    this.background,
  }) : super(type: 'content');

  factory ContentPage.fromJson(Map<String, dynamic> json) {
    final List<ContentComponent> contentItems = [];

    if (json['content'] != null) {
      for (var component in json['content']) {
        contentItems.add(ContentComponent.fromJson(component));
      }
    }

    return ContentPage(
      id: json['id'] ?? '',
      unlock: UnlockCondition.fromJson(json['unlock'] ?? 'immediate'),
      content: contentItems,
      background: json['background'] != null
          ? PageBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'unlock': unlock.toJson(),
      'isUnlocked': isUnlocked,
      'content': content.map((c) => c.toJson()).toList(),
      if (background != null) 'background': background!.toJson(),
    };
  }
}

/// Model for the immersive tour page content component
class ContentComponent {
  final String component;
  final String? text;
  final String? src;
  final String? caption;
  final String? action;
  final bool? autoplay;
  final bool? loop;
  final List<Map<String, dynamic>>? markers;

  ContentComponent({
    required this.component,
    this.text,
    this.src,
    this.caption,
    this.action,
    this.autoplay,
    this.loop,
    this.markers,
  });

  factory ContentComponent.fromJson(Map<String, dynamic> json) {
    return ContentComponent(
      component: json['component'] as String,
      text: json['text'] as String?,
      src: json['src'] as String?,
      caption: json['caption'] as String?,
      action: json['action'] as String?,
      autoplay: json['autoplay'] as bool?,
      loop: json['loop'] as bool?,
      markers: json['markers'] != null
          ? List<Map<String, dynamic>>.from(json['markers'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'component': component,
      if (text != null) 'text': text,
      if (src != null) 'src': src,
      if (caption != null) 'caption': caption,
      if (action != null) 'action': action,
      if (autoplay != null) 'autoplay': autoplay,
      if (loop != null) 'loop': loop,
      if (markers != null) 'markers': markers,
    };
  }
}

/// Model for unlock conditions for immersive tour pages
class UnlockCondition {
  final String mode;
  final int? distanceMeters;
  final String? message;

  const UnlockCondition({
    required this.mode,
    this.distanceMeters,
    this.message,
  });

  factory UnlockCondition.immediate() {
    return const UnlockCondition(mode: 'immediate');
  }

  factory UnlockCondition.fromJson(dynamic json) {
    if (json is String && json == 'immediate') {
      return UnlockCondition.immediate();
    }

    if (json is Map<String, dynamic>) {
      return UnlockCondition(
        mode: json['mode'] as String,
        distanceMeters: json['distance_meters'] as int?,
        message: json['message'] as String?,
      );
    }

    return UnlockCondition.immediate();
  }

  bool get isImmediate => mode == 'immediate';
  bool get isWalk => mode == 'walk';

  Map<String, dynamic> toJson() {
    if (isImmediate) {
      return {'mode': 'immediate'};
    }

    return {
      'mode': mode,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (message != null) 'message': message,
    };
  }
}

/// Model for background properties in immersive tour pages
class PageBackground {
  final String? image;
  final String? audio;

  PageBackground({
    this.image,
    this.audio,
  });

  factory PageBackground.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PageBackground();

    return PageBackground(
      image: json['image'] as String?,
      audio: json['audio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (image != null) 'image': image,
      if (audio != null) 'audio': audio,
    };
  }
}

/// Model for the tour theme styling
class TourTheme {
  final String primaryColor;
  final String accentColor;
  final String font;

  TourTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.font,
  });

  factory TourTheme.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TourTheme(
        primaryColor: '#111111',
        accentColor: '#E63946',
        font: 'serif',
      );
    }

    return TourTheme(
      primaryColor: json['primaryColor'] as String? ?? '#111111',
      accentColor: json['accentColor'] as String? ?? '#E63946',
      font: json['font'] as String? ?? 'serif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'font': font,
    };
  }
}

/// Model for an immersive tour experience
class ImmersiveTour {
  final String id;
  final String title;
  final TourTheme theme;
  final List<TourPage> pages;

  ImmersiveTour({
    required this.id,
    required this.title,
    required this.theme,
    required this.pages,
  });

  factory ImmersiveTour.fromJson(Map<String, dynamic> json) {
    final tourData = json['tour'] ?? json;

    // Create theme
    final theme =
        TourTheme.fromJson(tourData['theme'] as Map<String, dynamic>?);

    // Parse pages
    final List<TourPage> tourPages = [];
    if (tourData['pages'] != null) {
      for (var pageJson in tourData['pages']) {
        tourPages.add(TourPage.fromJson(pageJson));
      }
    }

    return ImmersiveTour(
      id: tourData['id'] as String? ?? '',
      title: tourData['title'] as String? ?? '',
      theme: theme,
      pages: tourPages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme.toJson(),
      'pages': pages.map((p) => p.toJson()).toList(),
    };
  }

  // Helper to convert hex color string to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
