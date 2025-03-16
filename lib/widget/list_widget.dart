import 'package:beotura/enums/language_enum.dart';
import 'package:flutter/material.dart';
import '../classes/card_item.dart';
import '../classes/loactions_class.dart';
import '../screens/details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/single_route_provider.dart';
import '../providers/language_provider.dart';

class ListCard extends ConsumerWidget {
  const ListCard({
    super.key,
    required this.item,
    this.locations,
    this.latitude,
    this.longitude,
    this.isTour = false, // Add this parameter
  });
  final double? latitude;
  final double? longitude;
  final CardItem item;
  final List<Location>? locations;
  final bool isTour; // Add this field

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleRoute = ref.watch(singleRouteProvider);
    final currentLanguage = ref.read(languageProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          if (latitude != null && longitude != null) {
            singleRoute.destinationLatitude = latitude!;
            singleRoute.destinationLongitude = longitude!;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                title: currentLanguage == Language.english
                    ? (item.title_en ?? 'Default Title')
                    : (item.title ?? 'Default Title'),
                imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
                text: currentLanguage == Language.english
                    ? (item.description_en ?? 'Default Description')
                    : (item.description ?? 'Default Description'),
                locations: locations,
                tourId: item.id,
                isTour: isTour, // Pass the isTour parameter
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          color: Colors.black,
          elevation: 5,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(
                    item.imageUrl ?? 'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                currentLanguage == Language.english
                    ? (item.title_en ?? 'Default Title')
                    : (item.title ?? 'Default Title'),
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
