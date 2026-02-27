import '../../domain/entities/location_entity.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<LocationEntity> locations;
  final bool isTracking;
  final String? message;

  LocationLoaded({
    required this.locations,
    required this.isTracking,
    this.message,
  });
}