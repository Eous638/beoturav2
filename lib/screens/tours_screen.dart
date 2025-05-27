import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tour_provider.dart';
import '../providers/language_provider.dart';
import '../classes/tours_class.dart';
import '../l10n/localization_helper.dart';
import '../enums/language_enum.dart';
import 'tour_detail_screen.dart'; // We'll create this screen for the immersive experience

class ToursScreen extends ConsumerWidget {
  const ToursScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Tour>> tours = ref.watch(tourProviderProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l10n = LocalizationHelper(ref);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Future<void> refreshTours() async {
      await ref.refresh(tourProviderProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('Tours'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: refreshTours,
        child: tours.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (toursData) => toursData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('No Tours Found'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('Check back later for new experiences'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Tour - First tour gets special treatment
                      if (toursData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            l10n.translate('Featured'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (toursData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildFeaturedTourCard(
                            context: context,
                            tour: toursData.first,
                            currentLanguage: currentLanguage,
                            isDarkMode: isDarkMode,
                          ),
                        ),

                      // All Tours section
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
                        child: Text(
                          l10n.translate('All Tours'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Tour cards grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio:
                                0.75, // Portrait orientation for cards
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: toursData.length,
                          itemBuilder: (context, index) {
                            final tour = toursData[index];
                            // Skip the first tour if it's already featured
                            if (index == 0 && toursData.length > 1) {
                              return _buildTourCard(
                                context: context,
                                tour: toursData[1],
                                currentLanguage: currentLanguage,
                                isDarkMode: isDarkMode,
                              );
                            } else if (index == 1 && toursData.length > 1) {
                              // Skip rendering again
                              return _buildTourCard(
                                context: context,
                                tour: toursData[index + 1 < toursData.length
                                    ? index + 1
                                    : index],
                                currentLanguage: currentLanguage,
                                isDarkMode: isDarkMode,
                              );
                            }
                            return _buildTourCard(
                              context: context,
                              tour: tour,
                              currentLanguage: currentLanguage,
                              isDarkMode: isDarkMode,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // Featured tour card - larger, with more details
  Widget _buildFeaturedTourCard({
    required BuildContext context,
    required Tour tour,
    required Language currentLanguage,
    required bool isDarkMode,
  }) {
    final title =
        currentLanguage == Language.english ? tour.title_en : tour.title_rs;
    final description = currentLanguage == Language.english
        ? tour.description_en
        : tour.description_rs;

    return GestureDetector(
      onTap: () {
        _openTourDetail(context, tour);
      },
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Tour image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                tour.imageUrl ?? 'https://via.placeholder.com/300', // Default placeholder URL
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.75, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tour.locations.length} locations',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tour title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tour description
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Start button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Start Tour',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Regular tour card for the grid
  Widget _buildTourCard({
    required BuildContext context,
    required Tour tour,
    required Language currentLanguage,
    required bool isDarkMode,
  }) {
    final title =
        currentLanguage == Language.english ? tour.title_en : tour.title_rs;

    return GestureDetector(
      onTap: () {
        _openTourDetail(context, tour);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Tour image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                tour.imageUrl ?? 'https://via.placeholder.com/150',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tour.locations.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Tour title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opens the immersive tour detail screen
  void _openTourDetail(BuildContext context, Tour tour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailScreen(tour: tour),
      ),
    );
  }
}
