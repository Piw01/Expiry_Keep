class Product {
  final String id;
  final String userId;
  final String categoryId;
  final String name;
  final DateTime manufacturedDate;
  final DateTime expiryDate;
  final ProductStatus status;
  final int remindBeforeDays;
  final DateTime? reminderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.manufacturedDate,
    required this.expiryDate,
    required this.status,
    this.remindBeforeDays = 1,
    this.reminderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      manufacturedDate: DateTime.parse(json['manufactured_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      status: ProductStatus.fromString(json['status'] as String),
      remindBeforeDays: json['remind_before_days'] as int? ?? 1,
      reminderDate: json['reminder_date'] != null
          ? DateTime.parse(json['reminder_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'manufactured_date': manufacturedDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'status': status.value,
      'remind_before_days': remindBeforeDays,
      'reminder_date': reminderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Calculate days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  // Check if expired
  bool get isExpired => daysUntilExpiry < 0;

  // Check if expiring soon (within 7 days)
  bool get isExpiringSoon => daysUntilExpiry >= 0 && daysUntilExpiry <= 7;

  // Check if fresh (more than 7 days)
  bool get isFresh => daysUntilExpiry > 7;

  Product copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? name,
    DateTime? manufacturedDate,
    DateTime? expiryDate,
    ProductStatus? status,
    int? remindBeforeDays,
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      manufacturedDate: manufacturedDate ?? this.manufacturedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      remindBeforeDays: remindBeforeDays ?? this.remindBeforeDays,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ProductStatus {
  fresh('fresh'),
  expiringSoon('expiring_soon'),
  expired('expired');

  final String value;
  const ProductStatus(this.value);

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProductStatus.fresh,
    );
  }
}