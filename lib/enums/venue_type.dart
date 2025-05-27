enum VenueType {
  BAR,
  RESTAURANT,
  CAFE,
  MUSEUM,
  HISTORICAL_SITE,
  SHOP,
  GALLERY,
  LANDMARK,
  OTHER;

  String get displayName {
    switch (this) {
      case VenueType.BAR:
        return 'Bar';
      case VenueType.RESTAURANT:
        return 'Restaurant';
      case VenueType.CAFE:
        return 'Cafe';
      case VenueType.MUSEUM:
        return 'Museum';
      case VenueType.HISTORICAL_SITE:
        return 'Historical Site';
      case VenueType.SHOP:
        return 'Shop';
      case VenueType.GALLERY:
        return 'Gallery';
      case VenueType.LANDMARK:
        return 'Landmark';
      case VenueType.OTHER:
        return 'Other';
      default:
        return name;
    }
  }
}
