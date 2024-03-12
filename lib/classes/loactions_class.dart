import 'card_item.dart';

class Location extends CardItem {
  final String icon;
  final double latitude;
  final double longitude;
  final int order;
  Location({
    required String title,
    required String description,
    required String imageUrl,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.order,
  }) : super(
          title: title,
          description: description,
          imageUrl: imageUrl,
        );

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      title: json['title'],
      description: json['description'],
      imageUrl: json['image'],
      icon: json['icon'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      order: json['ordering'],
    );
  }
}
