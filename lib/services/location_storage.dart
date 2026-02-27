import '../models/location_model.dart';
import 'database_service.dart';

class LocationStorage {

  static Future<void> save(LocationModel location) async {
    final db = await DatabaseService.database;

    await db.insert(
      'locations',
      location.toMap(),
    );
  }

  static Future<List<LocationModel>> getAll() async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'locations',
      orderBy: 'id ASC',
    );

    return result
        .map((e) => LocationModel.fromMap(e))
        .toList();
  }

  static Future<void> clear() async {
    final db = await DatabaseService.database;
    await db.delete('locations');
  }
}