import 'package:flutter/material.dart';
import '../models/item_model.dart';

// Daftar warna soft ala Google Keep
final Map<String, Color> keepColors = {
  'Putih': Colors.white,
  'Merah': const Color(0xfff28b82),
  'Oranye': const Color(0xfffbbc04),
  'Kuning': const Color(0xfffff475),
  'Hijau': const Color(0xffccff90),
  'Biru': const Color(0xffcbf0f8),
  'Ungu': const Color(0xffd7aefb),
};

class ItemCard extends StatelessWidget {
  final GroceryItem item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {

    
    // Hitung sisa hari
    final daysLeft = item.expiryDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      color: Color(item.colorValue), // Warna kartu dinamis
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(item.category, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysLeft < 3 ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$daysLeft Hari Lagi",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: daysLeft < 3 ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}