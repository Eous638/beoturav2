import 'package:beotura/classes/single_route_class.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'single_route_provider.g.dart';

@riverpod
SingleRoute singleRoute(SingleRouteRef ref) {
  return SingleRoute(
    originLatitude: 0.0,
    originLongitude: 0.0,
    destinationLatitude: 0.0,
    destinationLongitude: 0.0,
  );
}
