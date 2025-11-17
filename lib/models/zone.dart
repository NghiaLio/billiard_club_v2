class Zone {
  final String id;
  final String name;
  final String? description;
  final int sortOrder; // For custom ordering
  final bool isActive;
  final DateTime createdAt;

  Zone({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      sortOrder: map['sort_order'] ?? 0,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Zone copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

