import 'package:equatable/equatable.dart';
import '../../models/order.dart';

class OrderState extends Equatable {
  final Map<String, List<OrderItem>> currentOrders;

  const OrderState({this.currentOrders = const {}});

  List<OrderItem>? getOrderItemsForTable(String tableId) {
    return currentOrders[tableId];
  }

  double getOrderTotalForTable(String tableId) {
    final items = currentOrders[tableId];
    if (items == null || items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  @override
  List<Object?> get props => [currentOrders];

  OrderState copyWith({
    Map<String, List<OrderItem>>? currentOrders,
  }) {
    return OrderState(
      currentOrders: currentOrders ?? this.currentOrders,
    );
  }
}

