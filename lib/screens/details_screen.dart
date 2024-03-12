import 'package:flutter/material.dart';

import '../classes/loactions_class.dart';

import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/single_route_provider.dart';
import '../classes/single_route_class.dart';
import './navigation_screen.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.text,
    this.locations,
  });
  final String title;
  final String imageUrl;
  final String text;
  final List<Location>? locations;

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  late MapBoxNavigation _navigation;
  final bool _isMultipleStop = false;
  late SingleRoute _singleRoute;
  MapBoxNavigationViewController? _controller;
  bool _isNavigating = false;
  late WayPoint _origin;
  late WayPoint _destination;

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
    _destination = WayPoint(
      name: "destination",
      latitude: _singleRoute.destinationLatitude,
      longitude: _singleRoute.destinationLongitude,
    );
    if (widget.locations != null) {
      widget.locations!.sort((a, b) => a.order.compareTo(b.order));
    }
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
    var wayPoints = [_origin, _destination];
    await _navigation.registerRouteEventListener(_onRouteEvent);

    await _navigation.startNavigation(
      wayPoints: wayPoints,
      options: MapBoxOptions(
        mode: MapBoxNavigationMode.walking,
        language: "en",
        units: VoiceUnits.imperial,
        simulateRoute: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.locations != null)
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      'Locations',
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true, // Important for scrollable layouts
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable nested scrolling
                        itemCount: widget.locations!
                            .length, // Assuming locations is not null if we're within this 'if' block
                        itemBuilder: (context, index) {
                          final location = widget.locations![index];

                          return Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 63, 63, 63),
                            ),
                            child: ListTile(
                              leading: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      location.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(location.title),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.locations == null) {
                    _startNavigation();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationScreen(
                          locations: widget.locations,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: Colors.red, // Set the button color to red
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Zapocni put',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
