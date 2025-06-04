import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Map marker data model
class MapMarker {
  final double lat;
  final double lng;
  final String label;
  final String? description;

  MapMarker({
    required this.lat,
    required this.lng,
    required this.label,
    this.description,
  });
}

/// Component for displaying interactive maps with historical markers
class MapComponent extends StatefulWidget {
  final List<MapMarker> markers;
  final double? initialLat;
  final double? initialLng;
  final double initialZoom;
  final bool showRouteFromUser; // Added this field

  const MapComponent({
    super.key,
    required this.markers,
    this.initialLat,
    this.initialLng,
    this.initialZoom = 15.0,
    this.showRouteFromUser = true, // Initialize
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _mapMarkers = {};
  MapMarker? _selectedMarker;
  final Set<Polyline> _polylines = {};
  Position? _currentPosition;
  PolylinePoints polylinePoints = PolylinePoints();

  final String _googleApiKey =
      "AIzaSyATytR6x9HoAOszosuJjl_48pCzRLR0_NY"; // IMPORTANT: Replace with your key

  // Standard Google Maps dark style JSON
  static const String _darkMapStyle = '''

  [
    { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] },
    { "elementType": "labels.text.stroke", "stylers": [ { "color": "#242f3e" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#746855" } ] },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#d59563" } ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#d59563" } ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [ { "color": "#263c3f" } ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#6b9a76" } ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [ { "color": "#38414e" } ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [ { "color": "#212a37" } ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#9ca5b3" } ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [ { "color": "#746855" } ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [ { "color": "#1f2835" } ]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#f3d19c" } ]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [ { "color": "#2f3948" } ]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#d59563" } ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [ { "color": "#17263c" } ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [ { "color": "#515c6d" } ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [ { "color": "#17263c" } ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initMarkers();
    if (widget.showRouteFromUser && widget.markers.isNotEmpty) {
      _determinePositionAndGetRoute();
    }
  }

  Future<void> _determinePositionAndGetRoute() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle service disabled
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    if (_currentPosition != null && widget.markers.isNotEmpty) {
      _getPolylines(_currentPosition!, widget.markers.first);
    }
  }

  Future<void> _getPolylines(Position origin, MapMarker destination) async {
    List<LatLng> polylineCoordinates = [];
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.lat},${destination.lng}&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return; // Check mounted after await

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> result = polylinePoints.decodePolyline(points);
          if (result.isNotEmpty) {
            for (var point in result) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
        } else {
          print('Directions API: No routes found - ${data['status']}');
          if (data['error_message'] != null) {
            print('Error: ${data['error_message']}');
          }
        }
      } else {
        print(
            'Directions API: Failed to fetch directions - ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching polylines: $e');
    }

    if (polylineCoordinates.isNotEmpty) {
      if (!mounted) return; // Check mounted before setState
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Theme.of(context)
                .colorScheme
                .primary, // Use primary color from theme
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });
      // Animate camera to fit the route
      if (mounted) {
        // This check was already present and is good
        final GoogleMapController controller = await _controller.future;
        LatLngBounds bounds;
        if (origin.latitude > destination.lat) {
          bounds = LatLngBounds(
            southwest: LatLng(
                destination.lat,
                origin.longitude < destination.lng
                    ? origin.longitude
                    : destination.lng),
            northeast: LatLng(
                origin.latitude,
                origin.longitude > destination.lng
                    ? origin.longitude
                    : destination.lng),
          );
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(
                origin.latitude,
                origin.longitude < destination.lng
                    ? origin.longitude
                    : destination.lng),
            northeast: LatLng(
                destination.lat,
                origin.longitude > destination.lng
                    ? origin.longitude
                    : destination.lng),
          );
        }
        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
      }
    }
  }

  /// Create map markers from props
  void _initMarkers() {
    // This method is called from initState, setState is generally safe here.
    // However, if widget.markers could change and trigger a rebuild that calls this again
    // from a different context, a mounted check might be considered for extreme safety,
    // but for now, it's likely fine as is.
    _mapMarkers = widget.markers.map((marker) {
      return Marker(
        markerId: MarkerId('${marker.lat}_${marker.lng}'),
        position: LatLng(marker.lat, marker.lng),
        infoWindow: InfoWindow(
          title: marker.label,
          snippet: marker.description,
        ),
        onTap: () {
          if (!mounted) return; // Add mounted check before setState here too
          setState(() {
            _selectedMarker = marker;
          });
          // _showMarkerDetails might be problematic if it leads to dispose then async work
          // but the setState above is the direct concern for this tap.
          _showMarkerDetails(marker);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final initialLat = widget.initialLat ??
        (widget.markers.isNotEmpty
            ? widget.markers.first.lat
            : _currentPosition?.latitude ?? 44.8176);
    final initialLng = widget.initialLng ??
        (widget.markers.isNotEmpty
            ? widget.markers.first.lng
            : _currentPosition?.longitude ?? 20.4657);

    // The MapComponent will now fill the space given by its parent.
    // Height and margins are removed from here.
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(initialLat, initialLng),
            zoom: widget.initialZoom,
          ),
          markers: _mapMarkers,
          polylines: _polylines,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true, // Keep this for user convenience
          zoomControlsEnabled: true, // Keep zoom controls
          zoomGesturesEnabled:
              true, // Enabled by default, but good to be explicit
          scrollGesturesEnabled: true, // Enabled by default
          rotateGesturesEnabled: true, // Enabled by default
          tiltGesturesEnabled: true, // Enabled by default
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // Apply dark style when map is created
            controller.setMapStyle(_darkMapStyle);
          },
        ),
      ],
    );
  }

  // Show bottom sheet with marker details
  void _showMarkerDetails(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // Use card color from theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location title
            Text(
              marker.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface, // Use onSurface color
                  ),
            ),

            const Divider(height: 32),

            // Description if available
            if (marker.description != null)
              Text(
                marker.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // Use onSurface color
                      height: 1.5,
                    ),
              ),

            const SizedBox(height: 24),

            // Direction button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _animateToMarker(marker);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary, // Use primary color
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onPrimary, // Use onPrimary color
                ),
                child: const Text('Show on map'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Animate camera to selected marker
  Future<void> _animateToMarker(MapMarker marker) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(marker.lat, marker.lng),
          zoom: 17.0,
        ),
      ),
    );
  }
}
