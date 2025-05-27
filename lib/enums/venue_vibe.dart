import 'package:flutter/material.dart';

enum VenueVibe {
  HISTORIC_AUTHENTIC,
  ELEGANT_ROMANTIC,
  LIVELY_TRENDY,
  RELAXED_COZY,
  ARTISTIC_BOHEMIAN,
  MYSTERIOUS_HIDDEN,
  OTHER;

  String get displayName {
    switch (this) {
      case VenueVibe.HISTORIC_AUTHENTIC:
        return 'Historic & Authentic';
      case VenueVibe.ELEGANT_ROMANTIC:
        return 'Elegant & Romantic';
      case VenueVibe.LIVELY_TRENDY:
        return 'Lively & Trendy';
      case VenueVibe.RELAXED_COZY:
        return 'Relaxed & Cozy';
      case VenueVibe.ARTISTIC_BOHEMIAN:
        return 'Artistic & Bohemian';
      case VenueVibe.MYSTERIOUS_HIDDEN:
        return 'Mysterious & Hidden';
      case VenueVibe.OTHER:
        return 'Other';
      default:
        return name
            .replaceAll('_', ' ')
            .split(' ')
            .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
            .join(' ');
    }
  }
}

class VibeTheme {
  final Color backgroundColor; // Changed from primaryColor
  final Color accentColor;
  final Color
      onAccentColor; // For text on accent-colored backgrounds (e.g., chips)

  const VibeTheme({
    required this.backgroundColor,
    required this.accentColor,
    this.onAccentColor = Colors.white, // Default to white, can be customized
  });

  static VibeTheme getTheme(VenueVibe vibe) {
    switch (vibe) {
      case VenueVibe.HISTORIC_AUTHENTIC:
        return const VibeTheme(
          backgroundColor: Color(0xFF3E2723), // Dark Brown
          accentColor: Color(0xFFD4A017), // Old Gold
          onAccentColor: Colors.black87,
        );
      case VenueVibe.ELEGANT_ROMANTIC:
        return const VibeTheme(
          backgroundColor: Color(0xFF4A0072), // Deep Plum
          accentColor: Color(0xFFF8BBD0), // Soft Pink
          onAccentColor: Colors.black87,
        );
      case VenueVibe.LIVELY_TRENDY:
        return const VibeTheme(
          backgroundColor: Color(0xFF00332E), // Dark Teal
          accentColor: Color(0xFF2EFFAB), // Bright Mint
          onAccentColor: Colors.black87,
        );
      case VenueVibe.RELAXED_COZY:
        return const VibeTheme(
          backgroundColor: Color(0xFF1B5E20), // Forest Green
          accentColor: Color(0xFFFFF9C4), // Pale Yellow
          onAccentColor: Colors.black87,
        );
      case VenueVibe.ARTISTIC_BOHEMIAN:
        return const VibeTheme(
          backgroundColor: Color(0xFF2A004F), // Deep Indigo/Purple
          accentColor: Color(0xFFFF7043), // Bright Coral
          onAccentColor: Colors.black87,
        );
      case VenueVibe.MYSTERIOUS_HIDDEN:
        return const VibeTheme(
          backgroundColor: Color(0xFF212121), // Very Dark Grey/Charcoal
          accentColor: Color(0xFF4FC3F7), // Light Electric Blue
          onAccentColor: Colors.black87,
        );
      case VenueVibe.OTHER:
      default:
        return const VibeTheme(
          backgroundColor: Color(0xFF303030), // Dark Grey
          accentColor: Color(0xFFB0BEC5), // Light Grey Blue
          onAccentColor: Colors.black87,
        );
    }
  }
}
