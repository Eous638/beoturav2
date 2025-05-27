import 'package:beotura/screens/locations_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import '../providers/language_provider.dart';
import '../classes/loactions_class.dart';
import '../classes/tours_class.dart';
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import '../screens/details_screen.dart'; // Import details screen for navigation

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  String? selectedCategoryId;
  bool _showCategoriesAsGrid = false;
  String? _selectedCategoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationHelper(ref);
    // Get current language to determine which title to show
    final currentLanguage = ref.watch(languageProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get categories (tours) data
    final categoriesAsync = ref.watch(categoriesProvider);

    // Get filtered locations based on selected category
    final locationsAsync = selectedCategoryId == null
        ? ref.watch(allLocationsProvider)
        : ref.watch(locationsByTourProvider(selectedCategoryId!));

    Future<void> refreshData() async {
      await ref.refresh(categoriesProvider.future);
      await ref.refresh(allLocationsProvider.future);
      if (selectedCategoryId != null) {
        await ref.refresh(locationsByTourProvider(selectedCategoryId!).future);
      }
    }

    // Function to clear selected category
    void clearSelectedCategory() {
      setState(() {
        selectedCategoryId = null;
        _selectedCategoryName = null;
      });
    }

    return WillPopScope(
      // Handle back button press to prevent accidentally exiting the app
      onWillPop: () async {
        // If a category is selected, clear the selection and prevent popping
        if (selectedCategoryId != null) {
          clearSelectedCategory();
          return false; // Prevent navigating back
        }
        // Otherwise let the system handle the back press normally
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              selectedCategoryId == null
                  ? l10n.translate('Locations')
                  : _selectedCategoryName ?? l10n.translate('Locations'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Show back button in app bar when category is selected
            leading: selectedCategoryId != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: clearSelectedCategory,
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LocationsMapScreen();
                  }));
                },
              ),
            ]),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories (Tours) section
                categoriesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '${l10n.translate('error_loading_categories')}: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(l10n.translate('no_categories_found')),
                        ),
                      );
                    }

                    // If a category is selected, show a back button at the top
                    if (selectedCategoryId != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.arrow_back),
                              label: Text(l10n.translate('All Categories')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: clearSelectedCategory,
                            ),
                          ),

                          // Show locations for selected category
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildLocationsList(locationsAsync, l10n,
                                currentLanguage, isDarkMode),
                          ),
                        ],
                      );
                    }

                    // Category section header
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.translate('Categories'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Show categories as horizontal list
                        Container(
                          height: 180, // Increased height for more prominence
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return _buildCategoryCard(
                                category: category,
                                currentLanguage: currentLanguage,
                              );
                            },
                          ),
                        ),
                        // View all categories button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _showCategoriesAsGrid = true;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white30
                                      : Colors.black12,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.translate('View All Categories'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Show grid view of all categories if enabled
                        if (_showCategoriesAsGrid)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.translate('All Categories'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.close, size: 18),
                                      label: Text(l10n.translate('Close')),
                                      onPressed: () {
                                        setState(() {
                                          _showCategoriesAsGrid = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    return _buildCategoryCard(
                                      category: categories[index],
                                      currentLanguage: currentLanguage,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        // Location section header
                        if (!_showCategoriesAsGrid)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 16.0,
                                bottom: 8.0),
                            child: Text(
                              l10n.translate('Popular Places'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Show locations list if not showing grid
                        if (!_showCategoriesAsGrid)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _buildLocationsList(locationsAsync, l10n,
                                currentLanguage, isDarkMode),
                          ),
                        // Add space at the bottom
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required Tour category,
    required Language currentLanguage,
  }) {
    final title = currentLanguage == Language.english
        ? category.title_en
        : category.title_rs;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryId = category.id;
          _selectedCategoryName = title; // Store the selected category name
        });
      },
      child: Container(
        width: 250, // Wider cards
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // More rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Stronger shadow
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                category.imageUrl ?? 'https://via.placeholder.com/400x225',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            // Gradient overlay - make it darker for better text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.7, 1.0],
                ),
              ),
            ),
            // Category title
            Positioned(
              bottom: 16, // More padding at the bottom
              left: 16,
              right: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Larger font
                  height: 1.2, // Tighter line height for titles
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Add a subtle hint that this is tappable
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList(AsyncValue<List<Location>> locationsAsync,
      LocalizationHelper l10n, Language currentLanguage, bool isDarkMode) {
    return locationsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '${l10n.translate('error_loading_locations')}: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (locationsData) {
        // Sort locations by order property
        final sortedLocations = List.of(locationsData)
          ..sort((a, b) => a.order.compareTo(b.order));

        if (sortedLocations.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Text(
                l10n.translate('no_locations_found'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedLocations.length,
          itemBuilder: (context, index) {
            final location = sortedLocations[index];
            return _buildLocationCard(
                location, currentLanguage, isDarkMode, l10n);
          },
        );
      },
    );
  }

  Widget _buildLocationCard(Location location, Language currentLanguage,
      bool isDarkMode, LocalizationHelper l10n) {
    final title = currentLanguage == Language.english
        ? (location.title_en ?? location.title)
        : location.title;

    final description = currentLanguage == Language.english
        ? (location.description_en ?? location.description)
        : location.description;

    // Use theme-aware colors
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final descriptionColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Container(
      margin: const EdgeInsets.only(bottom: 20), // More spacing between cards
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _navigateToLocationDetails(location, currentLanguage);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured image - full width and larger
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9, // 16:9 aspect ratio for images
                  child: Image.network(
                    location.imageUrl ?? 'https://via.placeholder.com/400x225',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[isDarkMode ? 700 : 200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              // Location details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: descriptionColor,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            l10n.translate('View Details'),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            _navigateToLocationDetails(
                                location, currentLanguage);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Safe navigation to details screen with proper null handling
  void _navigateToLocationDetails(Location location, Language currentLanguage) {
    try {
      final title = currentLanguage == Language.english
          ? (location.title_en ?? location.title)
          : location.title;

      final description = currentLanguage == Language.english
          ? (location.description_en ?? location.description)
          : location.description;

      final categoryId = location.categoryId ?? '';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            title: title,
            imageUrl: location.imageUrl ?? '',
            text: description,
            tourId: categoryId,
            isTour: false,
          ),
        ),
      );
    } catch (e) {
      // Show error if navigation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening location details: $e')),
      );
    }
  }
}
