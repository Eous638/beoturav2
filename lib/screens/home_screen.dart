import 'dart:convert';

import 'package:beotura/enums/language_enum.dart';
import 'package:beotura/providers/current_protest_provider.dart';
import 'package:beotura/providers/tour_provider.dart';
import 'package:beotura/screens/add_blockade_screen.dart';
import 'package:beotura/screens/blockade_details_screen.dart';
import 'package:beotura/screens/login_page.dart';
import 'package:beotura/services/firebase_messaging_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:beotura/screens/details_screen.dart';
import 'package:beotura/providers/single_route_provider.dart';
import 'package:beotura/providers/blockades_provider.dart';
import '../providers/language_provider.dart';
import 'package:beotura/screens/live_protest_page.dart';
import '../providers/auth_provider.dart';
import 'package:dio/dio.dart';

class MapSample extends ConsumerStatefulWidget {
  const MapSample({super.key});

  @override
  ConsumerState<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends ConsumerState<MapSample> {
  List<Marker> markers = [];
  late final MapController _mapController = MapController();
  late final FirebaseMessagingService _firebaseMessagingService;

  @override
  void initState() {
    super.initState();
    _firebaseMessagingService = FirebaseMessagingService();
    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
    _firebaseMessagingService.flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (payload != null) {
          final data = jsonDecode(payload);
          switch (data['type']) {
            case 'notification':
              _showNotificationDialog(data);
              break;
            case 'protest_status_update':
            case 'new_protest':
              _navigateToProtestTab(data);
              break;
          }
        }
      },
    );
  }

  void _navigateToProtestTab(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProtestsTab(),
      ),
    );
  }

  void _showNotificationDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data['title']),
          content: Text(data['content']),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions. You must go to settings to allow location services.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = ref.watch(locationProviderProvider);
    final singleRoute = ref.watch(singleRouteProvider);
    final currentLanguage = ref.watch(languageProvider);
    final tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );

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
                            title: currentLanguage == Language.english
                                ? location.title_en
                                : location.title,
                            text: currentLanguage == Language.english
                                ? location.description_en
                                : location.description,
                            imageUrl: location.imageUrl,
                            tourId: location.id,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      location.icon,
                      fit: BoxFit.fill,
                      cacheWidth: 300,
                      cacheHeight: 300,
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
        heroTag: 'mapSampleFab',
        onPressed: () {
          _mapController.moveAndRotate(
            const LatLng(44.8176, 20.4633), // Center of Belgrade
            15.0,
            0,
          );
        },
        tooltip: 'Center Map',
        child: const Icon(Icons.location_searching),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(44.8176, 20.4633), // Center of Belgrade
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            tileProvider: tileProvider,
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
    return Scaffold(
      body: const MapSample(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeScreenFab', // Unique heroTag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProtestsPage(),
            ),
          );
        },
        tooltip: 'Protesti',
        child: const Icon(Icons.flag),
      ),
    );
  }
}

class ProtestsPage extends StatelessWidget {
  const ProtestsPage({super.key});

  Future<void> _refreshProtests(BuildContext context) async {
    // Implement your refresh logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protesti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProtests(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This page provides information about the current status of the student protests. Please check the updates and supplies needed to support the cause.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Blockades'),
                  subtitle: const Text('Information about current blockades.'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlockadesTab(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Map'),
                  subtitle: const Text('View blockades on the map.'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapTab(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Protests'),
                  subtitle: const Text('Information about upcoming protests.'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProtestsTab(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlockadesTab extends ConsumerWidget {
  const BlockadesTab({super.key});

  Future<void> _refreshBlockades(BuildContext context, WidgetRef ref) async {
    // Implement your refresh logic here
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockadesAsyncValue = ref.watch(blockadesProvider);
    final isLoggedIn = ref.watch(authProvider.notifier).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockades'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to the add blockade screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBlockadeScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBlockades(context, ref),
        child: blockadesAsyncValue.when(
          data: (blockades) {
            return ListView.builder(
              itemCount: blockades.length,
              itemBuilder: (context, index) {
                final blockade = blockades[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(blockade.universityName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(blockade.status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BlockadeDetailsScreen(blockade: blockade),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class MapTab extends ConsumerWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockadesAsyncValue = ref.watch(blockadesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: blockadesAsyncValue.when(
        data: (blockades) {
          final markers = blockades.map((blockade) {
            return Marker(
              width: 30.0,
              height: 40.0,
              point: LatLng(blockade.coordinates.lat, blockade.coordinates.lon),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BlockadeDetailsScreen(blockade: blockade),
                    ),
                  );
                },
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
            );
          }).toList();

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(44.8176, 20.4633), // Center of Belgrade
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.beotura.app',
                tileProvider: FMTCTileProvider(
                  stores: const {
                    'mapStore': BrowseStoreStrategy.readUpdateCreate
                  },
                ),
              ),
              MarkerLayer(markers: markers),
              CurrentLocationLayer(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class ProtestsTab extends ConsumerWidget {
  const ProtestsTab({super.key});

  Future<void> _refreshProtests(BuildContext context, WidgetRef ref) async {
    // Implement your refresh logic here
  }

  Future<void> _updateProtestStatus(BuildContext context, WidgetRef ref,
      String protestId, String status) async {
    final token = ref.read(authProvider)?.token;
    try {
      final response = await Dio().put(
        'https://api2.gladni.rs/api/beotura/update_protest_status/$protestId?status=$status',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Protest status updated successfully')),
        );
        ref.refresh(currentProtestProvider);
      } else {
        throw Exception('Failed to update protest status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addProtest(BuildContext context, WidgetRef ref) async {
    final token = ref.read(authProvider)?.token;
    final titleController = TextEditingController();
    final aboutController = TextEditingController();
    final locationController = TextEditingController();
    LatLng? selectedCoordinates;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Protest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: 'About'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                    }
                  },
                  child: const Text('Select Date & Time'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    selectedCoordinates = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapLocationPicker(),
                      ),
                    );
                  },
                  child: const Text('Select Location on Map'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    aboutController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null &&
                    selectedCoordinates != null) {
                  final selectedDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  try {
                    final response = await Dio().post(
                      'https://api2.gladni.rs/api/beotura/add_protest',
                      data: {
                        'title': titleController.text,
                        'about': aboutController.text,
                        'time': selectedDateTime.toIso8601String(),
                        'location_name': locationController.text,
                        'coordinates': {
                          'lat': selectedCoordinates!.latitude,
                          'lon': selectedCoordinates!.longitude,
                        },
                        'attendance': 0,
                        'status': 'scheduled',
                      },
                      options: Options(
                        headers: {'Authorization': 'Bearer $token'},
                      ),
                    );
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Protest added successfully')),
                      );
                      ref.refresh(currentProtestProvider);
                      Navigator.pop(context);
                    } else {
                      throw Exception('Failed to add protest');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProtest(
      BuildContext context, WidgetRef ref, Protest protest) async {
    final token = ref.read(authProvider)?.token;
    final titleController = TextEditingController(text: protest.title);
    final aboutController = TextEditingController(text: protest.about);
    final locationController =
        TextEditingController(text: protest.locationName);
    LatLng? selectedCoordinates =
        LatLng(protest.coordinates.lat, protest.coordinates.lon);
    DateTime? selectedDate = protest.time;
    TimeOfDay? selectedTime = TimeOfDay.fromDateTime(protest.time);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Protest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: 'About'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    selectedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      selectedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime!,
                      );
                    }
                  },
                  child: const Text('Select Date & Time'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    selectedCoordinates = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapLocationPicker(
                          initialCoordinates: selectedCoordinates,
                        ),
                      ),
                    );
                  },
                  child: const Text('Select Location on Map'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    aboutController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null &&
                    selectedCoordinates != null) {
                  final selectedDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  try {
                    final response = await Dio().put(
                      'https://api2.gladni.rs/api/beotura/edit_protest/${protest.id}',
                      data: {
                        'title': titleController.text,
                        'about': aboutController.text,
                        'time': selectedDateTime.toIso8601String(),
                        'location_name': locationController.text,
                        'coordinates': {
                          'lat': selectedCoordinates!.latitude,
                          'lon': selectedCoordinates!.longitude,
                        },
                        'attendance': protest.attendance,
                        'status': protest.status,
                      },
                      options: Options(
                        headers: {'Authorization': 'Bearer $token'},
                      ),
                    );
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Protest updated successfully')),
                      );
                      ref.refresh(currentProtestProvider);
                      Navigator.pop(context);
                    } else {
                      throw Exception('Failed to update protest');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'finished':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase() == 'scheduled'
                ? Icons.event
                : status.toLowerCase() == 'active'
                    ? Icons.local_activity
                    : Icons.event_available,
            size: 16,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProtestAsyncValue = ref.watch(currentProtestProvider);
    final isLoggedIn = ref.watch(authProvider.notifier).isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProtests(context, ref),
        child: currentProtestAsyncValue.when(
          data: (protest) {
            return Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                          protest.coordinates.lat, protest.coordinates.lon),
                      initialZoom: 15,
                      maxZoom: 14,
                      minZoom: 5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.beotura.app',
                        tileProvider: FMTCTileProvider(
                          stores: const {
                            'mapStore': BrowseStoreStrategy.readUpdateCreate
                          },
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(protest.coordinates.lat,
                                protest.coordinates.lon),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.location_on,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(
                                protest.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusChip(protest.status),
                              const SizedBox(height: 12),
                              Text(
                                protest.about,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.red),
                                title: Text(
                                  protest.locationName,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: const Text('Location'),
                              ),
                              if (protest.status == 'scheduled') ...[
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.access_time,
                                      color: Colors.orange),
                                  title: Text(
                                    protest.time.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  subtitle: const Text('Time'),
                                ),
                                const SizedBox(height: 12),
                                if (isLoggedIn) ...[
                                  ElevatedButton(
                                    onPressed: () => _updateProtestStatus(
                                        context, ref, protest.id, 'active'),
                                    child: const Text('Start Protest'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _editProtest(context, ref, protest),
                                    child: const Text('Edit Protest'),
                                  ),
                                ],
                              ] else if (protest.status == 'active') ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LiveProtestPage(
                                          protest: protest,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(Icons.group_add,
                                      color: Colors.white),
                                  label: const Text(
                                    'Join Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isLoggedIn)
                                  ElevatedButton(
                                    onPressed: () => _updateProtestStatus(
                                        context, ref, protest.id, 'finished'),
                                    child: const Text('End Protest'),
                                  ),
                              ] else if (protest.status == 'finished') ...[
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.groups,
                                      color: Colors.blue),
                                  title: Text(
                                    '${protest.attendance} attendees',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  subtitle: const Text('Final Attendance'),
                                ),
                                if (isLoggedIn)
                                  ElevatedButton(
                                    onPressed: () => _addProtest(context, ref),
                                    child: const Text('Create Next Protest'),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialCoordinates;

  const MapLocationPicker({super.key, this.initialCoordinates});

  @override
  _MapLocationPickerState createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? _selectedCoordinates;

  @override
  void initState() {
    super.initState();
    _selectedCoordinates = widget.initialCoordinates ??
        LatLng(44.8176, 20.4633); // Default to Belgrade
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedCoordinates);
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedCoordinates!,
          initialZoom: 15,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedCoordinates = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.beotura.app',
            tileProvider: FMTCTileProvider(
              stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
            ),
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: _selectedCoordinates!,
                child:
                    const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
