import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required double lat,
    required double lng,
    required DateTime time,
  }) : super(lat: lat, lng: lng, time: time);

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'time': time.toIso8601String(),
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      lat: map['lat'],
      lng: map['lng'],
      time: DateTime.parse(map['time']),
    );
  }
}