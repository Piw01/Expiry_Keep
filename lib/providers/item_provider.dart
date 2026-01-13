import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';

final supabase = Supabase.instance.client;

// 1. Provider untuk ambil data
final itemsProvider = FutureProvider<List<GroceryItem>>((ref) async {
  final response = await supabase
      .from('items')
      .select()
      .order('expiry_date', ascending: true);
  
  final data = response as List<dynamic>;
  return data.map((item) => GroceryItem.fromJson(item)).toList();
});

// 2. Fungsi untuk Tambah Data ke Supabase
Future<void> addItem(WidgetRef ref, String name, DateTime date, String category, int color) async {
  try {
    await supabase.from('items').insert({
      'name': name,
      'expiry_date': date.toIso8601String(),
      'category': category,
      'color_value': color, // Kita simpan kode warna di sini
    });
    
    // Memberitahu aplikasi bahwa data berubah, tolong ambil data baru
    ref.invalidate(itemsProvider);
  } catch (e) {
    print("Error simpan data: $e");
  }
}