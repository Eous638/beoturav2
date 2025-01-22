class ProtestLocation {
  final double lat;
  final double lng;

  ProtestLocation({required this.lat, required this.lng});

  factory ProtestLocation.fromJson(Map<String, dynamic> json) {
    return ProtestLocation(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
