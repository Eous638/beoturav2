import 'package:flutter/material.dart';
import '../classes/tours_class.dart';
import '../classes/loactions_class.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Use a simple Future provider to get all tours from the new API
final tourProviderProvider = FutureProvider<List<Tour>>((ref) async {
  try {
    // Use the new API endpoint
    final response =
        await http.get(Uri.parse('https://api.beotura.rs/api/tours'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch tours: ${response.statusCode}');
    }

    // Parse the response body and ensure it's UTF-8 encoded
    final jsonData = json.decode(utf8.decode(response.bodyBytes));

    // Convert JSON to Tour objects
    final tours = (jsonData as List<dynamic>)
        .map((tourData) => Tour.fromJson(tourData))
        .toList();

    // Sort the tours by their order field
    tours.sort((a, b) => a.order.compareTo(b.order));

    return tours;
  } catch (e) {
    debugPrint('Error in tourProviderProvider: $e');
    throw Exception('Failed to load tours: $e');
  }
});

// A provider for getting a tour by ID
final tourByIdProvider = FutureProvider.family<Tour?, String>((ref, id) async {
  final tours = await ref.watch(tourProviderProvider.future);
  try {
    return tours.firstWhere((tour) => tour.id == id);
  } catch (e) {
    // Return null if no tour matching the ID is found
    return null;
  }
});

// A provider for getting all locations from all tours
final allLocationsProvider = FutureProvider<List<Location>>((ref) async {
  final tours = await ref.watch(tourProviderProvider.future);
  final allLocations = <Location>[];

  // Extract locations from all tours
  for (final tour in tours) {
    allLocations.addAll(tour.locations);
  }

  // Sort locations by order
  allLocations.sort((a, b) => a.order.compareTo(b.order));

  return allLocations;
});

// Provider to get locations filtered by tour (category)
final locationsByTourProvider =
    FutureProvider.family<List<Location>, String>((ref, tourId) async {
  final tours = await ref.watch(tourProviderProvider.future);

  try {
    final tour = tours.firstWhere((t) => t.id == tourId);
    final locations = tour.locations;
    locations.sort((a, b) => a.order.compareTo(b.order));
    return locations;
  } catch (e) {
    // Return empty list if no tour matching the ID is found
    return [];
  }
});

// Provider for categories (repurposed tours)
final categoriesProvider = FutureProvider<List<Tour>>((ref) async {
  return ref.watch(tourProviderProvider.future);
});
