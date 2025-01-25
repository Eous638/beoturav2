import 'package:beotura/enums/language_enum.dart';
import 'package:beotura/providers/single_route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'screens/about_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/language_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import './providers/language_provider.dart';
import './providers/position_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:beotura/services/firebase_messaging_service.dart'; // Import FirebaseMessagingService
import 'firebase_options.dart'; // Import Firebase options

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Load Firebase options
  );

  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();
  FlutterForegroundTask.initCommunicationPort();

  // Define the region for Belgrade
  final region = RectangleRegion(
    LatLngBounds(LatLng(44.7334, 20.3755), LatLng(44.9021, 20.5536)),
  );

  // Convert the region to a downloadable region
  final downloadableRegion = region.toDownloadable(
    minZoom: 1,
    maxZoom: 18,
    options: TileLayer(
      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.beotura.app',
    ),
  );

  // Start the download
  try {
    final (:downloadProgress, :tileEvents) =
        const FMTCStore('mapStore').download.startForeground(
              region: downloadableRegion,
            );
  } catch (e) {
    // Handle connection refused and default to OSM
    final osmRegion = region.toDownloadable(
      minZoom: 1,
      maxZoom: 18,
      options: TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.beotura.app',
      ),
    );

    final (:downloadProgress, :tileEvents) =
        const FMTCStore('mapStore').download.startForeground(
              region: osmRegion,
            );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

  static final List<Widget> _pages = <Widget>[
    const LanguageScreen(),
    const ToursScreen(),
    const HomeScreen(),
    const LocationScreen(),
    const AboutScreen(),
  ];

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late FirebaseMessagingService _firebaseMessagingService;

  @override
  void initState() {
    super.initState();
    getLanguage();
    _requestPermissions();
    _initService();
    _initializeUUID();
    _firebaseMessagingService = FirebaseMessagingService(); // Initialize FCM service
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language != null) {
      ref.read(languageProvider.notifier).update((state) {
        if (language == Language.english.toString()) {
          ref
              .read(languageProvider.notifier)
              .update((state) => Language.english);
        } else {
          ref
              .read(languageProvider.notifier)
              .update((state) => Language.serbian);
        }
        return state;
      });
    } else {
      ref.read(languageProvider.notifier).update((state) => Language.serbian);
    }
  }

  Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _initializeUUID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('device_uuid');
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString('device_uuid', uuid);
    }
    debugPrint('Device UUID: $uuid');
  }

  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final singleRoute = ref.watch(singleRouteProvider);
    final l10n = LocalizationHelper(ref);
    final currentPosition = ref.watch(positionProvider);

    if (currentPosition != null) {
      singleRoute.originLatitude = currentPosition.latitude;
      singleRoute.originLongitude = currentPosition.longitude;
    }
    final navigationState = useState(2);
    void onItemTapped(int index) {
      navigationState.value = index;
    }

    final tileProvider = FMTCTileProvider(
      stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    );

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: Colors.white)),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.language_outlined),
              label: l10n.translate('language'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              label: l10n.translate('Tours'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: l10n.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_pin),
              label: l10n.translate('locations'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school),
              label: l10n.translate('about'),
            ),
          ],
          currentIndex: navigationState.value,
          selectedItemColor: Colors.blue,
          onTap: onItemTapped,
        ),
        body: Center(
          child: MyApp._pages.elementAt(navigationState.value),
        ),
      ),
    );
  }
}
