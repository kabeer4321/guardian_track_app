class LocationModel {
  final double lat;
  final double lng;
  final DateTime time;

  LocationModel({
    required this.lat,
    required this.lng,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'time': time.toIso8601String(),
    };
  }

  factory LocationModel.fromMap(Map map) {
    return LocationModel(
      lat: map['lat'],
      lng: map['lng'],
      time: DateTime.parse(map['time']),
    );
  }
}