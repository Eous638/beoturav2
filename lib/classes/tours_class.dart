import 'card_item.dart';
import 'loactions_class.dart';

class Tour extends CardItem {
  final List<Location> locations;

  Tour({
    required String title,
    required String description,
    required String imageUrl,
    required this.locations,
  }) : super(
          title: title,
          description: description,
          imageUrl: imageUrl,
        ) {
    locations.sort((a, b) => a.order.compareTo(b.order));
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      title: json['title'],
      description: json['description'],
      imageUrl: json['image'],
      locations: json['Place']
          .map<Location>((json) => Location.fromJson(json))
          .toList(),
    );
  }
}
