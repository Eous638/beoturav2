// ignore_for_file: non_constant_identifier_names

abstract class CardItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;

  // Add support for localized fields
  final String? title_en;
  final String? title_sr;
  final String? description_en;
  final String? description_sr;

  CardItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.title_en,
    this.title_sr,
    this.description_en,
    this.description_sr,
  });
}
