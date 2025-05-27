import 'package:flutter/foundation.dart';

/// Model for the immersive tour page content component
class TourPageComponent {
  final String component;
  final String? text;
  final String? src;
  final String? caption;
  final String? action;
  final bool? autoplay;
  final bool? loop;
  final List<Map<String, dynamic>>? markers;

  TourPageComponent({
    required this.component,
    this.text,
    this.src,
    this.caption,
    this.action,
    this.autoplay,
    this.loop,
    this.markers,
  });

  factory TourPageComponent.fromJson(Map<String, dynamic> json) {
    return TourPageComponent(
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

/// Model for an immersive tour page based on the new_tour.md spec
class ImmersiveTourPage {
  final String id;
  final String type;
  final UnlockCondition unlock;
  final PageBackground? background;
  final List<TourPageComponent> content;
  bool isUnlocked;

  ImmersiveTourPage({
    required this.id,
    required this.type,
    required this.unlock,
    this.background,
    required this.content,
    this.isUnlocked = false,
  });

  factory ImmersiveTourPage.fromJson(Map<String, dynamic> json) {
    final unlock = json['unlock'];

    return ImmersiveTourPage(
      id: json['id'] as String,
      type: json['type'] as String,
      unlock: unlock is String
          ? UnlockCondition(mode: unlock)
          : UnlockCondition.fromJson(unlock as Map<String, dynamic>),
      background: json['background'] != null
          ? PageBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,
      content: (json['content'] as List)
          .map((item) =>
              TourPageComponent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'unlock': unlock.toJson(),
      if (background != null) 'background': background!.toJson(),
      'content': content.map((c) => c.toJson()).toList(),
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
  final List<ImmersiveTourPage> pages;

  ImmersiveTour({
    required this.id,
    required this.title,
    required this.theme,
    required this.pages,
  });

  factory ImmersiveTour.fromJson(Map<String, dynamic> json) {
    final tourData = json['tour'] ?? json;

    return ImmersiveTour(
      id: tourData['id'] as String,
      title: tourData['title'] as String,
      theme: TourTheme.fromJson(tourData['theme'] as Map<String, dynamic>),
      pages: (tourData['pages'] as List)
              .map((page) =>
                  ImmersiveTourPage.fromJson(page as Map<String, dynamic>))
              .toList() ??
          [],
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
}
