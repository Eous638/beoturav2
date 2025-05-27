import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/location_provider.dart';
import '../screens/details_screen.dart';

/// Inline card for embedding a location summary in blog/tour content
class InlineLocationCard extends ConsumerWidget {
  final String locationId;
  const InlineLocationCard({super.key, required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the locationByIdProvider from location_provider.dart
    final locationAsync = ref.watch(locationByIdProvider(locationId));
    return locationAsync.when(
      data: (location) {
        if (location == null) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Location with ID $locationId not found.'),
            ),
          );
        }
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
                  builder: (context) => DetailsScreen(
                    title: location.title_en ?? location.title,
                    imageUrl: location.imageUrl ?? '',
                    text: location.description_en ?? location.description,
                    tourId: location.categoryId ?? '',
                    isTour: false,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                if (location.imageUrl != null && location.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      location.imageUrl!,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
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
                          location.title_en ?? location.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          location.description_en ?? location.description,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(Icons.place,
                                size: 14, color: Colors.redAccent),
                            SizedBox(width: 4),
                            Text('View details',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.redAccent)),
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
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading location $locationId: $error'),
        ),
      ),
    );
  }
}
