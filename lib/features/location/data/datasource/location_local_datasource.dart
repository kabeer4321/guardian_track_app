import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/location_model.dart';

class LocationLocalDataSource {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'locations.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lat REAL,
            lng REAL,
            time TEXT,
            sessionId TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  Future<void> save(LocationModel model) async {
    final db = await database;
    await db.insert('locations', model.toMap());
  }

  Future<List<LocationModel>> getAll() async {
    final db = await database;
    final result = await db.query('locations', orderBy: 'id ASC');
    return result.map((e) => LocationModel.fromMap(e)).toList();
  }
}