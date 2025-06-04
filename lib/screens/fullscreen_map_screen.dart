import 'package:flutter/material.dart';
import '../widgets/tour_components/map_component.dart' as map_component;

class FullScreenMapScreen extends StatelessWidget {
  final List<map_component.MapMarker> markers;
  final bool showRouteFromUser;
  final double? initialLat;
  final double? initialLng;
  final double initialZoom;
  final String? title;

  const FullScreenMapScreen({
    super.key,
    required this.markers,
    this.showRouteFromUser = false,
    this.initialLat,
    this.initialLng,
    this.initialZoom = 15.0,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ??
            theme.scaffoldBackgroundColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title ?? (markers.isNotEmpty ? markers.first.label : 'Map View'),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: map_component.MapComponent(
        markers: markers,
        showRouteFromUser: showRouteFromUser,
        initialLat: initialLat,
        initialLng: initialLng,
        initialZoom: initialZoom,
      ),
    );
  }
}
