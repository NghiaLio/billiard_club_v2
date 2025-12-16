import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderState());

  void addItemToOrder(String tableId, Product product, int quantity) {
    // Deep copy the map and lists
    final currentOrders = <String, List<OrderItem>>{};
    state.currentOrders.forEach((key, value) {
      currentOrders[key] = List<OrderItem>.from(value);
    });

    if (!currentOrders.containsKey(tableId)) {
      currentOrders[tableId] = [];
    }

    final existingItemIndex = currentOrders[tableId]!.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingItemIndex >= 0) {
      // Update existing item
      final existingItem = currentOrders[tableId]![existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      currentOrders[tableId]![existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
        subtotal: newQuantity * product.price,
      );
    } else {
      // Add new item
      final orderItem = OrderItem(
        id: const Uuid().v4(),
        orderId: '', // Will be set when order is saved
        productId: product.id,
        productName: product.name,
        category: product.category,
        price: product.price,
        quantity: quantity,
        subtotal: product.price * quantity,
      );
      currentOrders[tableId]!.add(orderItem);
    }

    emit(state.copyWith(currentOrders: currentOrders));
  }

  void removeItemFromOrder(String tableId, String itemId) {
    // Deep copy the map and lists
    final currentOrders = <String, List<OrderItem>>{};
    state.currentOrders.forEach((key, value) {
      currentOrders[key] = List<OrderItem>.from(value);
    });

    if (currentOrders.containsKey(tableId)) {
      currentOrders[tableId]!.removeWhere((item) => item.id == itemId);
      emit(state.copyWith(currentOrders: currentOrders));
    }
  }

  void updateItemQuantity(String tableId, String itemId, int newQuantity) {
    // Deep copy the map and lists
    final currentOrders = <String, List<OrderItem>>{};
    state.currentOrders.forEach((key, value) {
      currentOrders[key] = List<OrderItem>.from(value);
    });

    if (currentOrders.containsKey(tableId)) {
      final itemIndex = currentOrders[tableId]!.indexWhere(
        (item) => item.id == itemId,
      );

      if (itemIndex >= 0) {
        final item = currentOrders[tableId]![itemIndex];
        if (newQuantity <= 0) {
          currentOrders[tableId]!.removeAt(itemIndex);
        } else {
          currentOrders[tableId]![itemIndex] = item.copyWith(
            quantity: newQuantity,
            subtotal: newQuantity * item.price,
          );
        }
        emit(state.copyWith(currentOrders: currentOrders));
      }
    }
  }

  Future<void> saveOrder(String tableId, String sessionId) async {
    if (!state.currentOrders.containsKey(tableId) ||
        state.currentOrders[tableId]!.isEmpty) {
      return;
    }

    final orderId = const Uuid().v4();
    final items = state.currentOrders[tableId]!.map((item) {
      return item.copyWith(orderId: orderId);
    }).toList();

    final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);

    final order = Order(
      id: orderId,
      tableId: tableId,
      sessionId: sessionId,
      items: items,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    await DatabaseService.instance.insertOrder(order);
  }

  void clearOrderForTable(String tableId) {
    // Deep copy the map and lists
    final currentOrders = <String, List<OrderItem>>{};
    state.currentOrders.forEach((key, value) {
      currentOrders[key] = List<OrderItem>.from(value);
    });
    currentOrders.remove(tableId);
    emit(state.copyWith(currentOrders: currentOrders));
  }

  Future<List<Order>> loadOrdersForTable(String tableId) async {
    return await DatabaseService.instance.getOrdersByTableId(tableId);
  }
}
