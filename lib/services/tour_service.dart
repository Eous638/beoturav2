import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries/tour_queries.dart';
import '../classes/tours_class.dart';
import 'package:flutter/material.dart';

class TourService {
  static final HttpLink httpLink =
      HttpLink('https://api2.gladni.rs/api/graphql');

  static final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(store: HiveStore()),
    link: httpLink,
  );

  // Fetch basic tour list (for listings)
  static Future<List<Tour>> getAllToursBasic() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(TourQueries.getAllToursBasic),
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL error: ${result.exception.toString()}');
        return [];
      }

      if (result.data == null || result.data!['tours'] == null) {
        debugPrint('No tours found');
        return [];
      }

      final List<dynamic> toursData = result.data!['tours'];
      return toursData.map((tourData) => Tour.fromGraphQL(tourData)).toList();
    } catch (e) {
      debugPrint('Error fetching tours: $e');
      return [];
    }
  }

  // Fetch complete tour data with all pages and locations
  static Future<Tour?> getTourComplete(String id) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(TourQueries.getTourComplete),
        variables: {'id': id},
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL error: ${result.exception.toString()}');
        return null;
      }

      if (result.data == null || result.data!['tour'] == null) {
        debugPrint('No tour found with ID: $id');
        return null;
      }

      final tourData = result.data!['tour'];
      return Tour.fromGraphQL(tourData);
    } catch (e) {
      debugPrint('Error fetching tour: $e');
      return null;
    }
  }
}
