class Category {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Default categories
class DefaultCategories {
  static List<Map<String, String>> get categories => [
        {'name': 'Fruit', 'icon': '🍎', 'color': 'FFE57373'},
        {'name': 'Vegetable', 'icon': '🥕', 'color': 'FF81C784'},
        {'name': 'Meat', 'icon': '🥩', 'color': 'FFF06292'},
        {'name': 'Dairy', 'icon': '🧀', 'color': 'FFFFD54F'},
        {'name': 'Bakery', 'icon': '🍞', 'color': 'FFFFB74D'},
        {'name': 'Drinkable', 'icon': '🥤', 'color': 'FF64B5F6'},
        {'name': 'Fast Food', 'icon': '🍔', 'color': 'FFFF8A65'},
        {'name': 'Packed Food', 'icon': '📦', 'color': 'FFA1887F'},
        {'name': 'Herbs and Spices', 'icon': '🌿', 'color': 'FF4DB6AC'},
        {'name': 'Document', 'icon': '📄', 'color': 'FF90A4AE'},
        {'name': 'Subscription', 'icon': '📰', 'color': 'FFBA68C8'},
      ];
}