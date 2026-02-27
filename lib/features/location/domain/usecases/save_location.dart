import '../entities/location_entity.dart';
import '../repository/location_repository.dart';

class SaveLocation {
  final LocationRepository repository;

  SaveLocation(this.repository);

  Future<void> call(LocationEntity location) {
    return repository.save(location);
  }
}