import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/order.dart';

class OrderRepository {
  final Database database;

  OrderRepository(this.database);

  Future<void> insertOrder(Order order) async {
    await database.insert('orders', order.toMap());

    for (var item in order.items) {
      await database.insert('order_items', item.toMap());
    }
  }

  Future<List<Order>> getOrdersByTableId(String tableId) async {
    final orderMaps = await database.query(
      'orders',
      where: 'table_id = ? AND status = ?',
      whereArgs: [tableId, 'pending'],
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await _getOrderItems(orderMap['id'] as String);
      orders.add(Order.fromMap(orderMap, items));
    }

    return orders;
  }

  Future<List<OrderItem>> _getOrderItems(String orderId) async {
    final result = await database.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((map) => OrderItem.fromMap(map)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await database.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}

