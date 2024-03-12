import 'package:beotura/providers/tour_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beotura/screens/details_screen.dart';
import 'package:beotura/providers/single_route_provider.dart';

class MapSample extends ConsumerStatefulWidget {
  const MapSample({super.key});

  @override
  ConsumerState<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends ConsumerState<MapSample> {
  Position? _currentPosition;
  List<Marker> markers = [];
  late final MapController _mapController =
      MapController(); // MapController added

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getCurrentPosition();
  }

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // ignore: duplicate_ignore
    if (!serviceEnabled) {
      scaffoldMessengerKey.currentState!.showSnackBar(
          const SnackBar(content: Text('location services are disabled')));

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        scaffoldMessengerKey.currentState!.showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions. You must go to settings to allow location services.')));

      return false;
    }
    return true;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final locationProvider = ref.watch(locationProviderProvider);
    final singleRoute = ref.watch(singleRouteProvider);

    locationProvider.when(
      data: (locations) {
        setState(() {
          markers = locations
              .map(
                (location) => Marker(
                  width: 30.0,
                  height: 40.0,
                  point: LatLng(location.latitude, location.longitude),
                  child: GestureDetector(
                    onTap: () {
                      singleRoute.destinationLatitude = location.latitude;
                      singleRoute.destinationLongitude = location.longitude;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            title: location.title,
                            text: location.description,
                            imageUrl: location.imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      location.icon,
                      fit: BoxFit.fill,
                      cacheWidth: 40,
                      cacheHeight: 40,
                    ),
                  ),
                ),
              )
              .toList();
        });
      },
      loading: () {
        debugPrint('Loading');
      },
      error: (error, stackTrace) {
        debugPrint('Error: $error, $stackTrace');
      },
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getCurrentPosition();
          if (_currentPosition != null) {
            _mapController.moveAndRotate(
              LatLng(_currentPosition?.latitude ?? 44.423,
                  _currentPosition?.longitude ?? 20.523),
              15.0,
              0,
            );
          }
        },
        tooltip: 'Get Location',
        child: const Icon(Icons.location_searching),
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: _mapController, // Pass MapController here

              options: MapOptions(
                initialCenter: LatLng(_currentPosition?.latitude ?? 44.423,
                    _currentPosition?.longitude ?? 20.523),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/ormen105/clsc9lq6k00de01qz2yk8dir4/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoib3JtZW4xMDUiLCJhIjoiY2xzYzlhaWdyMGMzZzJrbzRuc3ExZHFxNSJ9.rSM7xW5hfRwNrw3qTVuM6A',
                  userAgentPackageName: 'com.beotura.app',
                ),
                CurrentLocationLayer(),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80,
                    disableClusteringAtZoom: 15,
                    size: const Size(40, 40),
                    markers: markers,
                    builder: (context, markers) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade700,
                            border: const Border.fromBorderSide(
                              BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                          ),
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapSample(),
    );
  }
}
