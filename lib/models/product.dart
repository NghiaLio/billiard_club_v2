class Product {
  final String id;
  final String name;
  final String category; // 'food', 'drink', 'equipment', 'other'
  final double price;
  final int stockQuantity;
  final String? unit; // 'piece', 'bottle', 'can', etc.
  final String? description;
  final bool isAvailable;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockQuantity,
    this.unit,
    this.description,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock_quantity': stockQuantity,
      'unit': unit,
      'description': description,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      stockQuantity: map['stock_quantity'],
      unit: map['unit'],
      description: map['description'],
      isAvailable: map['is_available'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stockQuantity,
    String? unit,
    String? description,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

