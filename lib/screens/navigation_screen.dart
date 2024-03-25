import 'package:beotura/classes/loactions_class.dart';
import 'package:beotura/enums/language_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beotura/providers/single_route_provider.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:beotura/classes/single_route_class.dart';
import '../l10n/localization_helper.dart';
import '../providers/language_provider.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, this.locations});
  final List<Location>? locations;
  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  late MapBoxNavigation _navigation;
  final bool _isMultipleStop = false;
  late SingleRoute _singleRoute;
  MapBoxNavigationViewController? _controller;
  bool _isNavigating = false;
  late WayPoint _origin;
  int _destinationIndex = 0;
  late List<WayPoint> _wayPoints = [];

  @override
  void initState() {
    super.initState();
    _navigation = MapBoxNavigation();
    _singleRoute = ref.read(singleRouteProvider);
    _origin = WayPoint(
      name: "start",
      latitude: _singleRoute.originLatitude,
      longitude: _singleRoute.originLongitude,
    );
    _wayPoints = widget.locations
            ?.map(
              (e) => WayPoint(
                name: e.title,
                latitude: e.latitude,
                longitude: e.longitude,
              ),
            )
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _navigation.finishNavigation();
    super.dispose();
  }

  _onRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {}
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {});
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {});
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _disposeNavigation();
        setState(() {
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }

  Future<void> _disposeNavigation() async {
    try {
      if (_isNavigating) {
        await _navigation.finishNavigation();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _startNavigation() async {
    var wayPoints = [_origin, _wayPoints[_destinationIndex]];
    await _navigation.registerRouteEventListener(_onRouteEvent);
    _destinationIndex++;

    await _navigation.startNavigation(
      wayPoints: wayPoints,
      options: MapBoxOptions(
        mode: MapBoxNavigationMode.walking,
        language: "en",
        units: VoiceUnits.metric,
        simulateRoute: false,
        voiceInstructionsEnabled: false,
      ),
    );
  }

  bool isFinished() {
    return _destinationIndex >= _wayPoints.length;
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_destinationIndex == 0) {
      return StartPage(
        click: _startNavigation,
      );
    } else if (_destinationIndex < _wayPoints.length) {
      return InfoPage(
          title: ref.read(languageProvider.notifier).state == Language.english
              ? widget.locations![_destinationIndex].title_en
              : widget.locations![_destinationIndex].title,
          imageUrl: widget.locations![_destinationIndex].imageUrl,
          text: ref.read(languageProvider.notifier).state == Language.english
              ? widget.locations![_destinationIndex].description_en
              : widget.locations![_destinationIndex].description,
          click: _startNavigation,
          isFinished: isFinished(),
          goBack: goBack);
    } else {
      return const Center(
        child: Text('You have reached your destination'),
      );
    }
  }
}

class StartPage extends ConsumerWidget {
  final void Function() click;
  const StartPage({
    super.key,
    required this.click,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('navigation')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                click();
              },
              child: Text(l10n.translate('begin journey')),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoPage extends ConsumerWidget {
  final String title;
  final String imageUrl;
  final String text;
  final void Function() click;
  final bool isFinished;
  final void Function() goBack;

  const InfoPage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.text,
    required this.click,
    required this.isFinished,
    required this.goBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('navigation')),
        leading: IconButton(
          onPressed: () {
            goBack();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Image.network(imageUrl),
            const SizedBox(height: 16),
            if (isFinished) ...[
              ElevatedButton(onPressed: () {}, child: const Text('finish!'))
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  click();
                },
                child: const Text('Next Destination'),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
