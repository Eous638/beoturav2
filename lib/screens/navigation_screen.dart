import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../classes/loactions_class.dart';
import 'full_screen_map_screen.dart';
import '../providers/position_provider.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({
    super.key,
    required this.sessionId,
    required this.totalPlaces,
    required this.orderedPlaces,
    required this.nextPlace,
    required this.totalDistanceKm,
    required this.totalDurationMin,
    required this.fullTourPolyline,
    required this.tourId,
  });

  final String sessionId;
  final int totalPlaces;
  final List<dynamic> orderedPlaces;
  final dynamic nextPlace;
  final double totalDistanceKm;
  final double totalDurationMin;
  final String fullTourPolyline;
  final String tourId;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  late List<Marker> _markers;
  late Polyline _polyline;

  @override
  void initState() {
    super.initState();
    _markers = widget.orderedPlaces
        .map(
          (place) => Marker(
            width: 30.0,
            height: 40.0,
            point: LatLng(place['latitude'], place['longitude']),
            child: const Icon(Icons.location_on, color: Colors.red),
          ),
        )
        .toList();

    _polyline = Polyline(
      points: decodePolyline(widget.fullTourPolyline),
      strokeWidth: 4.0,
      color: Colors.blue,
    );
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

  String formatDuration(double minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = (minutes % 60).toInt();
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}min';
    } else {
      return '${remainingMinutes}min';
    }
  }

  void _navigateToFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapScreen(
          sessionId: widget.sessionId,
          tourId: widget.tourId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(positionProvider);
    final tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _markers.isNotEmpty
                    ? _markers.first.point
                    : (currentPosition != null
                        ? LatLng(
                            currentPosition.latitude, currentPosition.longitude)
                        : LatLng(0, 0)),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  tileProvider: tileProvider,
                ),
                MarkerLayer(
                  markers: _markers,
                ),
                PolylineLayer(
                  polylines: [_polyline],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Column(
                  children: [
                    Text(
                      'Total Distance',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.totalDistanceKm.toStringAsFixed(0)} km',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Total Duration',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatDuration(widget.totalDurationMin),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _navigateToFullScreenMap,
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Start Tour',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
