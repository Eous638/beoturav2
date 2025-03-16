import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../classes/tours_class.dart';
import '../classes/loactions_class.dart';
import '../services/graphql_client.dart';
import '../graphql/queries/tour_queries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'tour_provider.g.dart';

final tourProviderProvider =
    AsyncNotifierProvider<TourProvider, List<Tour>>(() => TourProvider());

class TourProvider extends AsyncNotifier<List<Tour>> {
  @override
  Future<List<Tour>> build() async {
    return _fetchTours();
  }

  Future<List<Tour>> _fetchTours() async {
    try {
      final graphQLClient = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(graphQLClient);

      final result = await graphQLService.performQuery(TourQueries.getAllTours);

      if (result.hasException) {
        throw Exception(
            'Failed to fetch tours: ${result.exception.toString()}');
      }

      final data = result.data?['tours'] as List<dynamic>?;

      if (data == null) {
        return [];
      }

      // Parse and sort tours by the 'order' field
      return data.map((tourData) => Tour.fromGraphQL(tourData)).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      throw Exception('Error fetching tours: $e');
    }
  }

  Future<Tour?> getTourById(String id) async {
    try {
      final graphQLClient = ref.read(graphQLClientProvider);
      final graphQLService = GraphQLService(graphQLClient);

      final result = await graphQLService.performQuery(
        TourQueries.getTourById,
        variables: {'id': id},
      );

      if (result.hasException) {
        throw Exception('Failed to fetch tour: ${result.exception.toString()}');
      }

      final tourData = result.data?['tour'];
      if (tourData == null) return null;

      return Tour.fromGraphQL(tourData);
    } catch (e) {
      throw Exception('Error fetching tour: $e');
    }
  }
}

@riverpod
Future<List<Location>> locationProvider(LocationProviderRef ref) async {
  try {
    final response =
        await http.get(Uri.parse('https://api2.gladni.rs/api/beotura/places'));
    ref.keepAlive();
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final fetchedTours =
          data.map<Location>((json) => Location.fromGraphQL(json)).toList();

      return fetchedTours;
    } else {
      throw Exception('Failed to fetch tours: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching locations: $e');
    rethrow;
  }
}
