import 'package:beotura/enums/venue_vibe.dart';
import 'package:beotura/enums/venue_type.dart';
import 'package:beotura/enums/venue_area.dart';
import 'package:beotura/screens/venue_detail_screen.dart'; // Added import
import 'package:flutter/material.dart';
// Import for ImageFilter
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math'; // Import for Random

import '../models/venue_model.dart';

class VenuesScreen extends StatefulHookConsumerWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  // Sample data - replace with actual data fetching
  final List<Venue> _allVenues = [
    Venue(
      id: '1',
      name: 'The Golden Keg',
      type: VenueType.BAR,
      imageUrl: 'https://picsum.photos/seed/venue1/800/600',
      description:
          'A historic bar with a wide selection of local craft beers. Known for its cozy atmosphere and traditional Serbian snacks.',
      vibe: VenueVibe.HISTORIC_AUTHENTIC,
      area: VenueArea.UPPER_DORCOL,
    ),
    Venue(
      id: '2',
      name: 'Trattoria Romana',
      type: VenueType.RESTAURANT,
      imageUrl: 'https://picsum.photos/seed/venue2/800/600',
      description:
          'Serving classic Roman dishes in a charming setting. Features a beautiful courtyard garden.',
      vibe: VenueVibe.ELEGANT_ROMANTIC,
      area: VenueArea.TRG,
    ),
    Venue(
      id: '3',
      name: 'Café Central',
      type: VenueType.CAFE,
      imageUrl: 'https://picsum.photos/seed/venue3/800/600',
      description:
          'A popular meeting spot for locals and tourists alike. Offers a variety of coffees, pastries, and light meals.',
      vibe: VenueVibe.LIVELY_TRENDY,
      area: VenueArea.KNEZ_MIHAILOVA,
    ),
    Venue(
      id: '4',
      name: 'National Museum',
      type: VenueType.MUSEUM,
      imageUrl: 'https://picsum.photos/seed/venue4/800/600',
      description:
          'Explore Serbian art and history from prehistoric times to the present day.',
      vibe: VenueVibe.HISTORIC_AUTHENTIC,
      area: VenueArea.TRG,
    ),
    Venue(
      id: '5',
      name: 'Kalemegdan Fortress',
      type: VenueType.HISTORICAL_SITE,
      imageUrl: 'https://picsum.photos/seed/venue5/800/600',
      description:
          'Ancient citadel overlooking the confluence of the Sava and Danube rivers. Rich in history and offering stunning views.',
      vibe: VenueVibe.MYSTERIOUS_HIDDEN,
      area: VenueArea.KALEMEGDAN,
    ),
    Venue(
      id: '6',
      name: 'Bohemian Quarter Skadarlija',
      type: VenueType.LANDMARK,
      imageUrl: 'https://picsum.photos/seed/venue6/800/600',
      description:
          'Famous cobblestone street with traditional restaurants, live music, and art galleries.',
      vibe: VenueVibe.ARTISTIC_BOHEMIAN,
      area: VenueArea.SKADARLIJA,
    ),
    Venue(
      id: '7',
      name: 'Modern Art Gallery',
      type: VenueType.GALLERY,
      imageUrl: 'https://picsum.photos/seed/venue7/800/600',
      description:
          'Contemporary art space featuring local and international artists.',
      vibe: VenueVibe.ARTISTIC_BOHEMIAN,
      area: VenueArea.DORCOL,
    ),
    Venue(
      id: '8',
      name: 'Sava Promenade',
      type: VenueType.LANDMARK,
      imageUrl: 'https://picsum.photos/seed/venue8/800/600',
      description:
          'A beautiful riverside walkway with cafes, restaurants, and recreational areas.',
      vibe: VenueVibe.RELAXED_COZY,
      area: VenueArea.SAVAMALA,
    ),
    Venue(
      id: '9',
      name: 'St. Sava Temple',
      type: VenueType.HISTORICAL_SITE, // Or Landmark
      imageUrl: 'https://picsum.photos/seed/venue9/800/600',
      description:
          'One of the largest Orthodox churches in the world, a stunning architectural masterpiece.',
      vibe: VenueVibe.HISTORIC_AUTHENTIC,
      area: VenueArea.VRACAR,
    ),
    Venue(
      id: '10',
      name: 'Ušće Shopping Center',
      type: VenueType.SHOP, // Assuming SHOP is a VenueType
      imageUrl: 'https://picsum.photos/seed/venue10/800/600',
      description:
          'A large modern shopping mall with a wide variety of stores, a cinema, and food court.',
      vibe: VenueVibe.LIVELY_TRENDY,
      area: VenueArea.NEW_BELGRADE,
    ),
    Venue(
      // Added a SHOW type venue for testing
      id: '11',
      name: 'Belgrade Drama Theatre',
      type: VenueType.SHOW,
      imageUrl: 'https://picsum.photos/seed/venue11/800/600',
      description:
          'Catch captivating theatrical performances at one of Belgrade\'s most renowned theatres.',
      vibe: VenueVibe.ELEGANT_ROMANTIC, // Example vibe
      area: VenueArea.VRACAR, // Example area
    ),
  ];

  List<Object> _shuffledFilters = [];
  final String _allVenuesIdentifier = "All Venues";

  @override
  void initState() {
    super.initState();
    // Initialize and shuffle filters once
    List<Object> tempFilters = [];
    tempFilters.addAll(VenueVibe.values);
    tempFilters.addAll(VenueType.values);
    tempFilters.addAll(VenueArea.values); // Added VenueArea
    tempFilters.shuffle(Random());
    _shuffledFilters = [_allVenuesIdentifier, ...tempFilters];
  }

  Widget _buildFilterChip(
    Object filterItem,
    bool isSelected,
    ValueNotifier<Object?> selectedFilterState,
  ) {
    String label;
    Color chipColor;
    Color textColor;
    VoidCallback onTap = () => selectedFilterState.value = filterItem;

    if (filterItem == _allVenuesIdentifier) {
      label = _allVenuesIdentifier;
      chipColor = Colors.blueGrey[700]!; // Distinct color for "All"
      textColor = Colors.white;
      onTap = () => selectedFilterState.value = null; // Null for "All Venues"
    } else if (filterItem is VenueVibe) {
      label = filterItem.displayName;
      final vibeTheme = VibeTheme.getTheme(filterItem);
      chipColor = vibeTheme.accentColor;
      textColor = vibeTheme.onAccentColor;
    } else if (filterItem is VenueType) {
      label = filterItem.displayName;
      chipColor = Theme.of(context).colorScheme.secondary.withOpacity(0.8);
      textColor = Colors.white;
    } else if (filterItem is VenueArea) {
      label = filterItem.displayName;
      chipColor = Theme.of(context)
          .colorScheme
          .tertiary
          .withOpacity(0.7); // Distinct color for Area
      textColor = Colors.white;
    } else {
      return const SizedBox.shrink(); // Should not happen
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onTap(),
        backgroundColor: isSelected ? chipColor : chipColor.withOpacity(0.15),
        selectedColor: chipColor,
        labelStyle: TextStyle(
          color: isSelected ? textColor : Colors.white.withOpacity(0.85),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? chipColor : chipColor.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        elevation: isSelected ? 2 : 0,
        selectedShadowColor: chipColor.withOpacity(0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = useState<Object?>(null);

    final filteredVenues = _allVenues.where((venue) {
      if (selectedFilter.value == null) return true; // "All Venues"
      if (selectedFilter.value is VenueVibe) {
        return venue.vibe == selectedFilter.value;
      }
      if (selectedFilter.value is VenueType) {
        return venue.type == selectedFilter.value;
      }
      if (selectedFilter.value is VenueArea) {
        // Added VenueArea check
        return venue.area == selectedFilter.value;
      }
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Combined, Shuffled Filter Bar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              itemCount: _shuffledFilters.length,
              itemBuilder: (context, index) {
                final filterItem = _shuffledFilters[index];
                bool isSelected;
                if (filterItem == _allVenuesIdentifier) {
                  isSelected = selectedFilter.value == null;
                } else {
                  isSelected = selectedFilter.value == filterItem;
                }
                return _buildFilterChip(
                  filterItem,
                  isSelected,
                  selectedFilter,
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVenues.length,
              itemBuilder: (context, index) {
                final venue = filteredVenues[index];
                final vibeTheme = VibeTheme.getTheme(venue.vibe);

                return InkWell(
                  // Wrapped Card with InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VenueDetailScreen(venue: venue),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    color: vibeTheme.backgroundColor.withOpacity(0.85),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: vibeTheme.accentColor.withOpacity(0.3),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Hero(
                          // Added Hero widget for image transition
                          tag: 'venue-image-${venue.id}',
                          child: Image.network(
                            venue.imageUrl,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                venue.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  color: vibeTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    const Shadow(
                                      blurRadius: 2.0,
                                      color: Colors.black54,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Using displayName for area as well
                                '${venue.type.displayName} - ${venue.area.displayName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(venue.vibe.displayName),
                                backgroundColor: vibeTheme.accentColor,
                                labelStyle: TextStyle(
                                    color: vibeTheme.onAccentColor,
                                    fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                elevation: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
