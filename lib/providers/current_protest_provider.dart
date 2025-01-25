import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final currentProtestProvider = FutureProvider<Protest>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final storedProtest = prefs.getString('current_protest');

  try {
    final response =
        await Dio().get('https://api2.gladni.rs/api/beotura/current_protest');
    final protest = Protest.fromJson(response.data);

    await prefs.setString('current_protest', jsonEncode(protest.toJson()));

    return protest;
  } catch (e) {
    debugPrint('Failed to fetch latest protest data: $e');
    if (storedProtest != null) {
      final protest = Protest.fromJson(jsonDecode(storedProtest));
      if (protest.time.isBefore(DateTime.now())) {
        protest.status = 'active';
      }
      return protest;
    } else {
      throw Exception(
          'No internet connection and no stored protest data available');
    }
  }
});

class Protest {
  final String id;
  final String title;
  final String about;
  final DateTime time;
  final String locationName;
  final Coordinates coordinates;
  int attendance;
  String status;

  Protest({
    required this.id,
    required this.title,
    required this.about,
    required this.time,
    required this.locationName,
    required this.coordinates,
    required this.attendance,
    required this.status,
  });

  factory Protest.fromJson(Map<String, dynamic> json) {
    return Protest(
      id: json['_id'],
      title: json['title'],
      about: json['about'],
      time: DateTime.parse(json['time']),
      locationName: json['location_name'],
      coordinates: Coordinates.fromJson(json['coordinates']),
      attendance: json['attendance'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'about': about,
      'time': time.toIso8601String(),
      'location_name': locationName,
      'coordinates': coordinates.toJson(),
      'attendance': attendance,
      'status': status,
    };
  }
}

class Coordinates {
  final double lat;
  final double lon;

  Coordinates({required this.lat, required this.lon});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: json['lat'],
      lon: json['lon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}
