import '../entities/location_entity.dart';
import '../repository/location_repository.dart';

class GetLocations {
  final LocationRepository repository;

  GetLocations(this.repository);

  Future<List<LocationEntity>> call() {
    return repository.getAll();
  }
}