// ignore_for_file: non_constant_identifier_names

abstract class CardItem {
  final String title;
  final String title_en;
  final String imageUrl;
  final String description;
  final String description_en;

  CardItem({
    required this.title,
    required this.title_en,
    required this.imageUrl,
    required this.description,
    required this.description_en,
  });
}
