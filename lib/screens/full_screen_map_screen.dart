import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../providers/position_provider.dart';
import '../services/foreground_task_service.dart';

enum NavigationStatus {
  initializing,
  active,
  paused,
  completed,
  error,
}

class NavigationState {
  final LatLng? destination;
  final List<LatLng> routePolyline;
  final List<LatLng> fullTripPolyline;
  final double distanceKm;
  final double durationMin;
  final Map<String, dynamic> stats;
  final int remainingStops;
  final NavigationStatus status;
  final String currentStopName;
  final String currentStopDescription;
  final String currentStopTitle;
  final String image;

  NavigationState({
    this.destination,
    this.routePolyline = const [],
    this.image = '',
    this.fullTripPolyline = const [],
    this.distanceKm = 0,
    this.durationMin = 0,
    this.stats = const {},
    this.remainingStops = 0,
    this.status = NavigationStatus.initializing,
    this.currentStopName = '',
    this.currentStopDescription = '',
    this.currentStopTitle = '',
  });
}

class FullScreenMapScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final bool isNavigation; // Add this parameter
  final String tourId; // Add this parameter

  const FullScreenMapScreen({
    super.key,
    required this.sessionId,
    required this.tourId,
    this.isNavigation = true, // Default to true for navigation
  });

  @override
  FullScreenMapScreenState createState() => FullScreenMapScreenState();
}

class FullScreenMapScreenState extends ConsumerState<FullScreenMapScreen> {
  late WebSocketChannel channel;
  late Timer locationUpdateTimer;
  late Timer proximityCheckTimer;
  NavigationState navigationState = NavigationState();
  final mapController = MapController();
  bool isModalOpen = false;
  late ScaffoldMessengerState scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    initializeNavigation();
    setupFakeLocationUpdates(); // Use fake location updates for testing
    setupProximityCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void initializeNavigation() {
    try {
      final uri = widget.isNavigation
          ? 'wss://api2.gladni.rs/api/beotura/navigation'
          : 'wss://api2.gladni.rs/api/beotura/navigate_to_place'; // Different WebSocket URL
      channel = WebSocketChannel.connect(Uri.parse(uri));
      debugPrint('WebSocket connected');

      // Send session ID or place ID
      widget.isNavigation
          ? channel.sink.add(widget.sessionId)
          : channel.sink.add(widget.tourId);

      // Start navigation or location viewing
      sendLocation(command: 'start');

      channel.stream.listen(
        (message) => handleWebSocketMessage(message),
        onError: (error) => handleError(error),
      );
    } catch (e) {
      debugPrint('Error initializing navigation: $e');
    }
  }

  void setupFakeLocationUpdates() {
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (navigationState.status == NavigationStatus.active) {
        // Fake location data in Belgrade
        const fakeLocation = LatLng(44.8176, 20.4633); // Belgrade coordinates
        channel.sink.add(jsonEncode({
          'command': 'location_update',
          'data': {
            'location': {
              'lat': fakeLocation.latitude,
              'lon': fakeLocation.longitude,
            }
          }
        }));
        debugPrint('Fake location sent: $fakeLocation');
      }
    });
  }

  void setupProximityCheck() {
    proximityCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkProximityToDestination();
    });
  }

  void checkProximityToDestination() {
    final position = ref.read(positionProvider);
    if (position != null &&
        navigationState.destination != null &&
        !isModalOpen) {
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        navigationState.destination!.latitude,
        navigationState.destination!.longitude,
      );

      if (distance <= 50) {
        // 50 meters
        showLocationModal(autoOpen: true);
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 2 * R; R = 6371 km, converted to meters
  }

  void showLocationModal({bool autoOpen = false}) {
    if (isModalOpen) return; // Prevent reopening the modal

    setState(() => isModalOpen = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Image(image: NetworkImage(navigationState.image)),
                Text(
                  navigationState.currentStopName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.directions_walk,
                  'Distance',
                  '${navigationState.distanceKm.toStringAsFixed(1)} km',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'Estimated time',
                  '${navigationState.durationMin.toStringAsFixed(0)} min',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final position = ref.read(positionProvider);
                      if (position != null) {
                        channel.sink.add(jsonEncode({
                          'command': 'next_stop',
                          'data': {
                            'location': {
                              'lat': position.latitude,
                              'lon': position.longitude,
                            }
                          }
                        }));
                      }
                    },
                    child: const Text('Arrived!'),
                  ),
                ),
                Text(
                  navigationState.currentStopDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => setState(() => isModalOpen = false));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void sendLocation({required String command}) {
    try {
      final position = ref.read(positionProvider);
      if (position != null) {
        channel.sink.add(jsonEncode({
          'command': command,
          'data': {
            'location': {
              'lat': position.latitude,
              'lon': position.longitude,
            }
          }
        }));
        debugPrint('Location sent: $command');
      }
    } catch (e) {
      debugPrint('Error sending location: $e');
    }
  }

  void handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      debugPrint('WebSocket message received: $data');

      switch (data['type']) {
        case 'navigation_update':
          handleNavigationUpdate(data);
          break;
        case 'arrival':
          handleArrival(data);
          break;
        case 'tour_completed':
          handleTourCompleted(data);
          break;
        case 'navigation_paused':
          setState(() => navigationState =
              NavigationState(status: NavigationStatus.paused));
          break;
        case 'navigation_resumed':
          setState(() => navigationState =
              NavigationState(status: NavigationStatus.active));
          break;
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  void handleNavigationUpdate(Map<String, dynamic> data) {
    try {
      final destinationData = data['destination'];
      final polylinePoints = decodePolyline(data['polyline']);
      final fullTripPoints = decodePolyline(data['full_trip_polyline']);

      setState(() {
        navigationState = NavigationState(
          destination: LatLng(
            destinationData['latitude'].toDouble(),
            destinationData['longitude'].toDouble(),
          ),
          routePolyline: polylinePoints,
          fullTripPolyline: fullTripPoints,
          distanceKm: data['distance_km'].toDouble(),
          durationMin: data['duration_min'].toDouble(),
          stats: data['stats'],
          remainingStops: data['remaining_stops'],
          status: NavigationStatus.active,
          image: destinationData['image'] ?? '',
          currentStopName: destinationData['name'] ?? '',
          currentStopDescription: destinationData['description'] ?? '',
        );
      });

      // Center map on current route if needed
      if (polylinePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(polylinePoints);
        mapController.fitCamera(CameraFit.bounds(bounds: bounds));
      }
    } catch (e) {
      debugPrint('Error handling navigation update: $e');
    }
  }

  void handleArrival(Map<String, dynamic> data) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Destination Reached!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have arrived at: ${data['place']['name']}'),
              const SizedBox(height: 8),
              Text(
                  'Progress: ${data['stats']['completion_percentage'].toStringAsFixed(1)}%'),
              Text('Places visited: ${data['stats']['visited_places']}'),
              Text('Remaining places: ${data['stats']['remaining_places']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      debugPrint('Arrival handled');
    } catch (e) {
      debugPrint('Error handling arrival: $e');
    }
  }

  void handleTourCompleted(Map<String, dynamic> data) {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Tour Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Total distance: ${data['final_stats']['total_distance_km'].toStringAsFixed(2)} km'),
              Text(
                  'Active duration: ${data['final_stats']['active_duration_min'].toStringAsFixed(0)} minutes'),
              Text('Places visited: ${data['final_stats']['visited_places']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Finish'),
            ),
          ],
        ),
      ).then((_) => Navigator.pop(context));
      debugPrint('Tour completed handled');
    } catch (e) {
      debugPrint('Error handling tour completion: $e');
    }
  }

  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void handleError(dynamic error) {
    try {
      setState(() =>
          navigationState = NavigationState(status: NavigationStatus.error));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Navigation Error'),
          content: Text('An error occurred: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
      debugPrint('Error handled: $error');
    } catch (e) {
      debugPrint('Error handling error: $e');
    }
  }

  @override
  void dispose() {
    try {
      // First, cancel all timers immediately
      locationUpdateTimer.cancel();
      proximityCheckTimer.cancel();

      // Then handle WebSocket closure
      // Send stop command without waiting
      try {
        channel.sink.add(jsonEncode({'command': 'stop'}));
      } catch (e) {
        debugPrint('Error sending stop command: $e');
      }

      // Close the WebSocket with a valid close code
      try {
        channel.sink.close(1000); // Normal closure
      } catch (e) {
        debugPrint('Error closing WebSocket: $e');
      }

      ForegroundTaskService.stopForegroundTask(); // Stop foreground task

      debugPrint('Resources disposed');
    } catch (e) {
      debugPrint('Error in dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(positionProvider);
    final tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );

    if (currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNavigation
            ? 'Navigation'
            : 'Location View'), // Change title based on mode
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: tileProvider,
              ),
              PolylineLayer(
                polylines: [
                  if (navigationState.routePolyline.isNotEmpty)
                    Polyline(
                      points: navigationState.routePolyline,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  if (navigationState.fullTripPolyline.isNotEmpty)
                    Polyline(
                      points: navigationState.fullTripPolyline,
                      color: Colors.grey,
                      strokeWidth: 2.0,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    child: const Icon(Icons.navigation, color: Colors.blue),
                  ),
                  if (navigationState.destination != null)
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: navigationState.destination!,
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ),
                ],
              ),
            ],
          ),
          if (navigationState.status == NavigationStatus.active)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => showLocationModal(),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(navigationState.image),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                navigationState.currentStopName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.clip,
                                maxLines:
                                    2, // Allow wrapping into multiple lines
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Distance: ${navigationState.distanceKm.toStringAsFixed(1)} km',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'ETA: ${navigationState.durationMin.toStringAsFixed(0)} minutes',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
