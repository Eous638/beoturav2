import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchVisible = true;
  bool _isFilterActive = true;
  String _activeContentType = 'all';
  String? _activeTheme; // Changed to single selection

  AnimationController? _searchAnimationController;
  Animation<double>? _searchAnimation;

  // Content type filters with icons
  static const List<Map<String, dynamic>> _contentTypes = [
    {'id': 'all', 'name': 'All', 'icon': Icons.explore, 'color': 0xFF666666},
    {
      'id': 'stories',
      'name': 'Stories',
      'icon': Icons.auto_stories,
      'color': 0xFF6366F1
    },
    {'id': 'tours', 'name': 'Tours', 'icon': Icons.route, 'color': 0xFF10B981},
    {
      'id': 'venues',
      'name': 'Venues',
      'icon': Icons.restaurant,
      'color': 0xFFF59E0B
    },
    {
      'id': 'landmarks',
      'name': 'Landmarks',
      'icon': Icons.account_balance,
      'color': 0xFF8B5CF6
    },
    {
      'id': 'monuments',
      'name': 'Monuments',
      'icon': Icons.museum,
      'color': 0xFFEC4899
    },
    {
      'id': 'audio',
      'name': 'Audio',
      'icon': Icons.headphones,
      'color': 0xFF06B6D4
    },
    {
      'id': 'nearby',
      'name': 'Nearby',
      'icon': Icons.near_me,
      'color': 0xFFEF4444
    },
  ];

  // Fun creative themes
  static const List<Map<String, dynamic>> _funThemes = [
    {
      'id': 'spicy',
      'name': '🌶️ Spicy Stories',
      'subtitle': 'Drama & Scandal',
      'gradient': [0xFFDC2626, 0xFFEF4444],
      'emoji': '🌶️'
    },
    {
      'id': 'mystery',
      'name': '🕵️ Mystery Mode',
      'subtitle': 'Hidden Secrets',
      'gradient': [0xFF7C2D12, 0xFF9A3412],
      'emoji': '🕵️'
    },
    {
      'id': 'romantic',
      'name': '💕 Love Stories',
      'subtitle': 'Romance & Poetry',
      'gradient': [0xFFBE185D, 0xFFDB2777],
      'emoji': '💕'
    },
    {
      'id': 'midnight',
      'name': '🌙 After Dark',
      'subtitle': 'Night Adventures',
      'gradient': [0xFF1E1B4B, 0xFF3730A3],
      'emoji': '🌙'
    },
    {
      'id': 'underground',
      'name': '🚇 Underground',
      'subtitle': 'Hidden Gems',
      'gradient': [0xFF065F46, 0xFF047857],
      'emoji': '🚇'
    },
    {
      'id': 'vintage',
      'name': '📻 Retro Vibes',
      'subtitle': 'Old School Cool',
      'gradient': [0xFF92400E, 0xFFB45309],
      'emoji': '📻'
    },
    {
      'id': 'local',
      'name': '🏠 Local Secrets',
      'subtitle': 'Insider Tips',
      'gradient': [0xFF0F766E, 0xFF0D9488],
      'emoji': '🏠'
    },
    {
      'id': 'adventure',
      'name': '⚡ High Energy',
      'subtitle': 'Adrenaline Rush',
      'gradient': [0xFFC2410C, 0xFFEA580C],
      'emoji': '⚡'
    },
  ];

  // Modern color palette
  static const Color _backgroundPrimary = Color(0xFF121212);
  static const Color _backgroundSecondary = Color(0xFF1E1E1E);
  static const Color _backgroundCard = Color(0xFF2D2D2D);
  static const Color _accentRed = Color(0xFFFF3B30);
  static const Color _accentBlue = Color(0xFF007AFF);
  static const Color _accentGreen = Color(0xFF34C759);
  static const Color _accentPurple = Color(0xFFAF52DE);
  static const Color _accentOrange = Color(0xFFFF9500);
  static const Color _accentTeal = Color(0xFF5AC8FA);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear button
    });

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchAnimationController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 80.0;
    const returnThreshold = 40.0; // Less strict threshold for returning
    final shouldHide = _scrollController.offset > threshold;
    final shouldReturn = _scrollController.offset <= returnThreshold;

    // Search bar: visible at top, hidden when scrolling down, returns on slight scroll up
    if (shouldHide && _isSearchVisible) {
      setState(() => _isSearchVisible = false);
      _searchAnimationController?.forward();
    } else if (shouldReturn && !_isSearchVisible) {
      setState(() => _isSearchVisible = true);
      _searchAnimationController?.reverse();
    }
  }

  void _toggleFilter() {
    setState(() {
      _isFilterActive = !_isFilterActive;
      if (!_isFilterActive) {
        // Hide filters
        _scrollController.jumpTo(0); // Scroll to top
      }
    });
  }

  void _onContentTypeSelected(String type) {
    setState(() {
      _activeContentType = type;
    });
  }

  void _onThemeSelected(String themeId) {
    setState(() {
      if (_activeTheme == themeId) {
        _activeTheme = null; // Deselect if already selected
      } else {
        _activeTheme = themeId;
      }
    });
  }

  // Mock data generators
  List<Map<String, dynamic>> get _pinnedItems {
    return [
      {
        'id': 1,
        'type': 'tours',
        'theme': 'revolutionary',
        'image':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
        'title': 'Under the Clock Tower',
        'subtitle': '30 min • 5 slides • 🎧',
        'badge': '📖 Narrative',
        'rating': 4.8,
        'reviewCount': 123,
      },
      {
        'id': 2,
        'type': 'venues',
        'theme': 'cuisine',
        'image':
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
        'title': 'Jazz Basta',
        'subtitle': 'Live Music • Bar',
        'badge': '🏛️ Venue',
        'distance': 500,
      },
      {
        'id': 3,
        'type': 'landmarks',
        'theme': 'architectural',
        'image':
            'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
        'title': 'Saint Mark\'s Church',
        'subtitle': 'Free Entry • Historic',
        'badge': '🏰 Landmark',
        'distance': 750,
      },
      {
        'id': 4,
        'type': 'stories',
        'theme': 'courtyards',
        'image':
            'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=800&q=80',
        'title': 'Hidden Courtyards',
        'subtitle': '5 min read',
        'badge': '✍️ Story',
        'views': '2.3K',
      },
    ];
  }

  List<Map<String, dynamic>> get _feedItems {
    final items = [
      // Recommended items
      {
        'id': 5,
        'type': 'tours',
        'theme': 'revolutionary',
        'image':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
        'title': 'Revolutionary Belgrade Walk',
        'subtitle':
            'Discover the stories of freedom fighters and their secret meeting places',
        'badge': '📖 Narrative',
        'rating': 4.9,
        'reviewCount': 87,
        'distance': 300,
        'isLocal': false,
        'action': 'Start Story',
      },
      {
        'id': 6,
        'type': 'venues',
        'theme': 'cuisine',
        'image':
            'https://images.unsplash.com/photo-1551218808-94e220e084d2?auto=format&fit=crop&w=800&q=80',
        'title': 'Kafana Question Mark',
        'subtitle':
            'Historic tavern serving traditional Serbian cuisine since 1823',
        'badge': '🏛️ Venue',
        'rating': 4.6,
        'reviewCount': 234,
        'distance': 200,
        'isLocal': true,
        'action': 'View Venue',
      },
      {
        'id': 7,
        'type': 'landmarks',
        'theme': 'architectural',
        'image':
            'https://images.unsplash.com/photo-1587974928442-77dc3e0dba72?auto=format&fit=crop&w=800&q=80',
        'title': 'Kalemegdan Fortress',
        'subtitle':
            'Ancient fortress overlooking the confluence of two great rivers',
        'badge': '🏰 Landmark',
        'rating': 4.8,
        'reviewCount': 456,
        'distance': 400,
        'isLocal': false,
        'action': 'Explore',
      },
      {
        'id': 8,
        'type': 'stories',
        'theme': 'courtyards',
        'image':
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
        'title': 'Tales of Courtyard Cats',
        'subtitle':
            'Stories of Belgrade\'s most famous feline residents and their territories',
        'badge': '✍️ Story',
        'views': '1.2K',
        'readTime': '4 min',
        'isLocal': true,
        'action': 'Read Now',
      },
      {
        'id': 9,
        'type': 'monuments',
        'theme': 'revolutionary',
        'image':
            'https://images.unsplash.com/photo-1520637836862-4d197d17c8a4?auto=format&fit=crop&w=800&q=80',
        'title': 'Pobednik Monument',
        'subtitle':
            'Victory Monument commemorating Serbia\'s battles for independence',
        'badge': '🗿 Monument',
        'year': '1913',
        'distance': 1200,
        'isLocal': false,
        'action': 'View Monument',
      },
      {
        'id': 10,
        'type': 'tours',
        'theme': 'waterfront',
        'image':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80',
        'title': 'Riverside Promenade',
        'subtitle': 'Scenic walk along Danube and Sava river confluence',
        'badge': '📍 Trail',
        'rating': 4.5,
        'reviewCount': 67,
        'distance': 600,
        'isLocal': true,
        'action': 'Begin Trail',
      },
    ];

    return items.where((item) {
      // Filter by content type
      if (_activeContentType != 'all') {
        if (_activeContentType == 'audio' &&
            !['tours'].contains(item['type'])) {
          return false;
        } else if (_activeContentType == 'nearby' &&
            !(item['isLocal'] == true)) {
          return false;
        } else if (!_activeContentType
                .toLowerCase()
                .contains(item['type'] as String) &&
            !['audio', 'nearby'].contains(_activeContentType)) {
          return false;
        }
      }

      // Filter by themes
      if (_activeTheme != null && _activeTheme!.isNotEmpty) {
        return _activeTheme == item['theme'];
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Search Header - only show when visible
            if (_isSearchVisible)
              if (_searchAnimation != null)
                AnimatedBuilder(
                  animation: _searchAnimation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -60 * _searchAnimation!.value),
                      child: Opacity(
                        opacity: 1 - _searchAnimation!.value,
                        child: _buildSearchHeader(),
                      ),
                    );
                  },
                )
              else
                _buildSearchHeader(),
            // Animated Chip Rows - only show when visible and filter is active
            if (_isFilterActive)
              Column(
                children: [
                  _buildContentTypeChips(),
                  _buildThemeChips(),
                ],
              ),
            // Main content - expands to fill available space
            Expanded(child: _buildMainFeed()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _backgroundSecondary,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.search_rounded,
                        color: Colors.white60, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search stories, tours, venues, landmarks…',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isFilterActive ? _accentRed : _backgroundSecondary,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: _isFilterActive ? _accentRed : Colors.grey[700]!,
                    width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: (_isFilterActive ? _accentRed : Colors.black)
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.tune,
                  color: _isFilterActive ? Colors.white : Colors.white70,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _contentTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final type = _contentTypes[i];
          final isSelected = _activeContentType == type['id'];

          return GestureDetector(
            onTap: () => _onContentTypeSelected(type['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _accentRed : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? _accentRed : Colors.grey[600]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type['icon'],
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _funThemes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final theme = _funThemes[i];
          final isSelected = _activeTheme == theme['id'];
          final gradientColors = theme['gradient'] as List<int>;

          return GestureDetector(
            onTap: () => _onThemeSelected(theme['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: gradientColors.map((c) => Color(c)).toList(),
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey[600]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    theme['emoji'],
                    style: TextStyle(
                      fontSize: 16,
                      // Use a larger font size for emojis
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    theme['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainFeed() {
    final items = _feedItems;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length + 1, // +1 for load more button only
      separatorBuilder: (_, index) => const SizedBox(height: 20),
      itemBuilder: (context, i) {
        // Last item is load more button
        if (i == items.length) {
          return _buildLoadMoreButton();
        }
        // Regular feed items
        return _buildFeedCard(items[i]);
      },
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> item) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _backgroundSecondary,
                child: const Icon(Icons.image_not_supported,
                    color: Colors.grey, size: 50),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            // Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['badge'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Bookmark
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bookmark_border,
                    color: Colors.white, size: 16),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['subtitle'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaInfo(item),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: _accentRed,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _accentRed.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item['action'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item['rating'] != null) ...[
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${item['rating']} (${item['reviewCount']})',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ] else if (item['views'] != null) ...[
          Text(
            '${item['views']} views',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
        if (item['distance'] != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on, color: _accentRed, size: 14),
              const SizedBox(width: 4),
              Text(
                '${item['distance']}m away',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ElevatedButton(
          onPressed: () {
            // Load more items logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Load More',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
