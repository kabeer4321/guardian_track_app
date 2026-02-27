import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required super.lat,
    required super.lng,
    required super.time,
    required super.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'time': time.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      lat: map['lat'],
      lng: map['lng'],
      time: DateTime.parse(map['time']),
      sessionId: map['sessionId'],
    );
  }
}