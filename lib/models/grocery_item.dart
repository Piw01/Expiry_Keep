class GroceryItem {
  final int id;
  final String name;
  final DateTime expiryDate;

  GroceryItem({
    required this.id,
    required this.name,
    required this.expiryDate,
  });

  // Mengubah data JSON dari Supabase jadi Object Dart
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiry_date']),
    );
  }

  // Menghitung sisa hari
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }
}