import 'package:flutter/material.dart';

import '../classes/tours_class.dart';
import '../classes/loactions_class.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'tour_provider.g.dart';

@riverpod
Future<List<Tour>> tourProvider(TourProviderRef ref) async {
  final response =
      await http.get(Uri.parse('https://api2.gladni.rs/api/beotura/tours'));
  ref.keepAlive();

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data.map<Tour>((json) => Tour.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch tours: ${response.statusCode}');
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
          data.map<Location>((json) => Location.fromJson(json)).toList();

      return fetchedTours;
    } else {
      throw Exception('Failed to fetch tours: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching locations: $e');
    rethrow;
  }
}
