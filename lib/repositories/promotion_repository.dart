import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/promotion.dart';

class PromotionRepository {
  final Database database;

  PromotionRepository(this.database);

  Future<List<Promotion>> getAllPromotions() async {
    final result = await database.query('promotions', orderBy: 'priority DESC, created_at DESC');
    return result.map((map) => Promotion.fromMap(map)).toList();
  }

  Future<List<Promotion>> getActivePromotions() async {
    final result = await database.query(
      'promotions',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'priority DESC, created_at DESC',
    );
    return result.map((map) => Promotion.fromMap(map)).toList();
  }

  Future<Promotion?> getPromotionById(String id) async {
    final result = await database.query('promotions', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Promotion.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertPromotion(Promotion promotion) async {
    await database.insert('promotions', promotion.toMap());
  }

  Future<void> updatePromotion(Promotion promotion) async {
    await database.update(
      'promotions',
      promotion.toMap(),
      where: 'id = ?',
      whereArgs: [promotion.id],
    );
  }

  Future<void> deletePromotion(String id) async {
    await database.delete('promotions', where: 'id = ?', whereArgs: [id]);
  }
}

