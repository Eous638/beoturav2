// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'card_item.dart';

class Location extends CardItem {
  @override
  final String id;
  final String icon;
  final double latitude;
  final double longitude;
  final int order;
  Location({
    required this.id,
    required super.title,
    // ignore: non_constant_identifier_names
    required super.title_en,
    required super.description,
    required super.description_en,
    required super.imageUrl,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.order,
  }) : super(
          id: id,
        );

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'],
      title: json['title'],
      title_en: json['title_en'],
      description: json['description'],
      description_en: json['description_en'],
      imageUrl: json['image'],
      icon: json['icon'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      order: json['ordering'],
    );
  }
}
