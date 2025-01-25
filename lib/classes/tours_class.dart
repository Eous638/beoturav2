// ignore_for_file: non_constant_identifier_names

import 'card_item.dart';
import 'loactions_class.dart';

class Tour extends CardItem {
  final List<Location> locations;

  Tour({
    required super.id,
    required super.title,
    required super.title_en,
    required super.description,
    required super.description_en,
    required super.imageUrl,
    required this.locations,
  }) {
    locations.sort((a, b) => a.order.compareTo(b.order));
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['_id'],
      title: json['title'],
      title_en: json['title_en'],
      description: json['description'],
      description_en: json['description_en'],
      imageUrl: json['image'],
      locations: json['Place']
          .map<Location>((json) => Location.fromJson(json))
          .toList(),
    );
  }
}
