import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

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

  const MapComponent({
    super.key,
    required this.markers,
    this.initialLat,
    this.initialLng,
    this.initialZoom = 15.0,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _mapMarkers = {};
  MapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  /// Create map markers from props
  void _initMarkers() {
    _mapMarkers = widget.markers.map((marker) {
      return Marker(
        markerId: MarkerId('${marker.lat}_${marker.lng}'),
        position: LatLng(marker.lat, marker.lng),
        infoWindow: InfoWindow(
          title: marker.label,
          snippet: marker.description,
        ),
        onTap: () {
          setState(() {
            _selectedMarker = marker;
          });
          _showMarkerDetails(marker);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate center of map (first marker or provided coordinates)
    final initialLat = widget.initialLat ??
        (widget.markers.isNotEmpty ? widget.markers.first.lat : 44.8176);
    final initialLng = widget.initialLng ??
        (widget.markers.isNotEmpty ? widget.markers.first.lng : 20.4657);

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(initialLat, initialLng),
              zoom: widget.initialZoom,
            ),
            markers: _mapMarkers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // Map overlay with instructions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Tap markers to explore historical sites',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet with marker details
  void _showMarkerDetails(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 32),

            // Description if available
            if (marker.description != null)
              Text(
                marker.description!,
                style: const TextStyle(
                  fontSize: 16,
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
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
