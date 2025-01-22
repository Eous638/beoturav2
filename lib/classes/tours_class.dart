// ignore_for_file: non_constant_identifier_names

import 'card_item.dart';
import 'loactions_class.dart';

class Tour extends CardItem {
  final List<Location> locations;

  Tour({
    required String id,
    required String title,
    required String title_en,
    required String description,
    required String description_en,
    required String imageUrl,
    required this.locations,
  }) : super(
          id: id,
          title: title,
          title_en: title_en,
          description: description,
          description_en: description_en,
          imageUrl: imageUrl,
        ) {
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
