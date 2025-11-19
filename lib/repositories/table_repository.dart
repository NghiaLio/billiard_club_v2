import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/billiard_table.dart';

class TableRepository {
  final Database database;

  TableRepository(this.database);

  Future<List<BilliardTable>> getAllTables() async {
    final result = await database.query('billiard_tables', orderBy: 'table_name');
    return result.map((map) => BilliardTable.fromMap(map)).toList();
  }

  Future<BilliardTable?> getTableById(String id) async {
    final result = await database.query('billiard_tables', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return BilliardTable.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertTable(BilliardTable table) async {
    await database.insert('billiard_tables', table.toMap());
  }

  Future<void> updateTable(BilliardTable table) async {
    await database.update(
      'billiard_tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  Future<void> deleteTable(String id) async {
    await database.delete('billiard_tables', where: 'id = ?', whereArgs: [id]);
  }
}

