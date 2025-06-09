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

  String? _selectedCardType; // Track which card is selected

  AnimationController? _cardAnimationController;
  Animation<double>? _cardHeightAnimation;
  Animation<double>? _cardWidthAnimation;
  Animation<double>? _cardOpacityAnimation;

  // Content type cards with colors and details
  static const List<Map<String, dynamic>> _contentCards = [
    {
      'id': 'tours',
      'name': 'Tours',
      'icon': Icons.route,
      'color': Color(0xFF10B981),
      'lightColor': Color(0xFF34D399),
      'description': 'Guided experiences'
    },
    {
      'id': 'landmarks',
      'name': 'Landmarks',
      'icon': Icons.account_balance,
      'color': Color(0xFF8B5CF6),
      'lightColor': Color(0xFFA78BFA),
      'description': 'Historic sites'
    },
    {
      'id': 'venues',
      'name': 'Venues',
      'icon': Icons.restaurant,
      'color': Color(0xFFF59E0B),
      'lightColor': Color(0xFFFBBF24),
      'description': 'Places to visit'
    },
    {
      'id': 'events',
      'name': 'Events',
      'icon': Icons.event,
      'color': Color(0xFFEC4899),
      'lightColor': Color(0xFFF472B6),
      'description': 'Live happenings'
    },
  ];

  @override
  void initState() {
    super.initState();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Quick and smooth animation
      vsync: this,
    );
    _cardHeightAnimation = Tween<double>(begin: 100.0, end: 250.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController!, curve: Curves.easeInOut),
    );
    _cardOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _cardAnimationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize animations using MediaQuery.of(context) safely
    _cardWidthAnimation = Tween<double>(
      begin: 160.0,
      end: MediaQuery.of(context).size.width,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _cardAnimationController?.dispose();
    super.dispose();
  }

  void _onCardSelected(String cardType) {
    setState(() {
      if (_selectedCardType == cardType) {
        _selectedCardType = null;
        _cardAnimationController?.reverse();
      } else {
        _selectedCardType = cardType;
        _cardAnimationController?.forward();
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
        'type': 'events',
        'theme': 'music',
        'image':
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80',
        'title': 'Jazz Festival Tonight',
        'subtitle': 'Live performances in the heart of Belgrade',
        'badge': '🎵 Event',
        'rating': 4.7,
        'reviewCount': 89,
        'distance': 150,
        'isLocal': true,
        'action': 'Get Tickets',
      },
    ];

    return items.where((item) {
      // Filter by selected card type
      if (_selectedCardType != null) {
        return item['type'] == _selectedCardType;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Show search bar only when no card is selected
            if (_selectedCardType == null) _buildSearchHeader(),
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
        color: Colors.black,
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
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
        ],
      ),
    );
  }

  Widget _buildMainFeed() {
    final feedItems = _feedItems;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: feedItems.length + 1, // +1 for cards section
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        // Ensure cards start at the beginning of the feed
        if (i == 0) {
          return _buildContentCardsSection();
        }

        // Regular feed items (offset by 1 because of cards section)
        return _buildFeedCard(feedItems[i - 1]);
      },
    );
  }

  Widget _buildContentCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded card header
        if (_selectedCardType != null)
          AnimatedBuilder(
            animation: _cardAnimationController!,
            builder: (context, child) {
              return _buildExpandedCard();
            },
          ),

        // Cards grid
        AnimatedBuilder(
          animation: _cardAnimationController!,
          builder: (context, child) {
            return Opacity(
              opacity: _selectedCardType != null
                  ? _cardOpacityAnimation!.value
                  : 1.0,
              child: _buildContentCardsGrid(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandedCard() {
    if (_selectedCardType == null) return const SizedBox.shrink();

    final selectedCard = _contentCards.firstWhere(
      (card) => card['id'] == _selectedCardType,
    );

    return Container(
      height: 50, // Much shorter header
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              selectedCard['color'] as Color,
              selectedCard['lightColor'] as Color,
            ],
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (selectedCard['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _onCardSelected(_selectedCardType!),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selectedCard['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCard['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCardsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemCount: _contentCards.length,
        itemBuilder: (context, index) {
          final card = _contentCards[index];
          return _buildContentCard(card);
        },
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: () => _onCardSelected(card['id']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card['color'] as Color,
              card['lightColor'] as Color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (card['color'] as Color).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                card['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
              const Spacer(),
              Text(
                card['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card['description'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> item) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
                color: Colors.grey[900],
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
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
