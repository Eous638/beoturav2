import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final blockadesProvider = FutureProvider<List<Blockade>>((ref) async {
  final response =
      await Dio().get('https://api2.gladni.rs/api/beotura/blockades');
  final List<dynamic> data = response.data;
  return data.map((json) => Blockade.fromJson(json)).toList();
});

class Blockade {
  final String id;
  final String universityName;
  final String status;
  final String generalInformation;
  final Coordinates coordinates;
  final List<Update> updates;
  final List<Supply> supplies;

  Blockade({
    required this.id,
    required this.universityName,
    required this.status,
    required this.generalInformation,
    required this.coordinates,
    required this.updates,
    required this.supplies,
  });

  factory Blockade.fromJson(Map<String, dynamic> json) {
    return Blockade(
      id: json['_id'],
      universityName: json['university_name'],
      status: json['status'],
      generalInformation: json['general_information'],
      coordinates: Coordinates.fromJson(json['coordinates']),
      updates: (json['updates'] as List<dynamic>?)
              ?.map((update) => Update.fromJson(update))
              .toList() ??
          [],
      supplies: (json['supplies'] as List<dynamic>?)
              ?.map((supply) => Supply.fromJson(supply))
              .toList() ??
          [],
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

class Update {
  final String id;
  final String title;
  final String text;
  final DateTime date;

  Update(
      {required this.id,
      required this.title,
      required this.text,
      required this.date});

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      id: json['_id'],
      title: json['title'],
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}

class Supply {
  final String name;
  final int quantity;
  final String id;

  Supply({required this.name, required this.quantity, required this.id});

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      name: json['name'],
      quantity: json['quantity'],
      id: json['_id'],
    );
  }
}
