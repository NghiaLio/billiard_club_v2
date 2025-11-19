import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user.dart';

class UserRepository {
  final Database database;

  UserRepository(this.database);

  Future<User?> login(String username, String password) async {
    final result = await database.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final result = await database.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<void> insertUser(User user) async {
    await database.insert('users', user.toMap());
  }

  Future<void> updateUser(User user) async {
    await database.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    await database.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}

