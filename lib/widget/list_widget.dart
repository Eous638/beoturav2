import 'package:flutter/material.dart';
import '../classes/tours_class.dart';
import '../classes/loactions_class.dart';
import '../screens/details_screen.dart';
import '../screens/tour_details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListCard extends ConsumerWidget {
  final dynamic item;
  final bool isTour;

  const ListCard({
    super.key,
    required this.item,
    required this.isTour,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (isTour) {
            // Navigate to TourDetailsScreen with the tour
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TourDetailsScreen(tour: item),
              ),
            );
          } else {
            // Navigate to DetailsScreen with the location
            final location = item as Location;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  title: location.title_en ?? location.title_sr ?? '',
                  imageUrl: location.imageUrl ?? '',
                  text: location.description_en ?? location.description ?? '',
                  tourId: location.id ?? '',
                  isTour: false,
                ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                isTour
                    ? (item as Tour).imageUrl ?? ''
                    : (item as Location).imageUrl ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    isTour
                        ? (item as Tour).title_en
                        : (item as Location).title_en ??
                            (item as Location).title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    isTour
                        ? (item as Tour).description_en
                        : (item as Location).description_en ??
                            (item as Location).description ??
                            '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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
