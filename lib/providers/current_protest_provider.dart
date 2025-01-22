import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final currentProtestProvider = FutureProvider<Protest>((ref) async {
  final response = await Dio().get('https://api2.gladni.rs/api/beotura/current_protest');
  return Protest.fromJson(response.data);
});

class Protest {
  final String id;
  final String title;
  final String about;
  final DateTime time;
  final String locationName;
  final Coordinates coordinates;
  final int attendance;
  final String status;

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
}
