import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/member.dart';

class MemberRepository {
  final Database database;

  MemberRepository(this.database);

  Future<List<Member>> getAllMembers() async {
    final result = await database.query('members', orderBy: 'registration_date DESC');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMemberById(String id) async {
    final result = await database.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Member.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertMember(Member member) async {
    await database.insert('members', member.toMap());
  }

  Future<void> updateMember(Member member) async {
    await database.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(String id) async {
    await database.delete('members', where: 'id = ?', whereArgs: [id]);
  }
}

