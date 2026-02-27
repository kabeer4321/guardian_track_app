class LocationEntity {
  final String lat;
  final String lng;
  final DateTime time;
  final String sessionId;
  final String status;

  LocationEntity({
    required this.lat,
    required this.lng,
    required this.time,
    required this.sessionId,
    required this.status
  });
}