import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/tours_class.dart';
import '../classes/loactions_class.dart';
import '../classes/tour_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import 'details_screen.dart';
import '../widgets/document_renderer.dart';

class TourDetailsScreen extends ConsumerStatefulWidget {
  final Tour tour;

  const TourDetailsScreen({super.key, required this.tour});

  @override
  ConsumerState<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends ConsumerState<TourDetailsScreen> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late List<Widget> _pages = [];
  bool _isLoading = true;
  Tour? _completeTour;
  Timer? _loadingTimeout;
  bool _showSwipeIndicator = false;
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeAnimation;
  Timer? _swipeIndicatorTimer;
  bool _hasUserSwiped = false;
  final String _swipeCompletedKey = 'tour_swipe_completed';

  @override
  void initState() {
    super.initState();
    
    // Initialize swipe animation controller with slower animation
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Create a more subtle horizontal movement animation
    _swipeAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _swipeAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _swipeAnimationController.forward();
      }
    });
    
    // Start the animation
    _swipeAnimationController.forward();
    
    // Check if user has completed a swipe before
    _checkSwipeCompleted();
    
    // Delay initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCompleteTourData();
    });

    // Add a timeout to prevent infinite loading
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        debugPrint("Loading timeout - falling back to basic tour data");
        setState(() {
          _isLoading = false;
          _completeTour = widget.tour;
        });
        _initializePages();
      }
    });
  }

  // Check if the user has completed a swipe before
  Future<void> _checkSwipeCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSwipedBefore = prefs.getBool(_swipeCompletedKey) ?? false;
      
      if (mounted) {
        setState(() {
          _hasUserSwiped = hasSwipedBefore;
          _showSwipeIndicator = !hasSwipedBefore;
        });
      }
    } catch (e) {
      debugPrint("Error checking swipe preference: $e");
      // Default to showing the indicator if we can't check preferences
      if (mounted) {
        setState(() {
          _showSwipeIndicator = true;
        });
      }
    }
  }

  // Save that the user has completed a swipe
  Future<void> _saveSwipeCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_swipeCompletedKey, true);
      debugPrint("Saved swipe completed preference");
    } catch (e) {
      debugPrint("Error saving swipe preference: $e");
    }
  }

  // Handle user swipe
  void _handleUserSwipe(int newPage) {
    debugPrint("User swiped to page $newPage");
    
    // If this is the first time the user has swiped, save it
    if (!_hasUserSwiped) {
      _hasUserSwiped = true;
      _saveSwipeCompleted();
      
      // Hide the indicator
      if (mounted) {
        setState(() {
          _showSwipeIndicator = false;
        });
      }
    }
    
    // Update current page
    if (mounted) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  // Schedule showing the swipe indicator
  void _scheduleSwipeIndicator() {
    // Show indicator for a few seconds when pages are ready
    setState(() => _showSwipeIndicator = true);
    
    // Hide indicator after 5 seconds
    _swipeIndicatorTimer?.cancel();
    _swipeIndicatorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showSwipeIndicator = false);
      }
    });
  }

  // Fetch complete tour data using the tourByIdProvider
  Future<void> _fetchCompleteTourData() async {
    debugPrint("Fetching complete tour data for ID: ${widget.tour.id}");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the correctly defined provider
      final tourAsyncValue =
          await ref.read(tourByIdProvider(widget.tour.id).future);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _completeTour = tourAsyncValue ?? widget.tour;
      });

      _initializePages();
    } catch (e) {
      debugPrint("Exception in _fetchCompleteTourData: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _completeTour = widget.tour;
        });
        _initializePages();
      }
    }
  }

  void _initializePages() {
    if (!mounted) return;

    debugPrint("Initializing tour pages...");

    try {
      // Use the complete tour if available, otherwise use the basic tour
      final tour = _completeTour ?? widget.tour;
      final screenSize = MediaQuery.of(context).size;
      final useDescription = isContentEmpty(tour.frontPageContent_en);

      // Start with the cover page
      final List<Widget> newPages = [
        _buildCoverPage(tour, screenSize, useDescription),
      ];

      debugPrint("Created cover page. Adding other pages...");

      // Add pages from tour pages
      if (tour.pages.isNotEmpty) {
        debugPrint("Tour has ${tour.pages.length} pages to process");

        // Sort pages by order if available
        final sortedPages = List.of(tour.pages);
        sortedPages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        for (var page in sortedPages) {
          try {
            debugPrint(
                "Processing page: type=${page.type}, order=${page.order}");

            if (page.type == 'location' && page.location != null) {
              final location = page.location!;

              // Check if location has enough data to display
              if (_hasBasicLocationData(location)) {
                debugPrint(
                    "Adding location page: ${location.title_en ?? location.title}");

                // Choose the best available description
                final description = location.description_en?.isNotEmpty == true
                    ? location.description_en!
                    : (location.description.isNotEmpty == true
                        ? location.description
                        : "No description available");

                // Get image URL
                final imageUrl = location.imageUrl?.isNotEmpty == true
                    ? location.imageUrl!
                    : "https://via.placeholder.com/400x300?text=No+Image";

                newPages.add(_buildLocationDetailsPage(
                  location.title_en ?? location.title,
                  imageUrl,
                  description,
                ));
              } else {
                debugPrint("Skipping location with insufficient data");
              }
            } else if (page.type == 'content' && page.content_en != null) {
              debugPrint("Adding content page");
              newPages.add(_buildContentPage(
                page.content_en,
              ));
            }
          } catch (pageError) {
            debugPrint("Error processing page: $pageError");
          }
        }
      }

      debugPrint("Created ${newPages.length} pages total");

      if (mounted) {
        setState(() {
          _pages = newPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing pages: $e');
      if (mounted) {
        setState(() {
          _pages = [
            _buildErrorPage('Failed to load tour pages. Please try again.'),
          ];
          _isLoading = false;
        });
      }
    }

    // At the end of initializing pages, show the swipe indicator if multiple pages
    // and user hasn't swiped before
    if (mounted && _pages.length > 1 && !_hasUserSwiped) {
      setState(() {
        _showSwipeIndicator = true;
      });
    }
  }

  // Helper method to build a content page
  Widget _buildContentPage(dynamic content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              // Convert content to readable text format
              _extractTextFromContent(content),
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.justify,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Build a location details page directly without DetailsScreen
  Widget _buildLocationDetailsPage(
      String title, String imageUrl, String description) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
          ),

          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.justify,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  bool _hasBasicLocationData(Location location) {
    // Need at least a title
    final hasTitle = location.title_en?.isNotEmpty == true ||
        location.title.isNotEmpty == true;

    // And either a description or an image
    final hasDescription = location.description_en?.isNotEmpty == true ||
        location.description.isNotEmpty == true;

    final hasImage = location.imageUrl?.isNotEmpty == true;

    return hasTitle && (hasDescription || hasImage);
  }

  // Extract readable text from content JSON
  String _extractTextFromContent(dynamic content) {
    try {
      if (content == null) return '';

      // If it's already a string, return it
      if (content is String) return content;

      // If it's a document object from GraphQL
      if (content is Map && content.containsKey('document')) {
        final document = content['document'];
        if (document is String) {
          try {
            // Try to parse as JSON
            final parsed = jsonDecode(document);
            return _extractTextFromParagraphs(parsed);
          } catch (e) {
            return document;
          }
        } else if (document is List) {
          return _extractTextFromParagraphs(document);
        }
      }

      // Default fallback
      return content.toString();
    } catch (e) {
      print('Error extracting text: $e');
      return '';
    }
  }

  // Extract text from paragraph structure
  String _extractTextFromParagraphs(dynamic paragraphs) {
    StringBuffer result = StringBuffer();

    if (paragraphs is List) {
      for (var paragraph in paragraphs) {
        if (paragraph is Map &&
            paragraph.containsKey('type') &&
            paragraph['type'] == 'paragraph') {
          if (paragraph.containsKey('children') &&
              paragraph['children'] is List) {
            for (var child in paragraph['children']) {
              if (child is Map && child.containsKey('text')) {
                result.write(child['text']);
              }
            }
            result.write('\n\n'); // Add paragraph breaks
          }
        }
      }
    }

    return result.toString();
  }

  // Helper method to build the cover page
  Widget _buildCoverPage(Tour tour, Size screenSize, bool useDescription) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: screenSize.width,
                height: screenSize.height * 0.35,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.network(
                  tour.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Title below the image - with standardized font size
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              tour.title_en,
              style: TextStyle(
                fontSize: 26, // Standardized size
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible, // Ensures text wraps to new lines
            ),
          ),

          // Date created - centered
          if (tour.createdAt != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatDate(tour.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Content with fixed bottom padding (no double padding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: useDescription
                ? Text(
                    tour.description_en,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.justify,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  )
                : DocumentRenderer(
                    content: tour.frontPageContent_en,
                    defaultTextStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),

          // Single bottom margin
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Helper method to build a location page
  Widget _buildLocationPage(Location location) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location image with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                location.imageUrl ?? '',
                fit: BoxFit.cover,
                height: 220,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
          ),

          // Location title with standardized font size
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              location.title_en ?? location.title,
              style: TextStyle(
                fontSize: 26, // Standardized size
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible, // Ensures text wraps to new lines
            ),
          ),

          const SizedBox(height: 16),

          // Location description with improved formatting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              location.description_en ?? location.description ?? '',
              style: const TextStyle(
                fontSize: 16,
                height: 1.8, // Increased line height
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.justify,
              softWrap: true,
              overflow: TextOverflow.visible, // Ensures text wraps to new lines
            ),
          ),

          // Single bottom margin
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Helper method to check if frontPageContent is effectively empty
  bool isContentEmpty(dynamic content) {
    if (content == null) return true;

    // If it's already a string, check if it's empty
    if (content is String) {
      return content.trim().isEmpty;
    }

    // If it's a list, check if it's empty or only contains empty paragraphs
    if (content is List) {
      if (content.isEmpty) return true;

      // Check for the pattern of empty paragraphs
      bool hasContent = false;
      for (var item in content) {
        if (item is Map<String, dynamic> &&
            item['type'] == 'paragraph' &&
            item['children'] is List) {
          var children = item['children'] as List;
          for (var child in children) {
            if (child is Map<String, dynamic> &&
                child['text'] is String &&
                child['text'].toString().trim().isNotEmpty) {
              hasContent = true;
              break;
            }
          }
        }
        if (hasContent) break;
      }
      return !hasContent;
    }

    // Try to convert to string and check
    try {
      final String contentStr = content.toString();
      if (contentStr.contains('"text":""') &&
          !contentStr.contains('"text":"')) {
        return true;
      }
      return contentStr.trim() == '[]' || contentStr.trim().isEmpty;
    } catch (_) {
      return false; // When in doubt, assume there's content
    }
  }

  // Format date nicely
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    _swipeIndicatorTimer?.cancel();
    _swipeAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tour = _completeTour ?? widget.tour;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            tour.title_en,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Loading tour content...",
                style: TextStyle(fontSize: 16),
              ),
              if (_completeTour == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Fetching complete tour data...",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final totalPages = _pages.length;
    debugPrint("Building tour view with $_currentPage/$totalPages pages");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tour.title_en,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: kToolbarHeight * 1.2,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1}/$totalPages',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Page view with tour content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              _handleUserSwipe(index);
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          
          // Swipe indicator overlay - only show if user hasn't swiped yet and there are multiple pages
          if (_showSwipeIndicator && totalPages > 1 && !_hasUserSwiped)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _swipeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_swipeAnimation.value, 0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Swipe to navigate",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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

  // Helper method to build an error page
  Widget _buildErrorPage(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Error",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
