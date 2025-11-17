class Promotion {
  final String id;
  final String name;
  final String description;
  
  // Promotion type: 'fixed_price', 'percentage', 'buy_x_get_y'
  final String type;
  
  // Discount value (depends on type)
  final double value; // Fixed price or percentage value
  
  // Applicable conditions
  final List<String>? applicableTableTypes; // null = all types
  final List<String>? applicableZones; // null = all zones
  final String? applicableMembershipType; // null = all, or specific type
  
  // Time conditions
  final String? dayOfWeek; // null = all days, or 'monday', 'tuesday', etc.
  final String? startTime; // HH:mm format, e.g., "14:00"
  final String? endTime; // HH:mm format, e.g., "18:00"
  
  // Date range
  final DateTime? validFrom;
  final DateTime? validTo;
  
  // Minimum conditions
  final double? minAmount; // Minimum order amount
  final double? minPlayingHours; // Minimum playing hours
  
  // Status
  final bool isActive;
  final int priority; // Higher priority promotions apply first
  
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.applicableTableTypes,
    this.applicableZones,
    this.applicableMembershipType,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.validFrom,
    this.validTo,
    this.minAmount,
    this.minPlayingHours,
    this.isActive = true,
    this.priority = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'applicable_table_types': applicableTableTypes?.join(','),
      'applicable_zones': applicableZones?.join(','),
      'applicable_membership_type': applicableMembershipType,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
      'min_amount': minAmount,
      'min_playing_hours': minPlayingHours,
      'is_active': isActive ? 1 : 0,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      value: map['value'],
      applicableTableTypes: map['applicable_table_types'] != null
          ? (map['applicable_table_types'] as String).split(',')
          : null,
      applicableZones: map['applicable_zones'] != null
          ? (map['applicable_zones'] as String).split(',')
          : null,
      applicableMembershipType: map['applicable_membership_type'],
      dayOfWeek: map['day_of_week'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      validFrom: map['valid_from'] != null
          ? DateTime.parse(map['valid_from'])
          : null,
      validTo: map['valid_to'] != null ? DateTime.parse(map['valid_to']) : null,
      minAmount: map['min_amount'],
      minPlayingHours: map['min_playing_hours'],
      isActive: (map['is_active'] ?? 1) == 1,
      priority: map['priority'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Promotion copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    double? value,
    List<String>? applicableTableTypes,
    List<String>? applicableZones,
    String? applicableMembershipType,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    DateTime? validFrom,
    DateTime? validTo,
    double? minAmount,
    double? minPlayingHours,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      applicableTableTypes: applicableTableTypes ?? this.applicableTableTypes,
      applicableZones: applicableZones ?? this.applicableZones,
      applicableMembershipType:
          applicableMembershipType ?? this.applicableMembershipType,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      minAmount: minAmount ?? this.minAmount,
      minPlayingHours: minPlayingHours ?? this.minPlayingHours,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if promotion is applicable
  bool isApplicable({
    String? tableType,
    String? zone,
    String? membershipType,
    required double amount,
    required double playingHours,
    required DateTime checkTime,
  }) {
    // Check if active
    if (!isActive) return false;

    // Check date range
    if (validFrom != null && checkTime.isBefore(validFrom!)) return false;
    if (validTo != null && checkTime.isAfter(validTo!)) return false;

    // Check day of week
    if (dayOfWeek != null) {
      final currentDay = _getDayOfWeek(checkTime.weekday);
      if (currentDay != dayOfWeek) return false;
    }

    // Check time range
    if (startTime != null && endTime != null) {
      final currentTime = '${checkTime.hour.toString().padLeft(2, '0')}:${checkTime.minute.toString().padLeft(2, '0')}';
      if (currentTime.compareTo(startTime!) < 0 ||
          currentTime.compareTo(endTime!) > 0) {
        return false;
      }
    }

    // Check table type
    if (applicableTableTypes != null && tableType != null &&
        !applicableTableTypes!.contains(tableType)) {
      return false;
    }

    // Check zone
    if (applicableZones != null && zone != null && 
        !applicableZones!.contains(zone)) {
      return false;
    }

    // Check membership type
    if (applicableMembershipType != null &&
        applicableMembershipType != membershipType) {
      return false;
    }

    // Check minimum amount
    if (minAmount != null && amount < minAmount!) return false;

    // Check minimum playing hours
    if (minPlayingHours != null && playingHours < minPlayingHours!) {
      return false;
    }

    return true;
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  // Calculate discount amount
  double calculateDiscount(double originalAmount) {
    switch (type) {
      case 'fixed_price':
        return originalAmount - value;
      case 'percentage':
        return originalAmount * (value / 100);
      default:
        return 0;
    }
  }
}

