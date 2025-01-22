// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../classes/loactions_class.dart';
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import '../providers/language_provider.dart';
import './navigation_screen.dart';
import 'package:geolocator/geolocator.dart';
// Import the full screen map screen

class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.text,
    this.locations,
    required this.tourId,
    this.isTour = false, // Add this parameter
  });
  final String title;
  final String imageUrl;
  final String text;
  final List<Location>? locations;
  final String tourId;
  final bool isTour; // Add this field

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await Geolocator.checkPermission();
    if (hasPermission == LocationPermission.denied ||
        hasPermission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _startTour() async {
    // Use the center of Belgrade for testing purposes
    const double belgradeLat = 44.8176;
    const double belgradeLon = 20.4633;

    final response = await http.post(
      Uri.parse('https://api2.gladni.rs/api/beotura/start_tour'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'tour_id': widget.tourId,
        'user_location': {
          'lat': belgradeLat,
          'lon': belgradeLon,
        },
        'max_distance_km': 2,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            sessionId: data['session_id'],
            totalPlaces: data['total_places'],
            orderedPlaces: data['ordered_places'],
            nextPlace: data['next_place'],
            totalDistanceKm: data['total_distance_km'],
            totalDurationMin: data['total_duration_min'],
            fullTourPolyline: data['full_tour_polyline'],
            tourId: widget.tourId,
          ),
        ),
      );
    } else {
      throw Exception('Failed to start tour');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationHelper(ref);
    final currentLanguage = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.locations != null &&
                  widget.isTour) // Check if it's a tour
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      l10n.translate('locations'),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.locations!.length,
                        itemBuilder: (context, index) {
                          final location = widget.locations![index];
                          return Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 63, 63, 63),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      title: currentLanguage == Language.english
                                          ? location.title_en
                                          : location.title,
                                      imageUrl: location.imageUrl,
                                      text: currentLanguage == Language.english
                                          ? location.description_en
                                          : location.description,
                                      tourId: widget.tourId,
                                      isTour: false, // It's a location
                                    ),
                                  ),
                                );
                              },
                              leading: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      location.imageUrl,
                                      fit: BoxFit.cover,
                                      cacheWidth: 300,
                                      cacheHeight: 300,
                                    ),
                                  )),
                              title: Text(currentLanguage == Language.english
                                  ? location.title_en
                                  : location.title),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isTour) // Show start tour button only for tours
                ElevatedButton(
                  onPressed: _startTour,
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      l10n.translate('begin tour'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              // if (!widget.isTour) // Show navigate button only for locations
              //   ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => FullScreenMapScreen(
              //             sessionId: widget.tourId, // Use tourId as sessionId
              //             isNavigation: false, // Indicate it's not navigation
              //             tourId: widget.tourId, // Pass the tourId as place ID
              //           ),
              //         ),
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       elevation: 3,
              //       backgroundColor: Colors.blue,
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.all(12.0),
              //       child: Text(
              //         l10n.translate('navigate to location'),
              //         style: const TextStyle(color: Colors.white, fontSize: 16),
              //       ),
              //     ),
              //   ),
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
