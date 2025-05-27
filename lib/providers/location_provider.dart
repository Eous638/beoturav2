import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../classes/loactions_class.dart';
import '../services/graphql_client.dart';
import '../graphql/queries/location_queries.dart';

final locationProviderProvider =
    AsyncNotifierProvider<LocationProvider, List<Location>>(
        () => LocationProvider());

class LocationProvider extends AsyncNotifier<List<Location>> {
  @override
  Future<List<Location>> build() async {
    return _fetchLocations();
  }

  Future<List<Location>> _fetchLocations() async {
    try {
      final graphQLClient = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(graphQLClient);

      final result =
          await graphQLService.performQuery(LocationQueries.getAllLocations);

      if (result.hasException) {
        throw Exception(
            'Failed to fetch locations: ${result.exception.toString()}');
      }

      final data = result.data?['locations'] as List<dynamic>?;
      print(data);

      if (data == null) {
        return [];
      }

      // Parse and sort locations by the 'order' field
      return data
          .map((locationData) => Location.fromGraphQL(locationData))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }

  Future<Location?> getLocationById(String id) async {
    try {
      final graphQLClient = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(graphQLClient);

      final result = await graphQLService.performQuery(
        LocationQueries.getLocationById,
        variables: {'id': id},
      );

      if (result.hasException) {
        throw Exception(
            'Failed to fetch location: ${result.exception.toString()}');
      }

      final locationData = result.data?['location'];
      if (locationData == null) return null;

      return Location.fromGraphQL(locationData);
    } catch (e) {
      throw Exception('Error fetching location: $e');
    }
  }
}

// Provider to fetch a single location by its ID
final locationByIdProvider =
    FutureProvider.family<Location?, String>((ref, id) async {
  // Access the LocationProvider notifier to use its methods
  final locationNotifier = ref.watch(locationProviderProvider.notifier);
  return locationNotifier.getLocationById(id);
});
