// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import for date formatting
import '../classes/loactions_class.dart';
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import '../providers/language_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/document_renderer.dart'; // Import the full screen map screen

class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.text,
    this.locations,
    required this.tourId,
    this.isTour = false,
    this.createdAt, // Add date parameter
    this.child, // Add a builder for embedded mode
  });
  final String title;
  final String imageUrl;
  final String text;
  final List<Location>? locations;
  final String tourId;
  final bool isTour;
  final DateTime? createdAt; // Optional date field
  final Widget Function(BuildContext, Widget)?
      child; // Optional builder for embedding

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
    } else {
      throw Exception('Failed to start tour');
    }
  }

  // Format date nicely
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationHelper(ref);
    final currentLanguage = ref.watch(languageProvider);

    // Create the main content widget
    Widget content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.imageUrl,
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

          // Title with standardized font size
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 26, // Standardized size
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible, // Ensures text wraps properly
            ),
          ),

          // Date below title - centered as well
          if (widget.createdAt != null)
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
                    formatDate(widget.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          if (widget.locations != null && widget.isTour)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                title: Text(
                  l10n.translate('locations'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.locations!.length,
                    itemBuilder: (context, index) {
                      final location = widget.locations![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  title: currentLanguage == Language.english
                                      ? (location.title_en ?? 'Untitled')
                                      : (location.title_sr ?? 'Untitled'),
                                  imageUrl: location.imageUrl ?? '',
                                  text: currentLanguage == Language.english
                                      ? (location.description_en ?? '')
                                      : (location.description_sr ?? ''),
                                  tourId: widget.tourId,
                                  isTour: false,
                                ),
                              ),
                            );
                          },
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                location.imageUrl?.isNotEmpty == true
                                    ? location.imageUrl!
                                    : 'https://via.placeholder.com/300', // Provide a default URL
                                fit: BoxFit.cover,
                                cacheWidth: 300,
                                cacheHeight: 300,
                              ),
                            ),
                          ),
                          title: Text(
                            currentLanguage == Language.english
                                ? (location.title_en ?? 'Untitled')
                                : (location.title ?? 'Untitled'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          if (widget.isTour)
            Center(
              child: ElevatedButton(
                onPressed: _startTour,
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: Colors.grey[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    l10n.translate('begin tour'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Description text with consistent styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Builder(
              builder: (context) {
                // Handle the text content safely
                if (widget.text.isEmpty) {
                  return const Text(
                    "No content available.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.justify,
                  );
                }

                // Try to parse text as JSON for DocumentRenderer
                try {
                  final jsonContent = jsonDecode(widget.text);
                  return DocumentRenderer(
                    content: jsonContent,
                    defaultTextStyle: const TextStyle(
                      fontSize: 16,
                      height:
                          1.8, // Increased line height for better readability
                      letterSpacing: 0.2,
                    ),
                  );
                } catch (e) {
                  // If text is not valid JSON, display as regular text
                  return Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.justify,
                  );
                }
              },
            ),
          ),

          // Bottom margin
          const SizedBox(height: 80),
        ],
      ),
    );

    // If we're embedding within another screen (like PageView)
    if (widget.child != null) {
      return widget.child!(context, content);
    }

    // Regular standalone screen
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          softWrap: true,
          overflow:
              TextOverflow.visible, // Allow text to wrap instead of ellipsis
          textAlign: TextAlign.center, // Center the title text
        ),
        centerTitle: true,
        toolbarHeight: kToolbarHeight *
            1.2, // Slightly increase AppBar height to accommodate wrapping
      ),
      body: content,
    );
  }
}
