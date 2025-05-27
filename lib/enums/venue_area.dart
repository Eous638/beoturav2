enum VenueArea {
  UPPER_DORCOL,
  TRG,
  KNEZ_MIHAILOVA,
  KALEMEGDAN,
  SKADARLIJA,
  DORCOL,
  SAVAMALA,
  VRACAR,
  NEW_BELGRADE,
  OTHER;

  String get displayName {
    switch (this) {
      case VenueArea.UPPER_DORCOL:
        return 'Upper Dorcol';
      case VenueArea.KNEZ_MIHAILOVA:
        return 'Knez Mihailova';
      case VenueArea.NEW_BELGRADE:
        return 'New Belgrade';
      // Add other cases as needed
      default:
        // Simple title case conversion for other values
        return name.replaceAll('_', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase()).join(' ');
    }
  }
}
