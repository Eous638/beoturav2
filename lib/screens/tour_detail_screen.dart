import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/immersive_tour_page.dart';
import '../classes/tours_class.dart';
import '../widgets/tour_components/title_component.dart';
import '../widgets/tour_components/paragraph_component.dart';
import '../widgets/tour_components/image_component.dart';
import '../widgets/tour_components/prompt_component.dart';
import '../widgets/tour_components/map_component.dart';
import '../widgets/tour_components/button_component.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final Tour tour;

  const TourDetailScreen({
    super.key,
    required this.tour,
  });

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  late ImmersiveTour _immersiveTour;
  final PageController _pageController = PageController();
  final List<ScrollController> _scrollControllers = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoadingTour = true;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTour();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadTour() async {
    setState(() {
      _isLoadingTour = true;
    });

    try {
      // In a real app, this would be loaded from an API
      // Here we're creating a sample tour with different page types
      final sampleTourJson = {
        "id": widget.tour.id,
        "title": widget.tour.title_en,
        "theme": {
          "primaryColor": "#f5f3ff", // light paper background
          "accentColor": "#7c3aed", // purple accent
          "font": "serif"
        },
        "pages": [
          // Title page example (intro screen)
          {
            "id": "page-001",
            "type": "title",
            "unlock": "immediate",
            "title": widget.tour.title_en,
            "subtitle": "Discover the hidden stories of this historic location",
            "imageUrl": widget.tour.imageUrl,
            "authorName": "Beotura Tours",
            "description":
                "Join us on a journey through time and space as we explore the fascinating history of this location.",
            "showStartButton": true,
            "suggestedTime": "Morning",
            "startLocation": {
              "lat": 44.8226,
              "lng": 20.4506,
              "label": "Kalemegdan Fortress"
            }
          },

          // Navigation page with image example
          {
            "id": "page-002",
            "type": "nav",
            "unlock": "immediate",
            "imageUrl": widget.tour.imageUrl,
            "instructions":
                "Follow the path to the main entrance. Look for the stone archway adorned with ancient symbols.",
            "showMap": false
          },

          // Navigation page with map example
          {
            "id": "page-003",
            "type": "nav",
            "unlock": {
              "mode": "walk",
              "distance_meters": 50,
              "message": "Walk to the location to continue"
            },
            "instructions":
                "Navigate to the marked locations on the map to discover hidden historical sites.",
            "showMap": true,
            "mapMarkers": [
              {
                "lat": 44.8226,
                "lng": 20.4506,
                "label": "Kalemegdan Fortress",
                "description":
                    "Ancient citadel with structures dating from Roman, Byzantine, Ottoman, and Austrian periods."
              },
              {
                "lat": 44.8178,
                "lng": 20.4569,
                "label": "Skadarlija",
                "description":
                    "19th-century bohemian quarter where Serbian artists and intellectuals gathered."
              }
            ]
          },

          // Content page example
          {
            "id": "page-004",
            "type": "content",
            "unlock": "immediate",
            "background": {"image": widget.tour.imageUrl, "audio": null},
            "content": [
              {"component": "title", "text": "The Rich History"},
              {
                "component": "paragraph",
                "text":
                    "This area has been inhabited since ancient times, with archaeological evidence suggesting settlement as early as 7000 BCE. Throughout the centuries, various civilizations have left their mark on this land."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "Historical artifacts discovered during excavations in the early 20th century."
              },
              {
                "component": "paragraph",
                "text":
                    "The strategic importance of this location led to numerous conflicts over control of the region, with each ruling power adding their own architectural and cultural influences."
              }
            ]
          },

          // Content page with map
          {
            "id": "page-006",
            "type": "content",
            "unlock": "immediate",
            "content": [
              {"component": "title", "text": "Points of Interest"},
              {
                "component": "paragraph",
                "text":
                    "Explore these key historical sites to understand the full context of the region's development over time."
              },
              {
                "component": "map",
                "markers": [
                  {
                    "lat": 44.8226,
                    "lng": 20.4506,
                    "label": "Site A",
                    "description": "Ancient ruins dating to 3rd century BCE."
                  },
                  {
                    "lat": 44.8178,
                    "lng": 20.4569,
                    "label": "Site B",
                    "description": "Medieval church with unique frescoes."
                  },
                  {
                    "lat": 44.8048,
                    "lng": 20.4744,
                    "label": "Site C",
                    "description":
                        "19th century industrial complex showing early modernization."
                  }
                ]
              },
              {
                "component": "paragraph",
                "text":
                    "Each site offers a glimpse into a different era of the region's complex history."
              }
            ]
          },

          // Conclusion page
          {
            "id": "page-007",
            "type": "content",
            "unlock": "immediate",
            "content": [
              {"component": "title", "text": "Your Journey Continues"},
              {
                "component": "paragraph",
                "text":
                    "We hope you've enjoyed this tour and gained a deeper appreciation for the rich tapestry of history woven into this landscape. The stories of this place continue to unfold, and now you are part of its ongoing narrative."
              },
              {
                "component": "paragraph",
                "text":
                    "Feel free to revisit any of the sites at your leisure to further explore their significance."
              },
              {"component": "button", "text": "End Tour", "action": "endTour"}
            ]
          }
        ]
      };

      _immersiveTour = ImmersiveTour.fromJson(sampleTourJson);

      // Create scroll controllers for each page
      for (int i = 0; i < _immersiveTour.pages.length; i++) {
        _scrollControllers.add(ScrollController());
      }
    } catch (e) {
      debugPrint('Error loading tour: $e');
    } finally {
      setState(() {
        _isLoadingTour = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get current position
    try {
      // _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting position: $e');
    }
  }

  // Handle page change
  void _onPageChanged(int page) async {
    setState(() {
      _currentPageIndex = page;
    });

    // Play background audio if available for content pages
    final currentPage = _immersiveTour.pages[page];
    if (currentPage is ContentPage && currentPage.background?.audio != null) {
      try {
        await _audioPlayer
            .setAsset('assets/audio/${currentPage.background!.audio}');
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    } else {
      // Stop any playing audio
      _audioPlayer.stop();
    }
  }

  // Build a content component
  Widget _buildContentComponent(ContentComponent component) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    // Force text color to white
    const textColor = Colors.white;

    switch (component.component) {
      case 'title':
        return TitleComponent(
          text: component.text ?? '',
          style: theme.textTheme.headlineSmall!
              .copyWith(fontWeight: FontWeight.bold, color: textColor),
        );
      case 'paragraph':
        return ParagraphComponent(
          text: component.text ?? '',
          style: theme.textTheme.bodyMedium!.copyWith(color: textColor),
        );
      case 'prompt':
        return PromptComponent(
          text: component.text ?? '',
          style: theme.textTheme.titleMedium!.copyWith(
            fontStyle: FontStyle.italic,
            color: accentColor,
          ),
        );
      case 'image':
        return ImageComponent(
          imageUrl: component.src ?? '',
          caption: component.caption,
          src: '',
          captionStyle: theme.textTheme.bodySmall!
              .copyWith(fontStyle: FontStyle.italic, color: textColor),
        );
      case 'map':
        List<MapMarker> mapMarkers = [];
        if (component.markers != null) {
          for (var marker in component.markers!) {
            mapMarkers.add(MapMarker(
              lat: marker['lat'] ?? 0.0,
              lng: marker['lng'] ?? 0.0,
              label: marker['label'] ?? '',
              description: marker['description'],
            ));
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: MapComponent(
            markers: mapMarkers,
            showRouteFromUser: false,
          ),
        );
      case 'button':
        return ButtonComponent(
          text: component.text ?? 'Button',
          action: component.action,
          textColor: Colors.white,
          backgroundColor: accentColor,
          onTap: () {
            if (component.action == 'endTour') {
              Navigator.of(context).pop();
            }
          },
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text('Unknown component: \\${component.component}',
              style: const TextStyle(color: textColor)),
        );
    }
  }

  // Build a title page
  Widget _buildTitlePage(TitlePage page) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            controller: _scrollControllers[_currentPageIndex],
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tour image
                  if (page.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        page.imageUrl!,
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          color: Colors.grey[600],
                          child: const Icon(Icons.broken_image,
                              color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Tour title
                  Text(
                    page.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    page.subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (page.authorName != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'By ${page.authorName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (page.description != null) ...[
                    const SizedBox(height: 18),
                    Text(
                      page.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: textColor.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Suggested time and start location
                  if (page.suggestedTime != null || page.startLocation != null)
                    Column(
                      children: [
                        if (page.suggestedTime != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time, color: accentColor),
                              const SizedBox(width: 6),
                              Text(
                                'Suggested: ${page.suggestedTime}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (page.startLocation != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.place, color: accentColor),
                              const SizedBox(width: 6),
                              Text(
                                page.startLocation?['label'] ??
                                    'Start Location',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              final lat = page.startLocation?['lat'];
                              final lng = page.startLocation?['lng'];
                              final url =
                                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                              launchUrl(Uri.parse(url));
                            },
                            icon: const Icon(Icons.navigation,
                                color: Colors.white),
                            label: const Text('Navigate to Start',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Start button
                  if (page.showStartButton)
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_immersiveTour.pages.length > 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Begin Tour',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build a navigation page
  Widget _buildNavigationPage(NavigationPage page) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    // Use FMCTileProvider or Google Maps as appropriate
    // For demonstration, we show a route from current location to the first marker (if any)
    // In a real app, you would use a navigation/map widget that supports routing and step-by-step navigation
    final hasRoute = page.mapMarkers != null && page.mapMarkers!.isNotEmpty;
    final destination = hasRoute ? page.mapMarkers!.first : null;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and page indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: accentColor,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: accentColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPageIndex + 1}/${_immersiveTour.pages.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Column(
                children: [
                  if (hasRoute && destination != null)
                    Expanded(
                      child: MapComponent(
                        markers: [destination],
                        showRouteFromUser:
                            true, // You would implement this in MapComponent
                        initialLat: destination.lat,
                        initialLng: destination.lng,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      page.instructions,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a content page
  Widget _buildContentPage(ContentPage page) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button and page indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: accentColor,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: accentColor.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPageIndex + 1}/${_immersiveTour.pages.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                controller: _scrollControllers[_currentPageIndex],
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...page.content.map((component) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildContentComponent(component),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a page based on its type
  Widget _buildPage(TourPage page) {
    if (page is TitlePage) {
      return _buildTitlePage(page);
    } else if (page is NavigationPage) {
      return _buildNavigationPage(page);
    } else if (page is ContentPage) {
      return _buildContentPage(page);
    } else {
      return Center(child: Text('Unknown page type: \\${page.type}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTour) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading "${widget.tour.title}"...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _immersiveTour.pages.length,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final page = _immersiveTour.pages[index];
          return _buildPage(page);
        },
      ),
    );
  }
}
