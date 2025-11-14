class Invoice {
  final String id;
  final String tableId;
  final String tableName;
  final String? memberId;
  final String? memberName;
  final DateTime startTime;
  final DateTime endTime;
  final double playingHours;
  final double tableCharge;
  final double orderTotal;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String paymentMethod; // 'cash', 'card', 'online', 'member_account'
  final String status; // 'paid', 'pending', 'cancelled'
  final DateTime createdAt;
  final String createdBy;

  Invoice({
    required this.id,
    required this.tableId,
    required this.tableName,
    this.memberId,
    this.memberName,
    required this.startTime,
    required this.endTime,
    required this.playingHours,
    required this.tableCharge,
    required this.orderTotal,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.totalAmount,
    required this.paymentMethod,
    this.status = 'paid',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_id': tableId,
      'table_name': tableName,
      'member_id': memberId,
      'member_name': memberName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'playing_hours': playingHours,
      'table_charge': tableCharge,
      'order_total': orderTotal,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      tableId: map['table_id'],
      tableName: map['table_name'],
      memberId: map['member_id'],
      memberName: map['member_name'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      playingHours: map['playing_hours'],
      tableCharge: map['table_charge'],
      orderTotal: map['order_total'],
      subtotal: map['subtotal'],
      discount: map['discount'] ?? 0,
      tax: map['tax'] ?? 0,
      totalAmount: map['total_amount'],
      paymentMethod: map['payment_method'],
      status: map['status'] ?? 'paid',
      createdAt: DateTime.parse(map['created_at']),
      createdBy: map['created_by'],
    );
  }

  Invoice copyWith({
    String? id,
    String? tableId,
    String? tableName,
    String? memberId,
    String? memberName,
    DateTime? startTime,
    DateTime? endTime,
    double? playingHours,
    double? tableCharge,
    double? orderTotal,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Invoice(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      playingHours: playingHours ?? this.playingHours,
      tableCharge: tableCharge ?? this.tableCharge,
      orderTotal: orderTotal ?? this.orderTotal,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

