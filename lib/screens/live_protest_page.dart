import 'dart:convert';
import 'dart:io'; // Import dart:io to check platform
import 'package:beotura/classes/organiser_location_class.dart';
import 'package:beotura/classes/protest_alert_class.dart';
import 'package:beotura/classes/protest_location_class.dart';
import 'package:beotura/services/send_alert_service.dart';
import 'package:beotura/services/send_notification_service.dart';
import 'package:beotura/services/websocket_connection.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:beotura/providers/auth_provider.dart';
import 'package:beotura/providers/current_protest_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../services/foreground_task_service.dart';
import 'package:beotura/widget/notification_card.dart';
import 'package:beotura/services/ble_mesh_service.dart'; // Import BLE mesh service
import 'package:beotura/services/combined_communication_service.dart'; // Import CombinedCommunicationService
import 'package:beotura/services/speed_test_service.dart'; // Import SpeedTestService

class LiveProtestPage extends ConsumerStatefulWidget {
  final Protest protest;

  const LiveProtestPage({required this.protest, super.key});

  @override
  ConsumerState<LiveProtestPage> createState() => _LiveProtestPageState();
}

class _LiveProtestPageState extends ConsumerState<LiveProtestPage>
    with SingleTickerProviderStateMixin {
  late CombinedCommunicationService _communicationService;
  bool isOrganizer = false;
  List<OrganizerNotification> notifications = [];
  Map<String, ProtestAlert> activeAlerts = {};
  int activeUsers = 0;
  Position? currentLocation;
  final mapController = MapController();
  final MapController _locationSelectionController = MapController();
  late AnimationController _notificationController;
  Timer? _locationTimer;
  String? myActiveAlert; // Track if user has an active alert
  Map<String, ProtestLocation> userLocations = {}; // Track user locations
  LatLng? userSelectedLocation; // Track user selected location
  late ProtestAlertService _alertService;
  late ProtestNotificationsService _notificationsService;
  late SpeedTestService _speedTestService;
  double _connectionSpeed = 0.0;
  bool _isConnectionUsable = false;
  int _meshDeviceCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _speedTestService = SpeedTestService();
    _initializeCommunicationService();
    initializeLocation(); // Use real location updates
    _alertService = ProtestAlertService(
      webSocketService: _communicationService,
      context: context,
    );

    // Perform initial speed test
    _performSpeedTest();

    // Schedule periodic speed tests
    Timer.periodic(const Duration(minutes: 5), (_) => _performSpeedTest());

    // Remove ForegroundTaskService initialization as it's now handled by CombinedCommunicationService
    // ForegroundTaskService.startForegroundTask(ref); // Remove this line

    // Instead, just start the foreground service
    FlutterForegroundTask.startService(
      notificationTitle: 'Active Protest',
      notificationText: 'Communicating with other users',
      callback: startCallback,
    );

    // Move alert and notification handlers to CombinedCommunicationService
    _communicationService.onNewAlert = (alert) {
      if (mounted) {
        setState(() {
          activeAlerts[alert.owner] = alert;
        });
      }
    };

    _communicationService.onNewNotification = (notification) {
      if (mounted) {
        setState(() {
          notifications.add(notification);
        });
      }
    };
  }

  Future<void> _performSpeedTest() async {
    try {
      final isUsable = await _speedTestService.isConnectionUsable();
      if (mounted) {
        setState(() {
          _isConnectionUsable = isUsable;
        });
      }
    } catch (e) {
      debugPrint('Error performing speed test: $e');
    }
  }

  IconData _getConnectionQualityIcon() {
    return _isConnectionUsable ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off;
  }

  Widget _buildUserCountIcon() {
    if (_isConnectionUsable && _communicationService.isConnected) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('👥 $activeUsers'),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('🔗 $_meshDeviceCount'),
        ),
      );
    }
  }

  void _initializeCommunicationService() {
    _communicationService = CombinedCommunicationService(
      ref: ref,
      onNewNotification: (notification) {
        if (mounted) {
          setState(() {
            notifications.add(notification);
          });
        }
      },
      onNewAlert: (alert) {
        if (mounted) {
          setState(() {
            activeAlerts[alert.owner] = alert;
          });
        }
      },
      onYourAlert: (id, alert) {
        if (mounted) {
          setState(() {
            myActiveAlert = id;
            activeAlerts[alert.owner] = alert;
          });
        }
      },
      onAlertStopped: (alertId) {
        if (mounted) {
          setState(() {
            activeAlerts.remove(alertId);
          });
        }
      },
      onStateUpdate: (newNotifications, newAlerts, count) {
        if (mounted) {
          setState(() {
            notifications = newNotifications;
            activeAlerts = newAlerts;
            activeUsers = count;
            if (myActiveAlert != null &&
                !activeAlerts.containsKey(myActiveAlert)) {
              myActiveAlert = null;
            }
          });
        }
      },
    );

    final isLoggedIn = ref.read(authProvider.notifier).isLoggedIn;
    final user = ref.read(authProvider);
    if (isLoggedIn && user != null) {
      _communicationService.sendToken(user.token);
      _communicationService.registerAsOrganizer();
    }

    // Update mesh device count periodically
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _meshDeviceCount = _communicationService.meshDeviceCount;
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint('LiveProtestPage: Disposing...');
    _notificationController.dispose();
    _locationTimer?.cancel();
    _locationSelectionController.dispose();
    _communicationService
        .dispose(); // Make sure this runs before stopping foreground task
    ForegroundTaskService.stopForegroundTask();
    super.dispose();
  }

  Future<void> initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Start periodic location updates
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateLocation();
    });

    // Get initial location
    await _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      final newLocation = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        currentLocation = newLocation;
      });

      // Send location update only through communication service
      _communicationService.sendLocationUpdate(newLocation);

      // Remove the ForegroundTaskService location update as it's redundant
      // ForegroundTaskService.sendLocationUpdate(newLocation); // Remove this line
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> sendAlert(String alertType) async {
    if (!mounted) return;

    await _alertService.sendAlert(
      alertType: alertType,
      currentLocation: currentLocation != null
          ? LatLng(currentLocation!.latitude, currentLocation!.longitude)
          : null,
      selectLocationOnMap: _selectLocationOnMap,
    );

    if (!mounted) return;

    setState(() {
      myActiveAlert = alertType;
    });
  }

  Future<LatLng?> _selectLocationOnMap() async {
    print('_selectLocationOnMap called');
    Completer<LatLng?> completer = Completer();
    LatLng? localSelectedLocation;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Select Location'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context);
                      if (!completer.isCompleted) {
                        completer.complete(localSelectedLocation);
                      }
                    },
                  ),
                ],
              ),
              body: FlutterMap(
                mapController: _locationSelectionController,
                options: MapOptions(
                  initialCenter: LatLng(44.7866, 20.4489),
                  initialZoom: 15,
                  onTap: (_, point) {
                    setDialogState(() {
                      localSelectedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (localSelectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: localSelectedLocation!,
                          child:
                              const Icon(Icons.location_on, color: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    final selectedLocation = await completer.future;
    if (selectedLocation != null) {
      setState(() {
        userSelectedLocation = selectedLocation;
      });
    }
    return selectedLocation;
  }

  void _vibrate(String severity) {
    switch (severity) {
      case 'urgent':
        Vibration.vibrate(
            pattern: [0, 500, 200, 500, 200, 500],
            intensities: [255, 255, 255]);
        break;
      case 'warning':
        Vibration.vibrate(
            pattern: [0, 500, 200, 500], intensities: [128, 128]);
        break;
      default:
        Vibration.vibrate(pattern: [0, 500], intensities: [64]);
        break;
    }
    }

  void _showNotification(String message, {String severity = 'info'}) {
    _vibrate(severity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showNotificationScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.map((notification) {
              return NotificationCard(notification: notification);
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void stopAlert(String alertId) {
    ForegroundTaskService.stopAlert(alertId);
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.red,
      elevation: 8.0,
      children: [
        SpeedDialChild(
          child: Icon(Icons.local_police,
              color: myActiveAlert != null &&
                      activeAlerts[myActiveAlert]?.type == 'POLICE'
                  ? Colors.red
                  : Colors.white),
          backgroundColor: Colors.blue,
          label: 'Police',
          onTap: () => _handleAlertTap('POLICE'),
        ),
        SpeedDialChild(
          child: Icon(Icons.medical_services,
              color: myActiveAlert != null &&
                      activeAlerts[myActiveAlert]?.type == 'MEDICAL'
                  ? Colors.red
                  : Colors.white),
          backgroundColor: Colors.green,
          label: 'Medical',
          onTap: () => _handleAlertTap('MEDICAL'),
        ),
        SpeedDialChild(
          child: Icon(Icons.warning,
              color: myActiveAlert != null &&
                      activeAlerts[myActiveAlert]?.type == 'DANGER'
                  ? Colors.red
                  : Colors.white),
          backgroundColor: Colors.red,
          label: 'Danger',
          onTap: () => _handleAlertTap('DANGER'),
        ),
        SpeedDialChild(
          child: Icon(Icons.emergency_share,
              color: myActiveAlert != null &&
                      activeAlerts[myActiveAlert]?.type == 'HELP'
                  ? Colors.red
                  : Colors.white),
          backgroundColor: Colors.red,
          label: 'Help',
          onTap: () => _handleAlertTap('HELP'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.campaign),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          label: 'Send Update',
          onTap: () => _showNotificationDialog(context),
        ),
      ],
    );
  }

  Future<void> _handleAlertTap(String alertType) async {
    try {
      if (!mounted) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await sendAlert(alertType);

      // Dismiss loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Dismiss loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending alert: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider.notifier).isLoggedIn;
    final tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardTheme: CardTheme(
          color: const Color(0xFF2D2D2D),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.protest.title),
          actions: [
            // Show active users count or mesh device count
            _buildUserCountIcon(),
            // Connection quality icon
            Icon(_getConnectionQualityIcon()),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _showNotificationScreen(context),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  widget.protest.coordinates.lat,
                  widget.protest.coordinates.lon,
                ),
                initialZoom: 15,
                maxZoom: 18,
                minZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  tileProvider: tileProvider,
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: isLoggedIn ? _buildSpeedDial() : null,
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Alert markers
    markers.addAll(
      activeAlerts.values.map((alert) => Marker(
            width: 30,
            height: 30,
            point: LatLng(alert.location.lat, alert.location.lng),
            child: GestureDetector(
              onTap: () {
                if (ref.read(authProvider.notifier).isLoggedIn) {
                  stopAlert(alert.id);
                }
              },
              child: TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert.type).withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        alert.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
          )),
    );

    // Notification markers
    markers.addAll(
      notifications
          .where((n) => n.location != null)
          .map((notification) => Marker(
                width: 40,
                height: 40,
                point: LatLng(
                    notification.location!.lat, notification.location!.lng),
                child: GestureDetector(
                  onTap: () => _showNotificationDetails(context, notification),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.notification_important,
                        color: Colors.white),
                  ),
                ),
              )),
    );

    // User location markers
    markers.addAll(
      userLocations.values.map((location) => Marker(
            width: 5,
            height: 5,
            point: LatLng(location.lat, location.lng),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          )),
    );

    return markers;
  }

  void _showNotificationDetails(
      BuildContext context, OrganizerNotification notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification.title),
          content: Text(notification.content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotificationDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String severity = 'info';
    LatLng? notificationLocation;

    void onLocationSelected(LatLng location) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          notificationLocation = location;
        });
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              DropdownButton<String>(
                value: severity,
                onChanged: (String? newValue) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      severity = newValue!;
                    });
                  });
                },
                items: <String>['info', 'warning', 'urgent']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (notificationLocation != null)
                Text(
                  'Location: ${notificationLocation!.latitude}, ${notificationLocation!.longitude}',
                  style: const TextStyle(color: Colors.green),
                ),
              TextButton(
                onPressed: () async {
                  final selectedLocation = await _selectLocationOnMap();
                  if (selectedLocation != null) {
                    onLocationSelected(selectedLocation);
                  }
                },
                child: const Text('Add Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _communicationService.sendNotification(
                  title: titleController.text,
                  content: contentController.text,
                  severity: severity,
                  location: notificationLocation,
                );
                Navigator.pop(context);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'POLICE':
        return Colors.blue;
      case 'MEDICAL':
        return Colors.green;
      case 'DANGER':
        return Colors.red;
      case 'HELP':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
