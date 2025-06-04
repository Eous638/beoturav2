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
import 'screens/venues_screen.dart'; // Added VenuesScreen import
import 'screens/blog_screen.dart'; // Updated import
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import './providers/language_provider.dart';
import './providers/position_provider.dart';
import './providers/theme_provider.dart'
    as app_theme; // Add alias to avoid name conflicts
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import Firebase options
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/explore_screen.dart';

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
    // Commented out unused variables
    // final (:downloadProgress, :tileEvents) =
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

    // Commented out unused variables
    // final (:downloadProgress, :tileEvents) =
    const FMTCStore('mapStore').download.startForeground(
          region: osmRegion,
        );
  }

  runApp(const ProviderScope(child: MyApp()));
}

// Create a provider to manage back press handling
final backPressHandlerProvider = StateProvider<DateTime?>((ref) => null);

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

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

  // Method to handle back button press with double-tap protection
  Future<bool> _handleBackPress() async {
    final DateTime now = DateTime.now();
    final lastPress = ref.read(backPressHandlerProvider);

    // If this is the first back press or more than 2 seconds have passed since the last one
    if (lastPress == null ||
        now.difference(lastPress) > const Duration(seconds: 2)) {
      ref.read(backPressHandlerProvider.notifier).state = now;

      // Show a toast or snackbar indicating to press back again
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      return false; // Don't exit the app
    }

    return true; // Allow the app to exit
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(app_theme.isDarkModeProvider);
    final navigationState = useState(0); // Set initial page to Explore
    void onItemTapped(int index) {
      navigationState.value = index;
    }

    final List<Widget> pages = <Widget>[
      const ExploreScreen(),
      // Placeholder for Map
      Center(child: Icon(Icons.map, size: 80, color: Colors.white24)),
      // Placeholder for Profile
      Center(child: Icon(Icons.person, size: 80, color: Colors.white24)),
    ];

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF161211), // --smoky-black
          primary: const Color(0xFFB42020), // --fire-brick (accent)
          secondary: const Color(0xFF243735), // --gunmetal (subtle tint)
          surface: const Color(0xFF243735), // --gunmetal (for cards/surfaces)
          background: const Color(0xFF161211), // --smoky-black
          error: const Color(0xFF611924), // --chocolate-cosmos
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark, // Base theme is dark
        ),
        scaffoldBackgroundColor: const Color(0xFF161211), // --smoky-black
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF161211), // --smoky-black
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF243735), // --gunmetal
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textTheme: GoogleFonts.domineTextTheme(
          Theme.of(context)
              .textTheme
              .copyWith(
                // Headings with Domine
                headlineLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                headlineMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                headlineSmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleSmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                // Body with Playfair Display
                bodyLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
                bodyMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
                bodySmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
              )
              .apply(
                  bodyColor: Colors.white,
                  displayColor:
                      Colors.white), // Ensure all text is white by default
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        // Dark theme will use the same new palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF161211), // --smoky-black
          primary: const Color(0xFFB42020), // --fire-brick (accent)
          secondary: const Color(0xFF243735), // --gunmetal (subtle tint)
          surface: const Color(0xFF243735), // --gunmetal (for cards/surfaces)
          background: const Color(0xFF161211), // --smoky-black
          error: const Color(0xFF611924), // --chocolate-cosmos
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF161211), // --smoky-black
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161211), // --smoky-black
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF243735), // --gunmetal
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textTheme: GoogleFonts.domineTextTheme(
          Theme.of(context)
              .textTheme
              .copyWith(
                // Headings with Domine
                headlineLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                headlineMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                headlineSmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                titleSmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.domine().fontFamily),
                // Body with Playfair Display
                bodyLarge: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
                bodyMedium: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
                bodySmall: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily),
              )
              .apply(
                  bodyColor: Colors.white,
                  displayColor:
                      Colors.white), // Ensure all text is white by default
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: WillPopScope(
        onWillPop: _handleBackPress,
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: navigationState.value,
            selectedItemColor: const Color(0xFFB42020),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF161211),
            onTap: onItemTapped,
          ),
          body: pages[navigationState.value],
        ),
      ),
    );
  }
}
