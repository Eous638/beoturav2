import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import '../providers/location_provider.dart';
import '../classes/loactions_class.dart';
import 'details_screen.dart';

class LocationsMapScreen extends ConsumerStatefulWidget {
  const LocationsMapScreen({super.key});

  @override
  ConsumerState<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends ConsumerState<LocationsMapScreen> {
  double currentZoom = 13.0;
  final MapController mapController = MapController();

  // Lower the zoom threshold to minimize visual clutter
  final double minZoomForCards = 15.5;

  // Track visible locations to control card display
  List<Location> visibleLocations = [];
  LatLng? focusedLocation;

  // Maximum number of markers to show cards for
  final int maxVisibleCards = 5;

  @override
  Widget build(BuildContext context) {
    final locationsAsyncValue = ref.watch(locationProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations Map'),
        actions: [
          if (focusedLocation != null)
            IconButton(
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () {
                setState(() {
                  focusedLocation = null;
                });
                mapController.move(LatLng(44.8176, 20.4633), 13.0);
              },
            ),
        ],
      ),
      body: locationsAsyncValue.when(
        data: (locations) {
          debugPrint('Locations loaded: ${locations.length}');
          return _buildMap(context, locations);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMap(BuildContext context, List<Location> locations) {
    if (locations.isEmpty) {
      return const Center(child: Text('No locations available'));
    }

    final markers = locations.map((location) {
      return Marker(
        width: currentZoom > minZoomForCards ? 280.0 : 40.0,
        height: currentZoom > minZoomForCards ? 100.0 : 40.0,
        point: LatLng(location.latitude, location.longitude),
        child: GestureDetector(
          onTap: () {
            if (currentZoom <= minZoomForCards) {
              // If zoomed out, focus on this location by zooming in
              setState(() {
                focusedLocation = LatLng(location.latitude, location.longitude);
              });
              mapController.move(LatLng(location.latitude, location.longitude),
                  minZoomForCards + 0.5);
            } else {
              // If already zoomed in, show details
              _showLocationDetails(context, location);
            }
          },
          child: currentZoom > minZoomForCards
              ? _buildLocationCard(location)
              : const Icon(Icons.location_on_outlined,
                  color: Colors.white70, size: 40.0),
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: focusedLocation ?? LatLng(44.8176, 20.4633),
        initialZoom: focusedLocation != null ? (minZoomForCards + 0.5) : 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        onMapEvent: (MapEvent event) {
          if (event is MapEventMove &&
              event.source != MapEventSource.nonRotatedSizeChange) {
            setState(() {
              currentZoom = event.camera.zoom;
              // Reset focus if user manually zooms out
              if (currentZoom < minZoomForCards && focusedLocation != null) {
                focusedLocation = null;
              }
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          tileProvider: FMTCTileProvider(
            stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
          ),
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 80,
            disableClusteringAtZoom: minZoomForCards.round(),
            polygonOptions: const PolygonOptions(
              borderColor: Colors.black12,
              color: Colors.black12,
              borderStrokeWidth: 3,
            ),
            size: const Size(40, 40),
            markers: markers,
            builder: (context, markers) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                    border: const Border.fromBorderSide(
                      BorderSide(
                        color: Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                  ),
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Location location) {
    return Card(
      color: Colors.black.withOpacity(0.85),
      clipBehavior: Clip.antiAlias, // Ensures image stays inside card radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      elevation: 4,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image section - fixed width
            SizedBox(
              width: 80,
              height: 100,
              child: location.imageUrl != null && location.imageUrl!.isNotEmpty
                  ? Image.network(
                      location.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white54),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child:
                          const Icon(Icons.location_on, color: Colors.white54),
                    ),
            ),

            // Content section - flexible width
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      location.title_en ?? location.title ?? 'Untitled',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              title: location.title_en ??
                                  location.title ??
                                  'Untitled',
                              imageUrl: location.imageUrl ?? '',
                              text: location.description_en ??
                                  location.description ??
                                  '',
                              tourId: '', // Not a tour
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(fontSize: 12),
                      ),
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

  void _showLocationDetails(BuildContext context, Location location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle bar indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Location image
                  if (location.imageUrl != null &&
                      location.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        location.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50)),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    location.title_en ?? location.title ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    location.description_en ?? location.description ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  // Full details button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            title: location.title_en ??
                                location.title ??
                                'Untitled',
                            imageUrl: location.imageUrl ?? '',
                            text: location.description_en ??
                                location.description ??
                                '',
                            tourId: '', // Not a tour
                          ),
                        ),
                      );
                    },
                    child: const Text('View Full Details'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
