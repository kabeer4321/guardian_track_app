import '../../domain/entities/location_entity.dart';
import '../../domain/repository/location_repository.dart';
import '../datasource/location_local_datasource.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource local;

  LocationRepositoryImpl(this.local);

  @override
  Future<void> save(LocationEntity location) {
    return local.save(
      LocationModel(
        lat: location.lat,
        lng: location.lng,
        time: location.time,
        sessionId: location.sessionId,
      ),
    );
  }

  @override
  Future<List<LocationEntity>> getAll() {
    return local.getAll();
  }
}