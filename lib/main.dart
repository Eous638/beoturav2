import 'package:beotura/enums/language_enum.dart';
import 'package:beotura/providers/single_route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // Add GraphQL import
import 'screens/settings_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/language_screen.dart';
import 'screens/home_screen.dart'; // Ensure this import is present
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import './providers/language_provider.dart';
import './providers/position_provider.dart';
import './providers/theme_provider.dart'
    as app_theme; // Add alias to avoid name conflicts
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import Firebase options
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GraphQL cache
  await initHiveForFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Load Firebase options
  );

  // Initialize Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

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
    const HomeScreen(), // Make sure HomeScreen is included here
    const LocationsScreen(),
    const SettingsScreen(),
  ];

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    getLanguage();
    _initializeUUID();
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
    final isDarkMode =
        ref.watch(app_theme.isDarkModeProvider); // Use aliased import

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
              seedColor: Colors.deepPurple, // Changed to deepPurple
              brightness: Brightness.light), // Light mode
          useMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: Colors.black)), // Black text for light mode
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, // Changed to deepPurple
              brightness: Brightness.dark),
          useMaterial3: true,
          textTheme: GoogleFonts.openSansTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: Colors.white)), // White text for dark mode
      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light, // Now using Flutter's ThemeMode without conflict
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
              icon: const Icon(
                  Icons.settings), // Changed icon from school to settings
              label: l10n.translate(
                  'settings'), // Changed label from "about" to "settings"
            ),
          ],
          currentIndex: navigationState.value,
          selectedItemColor: Colors.deepPurple, // Changed to purple
          onTap: onItemTapped,
        ),
        body: Center(
          child: MyApp._pages.elementAt(navigationState.value),
        ),
      ),
    );
  }
}
