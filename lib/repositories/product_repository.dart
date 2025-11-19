import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/product.dart';

class ProductRepository {
  final Database database;

  ProductRepository(this.database);

  Future<List<Product>> getAllProducts() async {
    final result = await database.query('products', orderBy: 'name');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final result = await database.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertProduct(Product product) async {
    await database.insert('products', product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await database.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    await database.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

