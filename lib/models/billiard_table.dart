class BilliardTable {
  final String id;
  final String tableName;
  final String tableType; // 'pool', 'snooker', 'carom'
  final double pricePerHour;
  final String status; // 'available', 'occupied', 'reserved', 'maintenance'
  final DateTime? startTime;
  final String? currentSessionId;
  final String? reservedBy; // Member ID or name
  final DateTime? reservationTime;

  BilliardTable({
    required this.id,
    required this.tableName,
    required this.tableType,
    required this.pricePerHour,
    this.status = 'available',
    this.startTime,
    this.currentSessionId,
    this.reservedBy,
    this.reservationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'table_type': tableType,
      'price_per_hour': pricePerHour,
      'status': status,
      'start_time': startTime?.toIso8601String(),
      'current_session_id': currentSessionId,
      'reserved_by': reservedBy,
      'reservation_time': reservationTime?.toIso8601String(),
    };
  }

  factory BilliardTable.fromMap(Map<String, dynamic> map) {
    return BilliardTable(
      id: map['id'],
      tableName: map['table_name'],
      tableType: map['table_type'],
      pricePerHour: map['price_per_hour'],
      status: map['status'] ?? 'available',
      startTime:
          map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      currentSessionId: map['current_session_id'],
      reservedBy: map['reserved_by'],
      reservationTime: map['reservation_time'] != null
          ? DateTime.parse(map['reservation_time'])
          : null,
    );
  }

  BilliardTable copyWith({
    String? id,
    String? tableName,
    String? tableType,
    double? pricePerHour,
    String? status,
    DateTime? startTime,
    String? currentSessionId,
    String? reservedBy,
    DateTime? reservationTime,
  }) {
    return BilliardTable(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      tableType: tableType ?? this.tableType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      reservedBy: reservedBy ?? this.reservedBy,
      reservationTime: reservationTime ?? this.reservationTime,
    );
  }

  // Calculate playing duration in hours
  double get playingDuration {
    if (startTime == null) return 0;
    final duration = DateTime.now().difference(startTime!);
    return duration.inMinutes / 60.0;
  }

  // Calculate current cost
  double get currentCost {
    return playingDuration * pricePerHour;
  }
}

