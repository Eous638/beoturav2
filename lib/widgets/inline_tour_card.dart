import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/tour_provider.dart'; // Use the actual tour provider
import '../screens/tour_detail_screen.dart';
import '../l10n/localization_helper.dart';
import '../enums/language_enum.dart';
import '../providers/language_provider.dart'; // Assuming this is where languageProvider is

/// Inline card for embedding a tour summary in blog/tour content
class InlineTourCard extends ConsumerWidget {
  final String tourId;

  const InlineTourCard({super.key, required this.tourId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourByIdProvider(tourId)); // Fetch tour by ID
    final currentLanguage = ref.watch(languageProvider);
    final l10n = LocalizationHelper(ref);

    return tourAsync.when(
      data: (tour) {
        if (tour == null) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Tour with ID $tourId not found.'),
            ),
          );
        }

        final title =
            currentLanguage == Language.english ? tour.title_en : tour.title_rs;
        // Use description_en/rs from the Tour class
        final description = currentLanguage == Language.english
            ? tour.description_en
            : tour.description_rs;
        final imageUrl =
            tour.imageUrl; // imageUrl is directly on Tour via CardItem

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TourDetailScreen(tour: tour),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.tour_outlined,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description, // Use the correct description field
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_walk,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              l10n.translate('ViewTour'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
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
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading tour $tourId: $error'),
        ),
      ),
    );
  }
}
