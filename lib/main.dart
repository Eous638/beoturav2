import 'package:beotura/enums/language_enum.dart';
import 'package:beotura/providers/single_route_provider.dart';
import 'package:flutter/material.dart';
import 'screens/about_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/language_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/home_screen.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../l10n/localization_helper.dart';
import './providers/language_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
  Position? _currentPosition;
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
    getLanguage();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getCurrentPosition();
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
  Widget build(BuildContext context) {
    final singleRoute = ref.watch(singleRouteProvider);
    final l10n = LocalizationHelper(ref);
    // ignore: unused_local_variable
    final currentLanguage = ref.watch(languageProvider);

    if (_currentPosition != null) {
      singleRoute.originLatitude = _currentPosition!.latitude;
      singleRoute.originLongitude = _currentPosition!.longitude;
    }
    final navigationState = useState(2);
    void onItemTapped(int index) {
      navigationState.value = index;
    }

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
