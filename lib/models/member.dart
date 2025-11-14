class Member {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final DateTime registrationDate;
  final String membershipType; // 'standard', 'silver', 'gold', 'platinum'
  final double discountRate; // Discount percentage
  final bool isActive;
  final DateTime? expiryDate;

  Member({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    required this.registrationDate,
    this.membershipType = 'standard',
    this.discountRate = 0,
    this.isActive = true,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'registration_date': registrationDate.toIso8601String(),
      'membership_type': membershipType,
      'discount_rate': discountRate,
      'is_active': isActive ? 1 : 0,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      fullName: map['full_name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      registrationDate: DateTime.parse(map['registration_date']),
      membershipType: map['membership_type'] ?? 'standard',
      discountRate: map['discount_rate'] ?? 0,
      isActive: map['is_active'] == 1,
      expiryDate:
          map['expiry_date'] != null ? DateTime.parse(map['expiry_date']) : null,
    );
  }

  Member copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? address,
    DateTime? registrationDate,
    String? membershipType,
    double? discountRate,
    bool? isActive,
    DateTime? expiryDate,
  }) {
    return Member(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      registrationDate: registrationDate ?? this.registrationDate,
      membershipType: membershipType ?? this.membershipType,
      discountRate: discountRate ?? this.discountRate,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

