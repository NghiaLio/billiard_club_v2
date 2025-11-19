import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/zone.dart';

class ZoneRepository {
  final Database database;

  ZoneRepository(this.database);

  Future<List<Zone>> getAllZones() async {
    final result = await database.query('zones', orderBy: 'sort_order ASC');
    return result.map((map) => Zone.fromMap(map)).toList();
  }

  Future<List<Zone>> getActiveZones() async {
    final result = await database.query(
      'zones',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );
    return result.map((map) => Zone.fromMap(map)).toList();
  }

  Future<Zone?> getZoneById(String id) async {
    final result = await database.query('zones', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Zone.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertZone(Zone zone) async {
    await database.insert('zones', zone.toMap());
  }

  Future<void> updateZone(Zone zone) async {
    await database.update(
      'zones',
      zone.toMap(),
      where: 'id = ?',
      whereArgs: [zone.id],
    );
  }

  Future<void> deleteZone(String id) async {
    await database.delete('zones', where: 'id = ?', whereArgs: [id]);
  }
}

