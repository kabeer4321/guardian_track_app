class LocationEntity {
  final double lat;
  final double lng;
  final DateTime time;
  final String sessionId;

  LocationEntity({
    required this.lat,
    required this.lng,
    required this.time,
    required this.sessionId,
  });
}