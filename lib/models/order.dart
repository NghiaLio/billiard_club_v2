class Order {
  final String id;
  final String tableId;
  final String? sessionId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'cancelled'

  Order({
    required this.id,
    required this.tableId,
    this.sessionId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_id': tableId,
      'session_id': sessionId,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return Order(
      id: map['id'],
      tableId: map['table_id'],
      sessionId: map['session_id'],
      items: items,
      totalAmount: map['total_amount'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'pending',
    );
  }

  Order copyWith({
    String? id,
    String? tableId,
    String? sessionId,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? createdAt,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      sessionId: sessionId ?? this.sessionId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? category;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.category,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      category: map['category'],
      price: map['price'],
      quantity: map['quantity'],
      subtotal: map['subtotal'],
    );
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    String? category,
    double? price,
    int? quantity,
    double? subtotal,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
