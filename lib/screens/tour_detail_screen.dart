import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';

import '../models/immersive_tour_page.dart';
import '../classes/tours_class.dart';
import '../providers/language_provider.dart';
import '../enums/language_enum.dart';
import '../widgets/tour_components/title_component.dart';
import '../widgets/tour_components/paragraph_component.dart';
import '../widgets/tour_components/image_component.dart';
import '../widgets/tour_components/prompt_component.dart';
import '../widgets/tour_components/map_component.dart';
import '../widgets/tour_components/video_component.dart';
import '../widgets/tour_components/button_component.dart';
import '../widgets/tour_components/unlock_overlay.dart';

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
  final List<double> _scrollPositions = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Position? _currentPosition;
  bool _isLoadingTour = true;
  int _currentPageIndex = 0;
  bool _canSwipeToNextPage = false;

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
      // Create a much richer and more historically engaging immersive tour
      // In a real app, this would be loaded from an API or parsed from the Tour object

      // Create enhanced tour data with more content and historical context
      final enhancedTourJson = {
        "id": widget.tour.id,
        "title": widget.tour.title,
        "theme": {
          "primaryColor": "#111111",
          "accentColor": "#E63946",
          "font": "serif"
        },
        "pages": [
          // Page 1: Introduction - The Gateway to Belgrade's History
          {
            "id": "page-001",
            "type": "scrollable",
            "unlock": "immediate",
            "background": {"image": widget.tour.imageUrl, "audio": null},
            "content": [
              {
                "component": "title",
                "text": "The Gateway to Belgrade's History"
              },
              {
                "component": "prompt",
                "text":
                    "Stand at the crossroads where empires collided and civilizations converged."
              },
              {
                "component": "paragraph",
                "text":
                    "Before you stretches a landscape that has witnessed the rise and fall of countless powers. Belgrade, the 'White City,' stands at the confluence of the Sava and Danube rivers—a strategic position that has made it both a coveted prize and a cultural melting pot for over 7,000 years."
              },
              {
                "component": "paragraph",
                "text":
                    "Look beyond the bustling streets of the modern city and you'll find layers of history embedded in its architecture, customs, and spirit. Romans, Byzantines, Ottomans, Austro-Hungarians—all have left their mark on this resilient city that has been destroyed and rebuilt over 40 times throughout its tumultuous history."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The historic entrance to Kalemegdan Fortress, a silent witness to Belgrade's many transformations."
              },
              {
                "component": "paragraph",
                "text":
                    "Today, we begin a journey through time, exploring the hidden stories and forgotten spaces that have shaped Belgrade's unique character. From ancient fortifications to underground passages, from imperial palaces to modernist monuments—each site reveals another chapter in the epic tale of a city that has always been at the crossroads of East and West."
              },
              {
                "component": "paragraph",
                "text":
                    "As you stand here, take a moment to feel the weight of history beneath your feet. The path ahead will take you through centuries of triumph and tragedy, resistance and rebirth."
              }
            ]
          },

          // Page 2: Kalemegdan Fortress - The Ancient Citadel
          {
            "id": "page-002",
            "type": "scrollable",
            "unlock": {
              "mode": "walk",
              "distance_meters": 80,
              "message": "Walk to Kalemegdan Fortress to continue"
            },
            "background": {"image": widget.tour.imageUrl, "audio": null},
            "content": [
              {
                "component": "title",
                "text": "Kalemegdan Fortress: The Ancient Citadel"
              },
              {
                "component": "paragraph",
                "text":
                    "You've reached Kalemegdan, Belgrade's ancient citadel and its most important historical monument. Rising above the confluence of the Sava and Danube rivers, this fortress has stood guard over the city since Celtic times, though what you see today is primarily the result of Ottoman and Austro-Hungarian construction."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The imposing walls of Kalemegdan Fortress offer panoramic views of the rivers below."
              },
              {
                "component": "paragraph",
                "text":
                    "In the Roman era, this site housed the castrum of Singidunum. Later, Byzantine Emperor Justinian I rebuilt it as a powerful stronghold against barbarian invasions. The Slavic name 'Beograd' (White City) likely referred to the white stone walls that gleamed in the sunlight, visible from great distances to travelers approaching by river."
              },
              {
                "component": "paragraph",
                "text":
                    "During the Ottoman-Habsburg wars, Kalemegdan changed hands numerous times. Each power left its architectural signature: Ottoman minarets and hammams stood alongside Austrian baroque gates and neoclassical facades. The fortress has 18 gates in total, each with its own story of sieges withstood and battles won and lost."
              },
              {
                "component": "paragraph",
                "text":
                    "Walk these ramparts and you walk in the footsteps of Celtic warriors, Roman legionaries, Byzantine soldiers, Ottoman janissaries, and Austrian dragoons. Few places in Europe have witnessed such a continuous parade of civilizations."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The Victor Monument (Pobednik), installed in 1928, commemorates Serbia's victory over Ottoman and Austro-Hungarian forces."
              },
              {
                "component": "paragraph",
                "text":
                    "Today, the fortress is Belgrade's most beloved park, where chess players gather under ancient trees and lovers stroll along paths once patrolled by armed guards. The Military Museum houses collections spanning from Roman times to the NATO bombing of 1999, while the former gunpowder magazine now serves as an astronomical observatory."
              }
            ]
          },

          // Page 3: Skadarlija - The Bohemian Quarter
          {
            "id": "page-003",
            "type": "scrollable",
            "unlock": {
              "mode": "walk",
              "distance_meters": 120,
              "message": "Walk to Skadarlija to continue"
            },
            "background": {"image": widget.tour.imageUrl, "audio": null},
            "content": [
              {
                "component": "title",
                "text": "Skadarlija: Belgrade's Bohemian Heart"
              },
              {
                "component": "prompt",
                "text":
                    "Step into the cobblestone street where poetry and wine once flowed in equal measure."
              },
              {
                "component": "paragraph",
                "text":
                    "You've arrived at Skadarlija, often compared to Paris's Montmartre—a cobblestone street that has been the bohemian soul of Belgrade for over a century. In the late 19th and early 20th centuries, this was where the city's artists, writers, poets, and musicians gathered to create, debate, and carouse into the early hours."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The charming cobblestone pathway of Skadarlija with its distinctive 19th-century architecture."
              },
              {
                "component": "paragraph",
                "text":
                    "The kafanas (traditional Serbian taverns) of Skadarlija—Tri Šešira (Three Hats), Dva Jelena (Two Deer), and Zlatni Bokal (Golden Jug)—were the living rooms for Serbia's cultural elite. Poets like Tin Ujević and Branislav Nušić composed verses at these tables, while painter Đura Jakšić lived in a house that still stands on this street."
              },
              {
                "component": "paragraph",
                "text":
                    "After the demolition of the Dardaneli kafana in 1901 (which stood near today's National Museum), many artists relocated to Skadarlija, cementing its reputation as a haven for creative spirits. During the interwar period, visiting luminaries like Alfred Hitchcock and King Edward VIII came to experience the street's legendary atmosphere."
              },
              {
                "component": "paragraph",
                "text":
                    "Though commercialization has changed aspects of Skadarlija since its heyday, you can still feel echoes of its bohemian past in the traditional orchestras playing old urban songs called starogradska muzika, the servers dressed in traditional costumes, and the photographs of literary giants adorning the walls of establishments that have stood for generations."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "Musicians performing traditional Serbian folk music in one of Skadarlija's historic kafanas."
              },
              {
                "component": "paragraph",
                "text":
                    "As you walk these cobblestones, imagine the heated discussions about art and politics, the impromptu poetry recitals, and the passionate romances that unfolded here—a bohemian tradition that continues, in spirit if not in exact form, to the present day."
              }
            ]
          },

          // Page 4: Nikola Tesla Museum - The Visionary's Legacy
          {
            "id": "page-004",
            "type": "scrollable",
            "unlock": {
              "mode": "walk",
              "distance_meters": 150,
              "message": "Walk to the Nikola Tesla Museum to continue"
            },
            "background": {"image": widget.tour.imageUrl, "audio": null},
            "content": [
              {
                "component": "title",
                "text": "The Nikola Tesla Museum: A Visionary's Legacy"
              },
              {
                "component": "paragraph",
                "text":
                    "Welcome to the Nikola Tesla Museum, housed in a elegant 1920s villa in the upscale Vračar district. This museum is dedicated to the life and work of Serbia's most famous son—the brilliant inventor who, in many ways, designed our modern world."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The Nikola Tesla Museum, established in 1952, houses the inventor's personal effects and interactive demonstrations of his work."
              },
              {
                "component": "paragraph",
                "text":
                    "Born to Serbian parents in what is now Croatia in 1856, Tesla revolutionized our understanding of electricity. His alternating current (AC) system powers homes and businesses worldwide. He pioneered wireless technology, remote control, and even laid the groundwork for technologies we still use today, from X-ray machines to radio to wireless power transmission."
              },
              {
                "component": "paragraph",
                "text":
                    "After his death in New York in 1943, Tesla's ashes were transferred to Belgrade in 1957. The brass sphere in the museum's courtyard contains these ashes—a fitting tribute to a man whose mind constantly contemplated the spherical transmission of energy through space."
              },
              {
                "component": "paragraph",
                "text":
                    "Inside the museum, you'll find Tesla's personal items, detailed models of his inventions, and original documents including his famous patents. The highlight for many visitors is the demonstration room, where museum staff recreate Tesla's experiments with wireless electricity, causing fluorescent tubes to light up without any connection to a power source—a feat that still seems magical today."
              },
              {
                "component": "paragraph",
                "text":
                    "Tesla's relationship with his homeland was complex. Though he left the region as a young man and spent most of his productive years in America, he maintained a strong Serbian identity. Today, he is celebrated as a national hero in Serbia—his image appears on the 100 dinar note, and Belgrade's international airport bears his name."
              },
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "A working Tesla coil demonstration at the museum, producing artificial lightning just as Tesla did in his experiments."
              },
              {
                "component": "paragraph",
                "text":
                    "As you explore the museum, consider this paradox: Tesla died nearly penniless despite giving the world innovations worth billions. His story reminds us that progress often comes not from those seeking fortune, but from dreamers whose vision extends beyond their own lifetime."
              }
            ]
          },

          // Page 5: Interactive Map of Historical Sites
          {
            "id": "page-005",
            "type": "scrollable",
            "unlock": "immediate",
            "content": [
              {
                "component": "title",
                "text": "Belgrade Through the Ages: Historical Map"
              },
              {
                "component": "paragraph",
                "text":
                    "Belgrade's rich history is written across its urban landscape. This interactive map highlights key historical sites from different eras, allowing you to trace the city's evolution from ancient fortress to modern European capital."
              },
              {
                "component": "paragraph",
                "text":
                    "Each marker represents a different historical period or significant event. Tap on any marker to learn more about its historical context and importance to Belgrade's development."
              },
              {
                "component": "map",
                "markers": [
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
                  },
                  {
                    "lat": 44.8048,
                    "lng": 20.4744,
                    "label": "Nikola Tesla Museum",
                    "description":
                        "Dedicated to Serbia's greatest inventor, housing his personal effects and interactive exhibits."
                  },
                  {
                    "lat": 44.8232,
                    "lng": 20.4593,
                    "label": "Knez Mihailova Street",
                    "description":
                        "Belgrade's main pedestrian zone with buildings showcasing 19th-century architecture."
                  },
                  {
                    "lat": 44.8131,
                    "lng": 20.4652,
                    "label": "Republic Square",
                    "description":
                        "The central square home to the National Museum and National Theatre."
                  },
                  {
                    "lat": 44.7866,
                    "lng": 20.4489,
                    "label": "Museum of Yugoslav History",
                    "description":
                        "Complex housing Tito's mausoleum and exhibitions on the socialist era."
                  }
                ]
              },
              {
                "component": "paragraph",
                "text":
                    "As you can see, Belgrade's historical sites span from the ancient confluence fortress to the modernist monuments of the 20th century. Each era has added another layer to the city's complex identity."
              },
              {
                "component": "paragraph",
                "text":
                    "If you wish to continue exploring specific locations in depth, you can use this map as a reference for planning your next adventures through Belgrade's rich historical landscape."
              }
            ]
          },

          // Page 6: Conclusion and Reflection
          {
            "id": "page-006",
            "type": "scrollable",
            "unlock": "immediate",
            "content": [
              {"component": "title", "text": "Belgrade: Where History Lives"},
              {
                "component": "image",
                "src": widget.tour.imageUrl,
                "caption":
                    "The sun setting over Belgrade, illuminating thousands of years of history."
              },
              {
                "component": "paragraph",
                "text":
                    "You've now journeyed through some of Belgrade's most significant historical sites, from the ancient fortress overlooking the rivers to the bohemian streets where cultural revolutions were born to the museum celebrating one of history's greatest innovators."
              },
              {
                "component": "paragraph",
                "text":
                    "What makes Belgrade unique is not just the individual monuments or locations, but how they intertwine to tell a story of resilience and reinvention. Few European capitals have changed hands so many times or risen from destruction so repeatedly. This history is not confined to museums—it lives in the daily rhythm of the city, in the blend of architectural styles, in the fusion of cultures evident in everything from the cuisine to the language."
              },
              {
                "component": "paragraph",
                "text":
                    "As the writer Miloš Crnjanski once observed: 'Belgrade is more than a city; it is a metaphor for a certain kind of immortality.' The city endures because it adapts, incorporating each new influence while maintaining its essential character."
              },
              {
                "component": "paragraph",
                "text":
                    "Whether you are a visitor or a resident, we hope this tour has deepened your appreciation for the layers of history beneath your feet. The next time you walk these streets, perhaps you'll see beyond the modern facade to the centuries of human drama that have unfolded here."
              },
              {
                "component": "paragraph",
                "text":
                    "Thank you for joining us on this journey through time. Belgrade's story continues to unfold, and now you are part of its ongoing narrative."
              },
              {"component": "button", "text": "End Tour", "action": "endTour"}
            ]
          }
        ]
      };

      _immersiveTour = ImmersiveTour.fromJson(enhancedTourJson);

      // Create scroll controllers for each page
      for (int i = 0; i < _immersiveTour.pages.length; i++) {
        _scrollControllers.add(ScrollController());
        _scrollPositions.add(0.0);

        // Set first page as unlocked
        if (i == 0) {
          _immersiveTour.pages[i].isUnlocked = true;
        }
      }

      // Add scroll listeners for each controller
      for (int i = 0; i < _scrollControllers.length; i++) {
        _scrollControllers[i].addListener(() {
          _handleScroll(i);
        });
      }
    } catch (e) {
      debugPrint('Error loading tour: $e');
    } finally {
      setState(() {
        _isLoadingTour = false;
      });
    }
  }

  // Handle scroll events to determine when user can swipe to next page
  void _handleScroll(int pageIndex) {
    if (pageIndex != _currentPageIndex) return;

    final scrollController = _scrollControllers[pageIndex];
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    _scrollPositions[pageIndex] = currentScroll;

    // Enable swiping to next page when user has scrolled to ~80% of content
    final canSwipe = currentScroll >= maxScroll * 0.8;

    if (canSwipe != _canSwipeToNextPage) {
      setState(() {
        _canSwipeToNextPage = canSwipe;
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
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting position: $e');
    }
  }

  // Check if user has walked the required distance to unlock a page
  Future<bool> _checkDistanceCondition(UnlockCondition condition) async {
    if (condition.isImmediate) return true;
    if (!condition.isWalk || condition.distanceMeters == null) return false;

    try {
      final newPosition = await Geolocator.getCurrentPosition();
      if (_currentPosition == null) {
        _currentPosition = newPosition;
        return false;
      }

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      _currentPosition = newPosition;

      return distance >= condition.distanceMeters!;
    } catch (e) {
      debugPrint('Error checking distance: $e');
      return false;
    }
  }

  // Try to unlock the next page
  Future<void> _tryUnlockNextPage() async {
    if (_currentPageIndex >= _immersiveTour.pages.length - 1) return;

    final nextPage = _immersiveTour.pages[_currentPageIndex + 1];
    if (nextPage.isUnlocked) return;

    final condition = nextPage.unlock;

    if (condition.isImmediate) {
      setState(() {
        nextPage.isUnlocked = true;
      });
      return;
    }

    final unlocked = await _checkDistanceCondition(condition);
    if (unlocked) {
      setState(() {
        nextPage.isUnlocked = true;
      });
    }
  }

  // Handle page change
  void _onPageChanged(int page) async {
    setState(() {
      _currentPageIndex = page;
      _canSwipeToNextPage = false;
    });

    // Try to unlock next page when moving to a new page
    _tryUnlockNextPage();

    // Play background audio if available
    final currentPage = _immersiveTour.pages[page];
    if (currentPage.background?.audio != null) {
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

  // Render a component based on its type
  Widget _buildComponent(TourPageComponent component) {
    final currentLanguage = ref.watch(languageProvider);
    final isEnglish = currentLanguage == Language.english;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (component.component) {
      case 'title':
        return TitleComponent(
          text: component.text ?? '',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        );
      case 'paragraph':
        return ParagraphComponent(
          text: component.text ?? '',
          style: TextStyle(
            fontSize: 17,
            height: 1.6,
            fontFamily: 'Times New Roman',
            color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
        );
      case 'prompt':
        return PromptComponent(
          text: component.text ?? '',
          style: TextStyle(
            fontSize: 19,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.amber[100] : Colors.grey[800],
            fontFamily: 'Times New Roman',
          ),
        );
      case 'image':
        return ImageComponent(
          imageUrl: component.src ?? '',
          caption: component.caption,
          src: '',
          captionStyle: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        );
      case 'video':
        return VideoComponent(
          videoUrl: component.src ?? '',
          autoplay: component.autoplay ?? false,
          loop: component.loop ?? false,
        );
      case 'map':
        return MapComponent(
            markers: (component.markers as List).cast<MapMarker>());
      case 'button':
        return ButtonComponent(
          text: component.text ?? 'Button',
          action: component.action,
          onTap: () {
            if (component.action == 'endTour') {
              Navigator.of(context).pop();
            }
          },
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text('Unknown component: ${component.component}'),
        );
    }
  }

  // Build a page with its components in a newspaper-like layout
  Widget _buildPage(ImmersiveTourPage page, int pageIndex) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.grey[100],
      ),
      child: Stack(
        children: [
          // Newspaper-style content container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: ListView(
              controller: _scrollControllers[pageIndex],
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 100,
                left: 20,
                right: 20,
              ),
              physics: const ClampingScrollPhysics(),
              children: [
                // Header image if available
                if (page.background?.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: Image.network(
                        page.background!.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Tour content with newspaper styling
                ...page.content.map((component) {
                  // For better newspaper layout, add dividers between sections
                  if (component.component == 'title' &&
                      page.content.indexOf(component) > 0) {
                    return Column(
                      children: [
                        Divider(
                          height: 40,
                          thickness: 1,
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        ),
                        _buildComponent(component),
                      ],
                    );
                  }
                  return _buildComponent(component);
                }),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? Colors.grey[850]!.withOpacity(0.7)
                      : Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Swipe indicator that appears when scrolled to bottom
          if (_canSwipeToNextPage &&
              pageIndex < _immersiveTour.pages.length - 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[850]!.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue to next section',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Page indicator
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[850]!.withOpacity(0.7)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  '${pageIndex + 1}/${_immersiveTour.pages.length}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman',
                  ),
                ),
              ),
            ),
          ),

          // Unlock overlay - shown when page is locked
          if (pageIndex > 0 && !page.isUnlocked)
            UnlockOverlay(
              unlockCondition: page.unlock,
              onUnlock: () {
                setState(() {
                  page.isUnlocked = true;
                });
              },
              message: '',
              progress: 0.0,
              onOverride: () {},
            ),
        ],
      ),
    );
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
      body: PageView.builder(
        controller: _pageController,
        itemCount: _immersiveTour.pages.length,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final page = _immersiveTour.pages[index];

          // Don't allow swiping to locked pages
          if (index > 0 && !page.isUnlocked) {
            return Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey[100],
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.unlock.message ??
                            'This part of the tour is locked',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 18,
                          fontFamily: 'Times New Roman',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return _buildPage(page, index);
        },
      ),
    );
  }
}
