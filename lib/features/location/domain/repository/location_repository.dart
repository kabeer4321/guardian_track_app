import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<void> save(LocationEntity location);
  Future<List<LocationEntity>> getAll();
}