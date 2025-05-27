import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries/location_queries.dart';
import '../classes/loactions_class.dart';
import 'package:flutter/material.dart';

class GraphQLService {
  static final HttpLink httpLink =
      HttpLink('https://api2.gladni.rs/api/graphql');

  static final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(store: HiveStore()),
    link: httpLink,
  );

  // Fetch a location by ID
  static Future<Location?> getLocationById(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(LocationQueries.getLocationById),
        variables: {'id': id},
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL error: ${result.exception.toString()}');
        return null;
      }

      if (result.data == null || result.data!['location'] == null) {
        debugPrint('No location data found for ID: $id');
        return null;
      }

      final locationData = result.data!['location'];
      return Location.fromJson(locationData);
    } catch (e) {
      debugPrint('Error fetching location: $e');
      return null;
    }
  }
}
