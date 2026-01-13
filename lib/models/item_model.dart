class GroceryItem {
  final int id;
  final String name;
  final DateTime expiryDate;
  final String category;
  final int colorValue;

  GroceryItem({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.category,
    required this.colorValue,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiry_date']),
      category: json['category'] ?? 'Lainnya',
      colorValue: json['color_value'] ?? 0xFFFFFFFF, // Default Putih
    );
  }
}