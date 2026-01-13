import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/item_provider.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/item_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);

return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4), // Background abu terang ala Google
      appBar: AppBar(
        title: const Text("FreshKeep", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.black54),
            onPressed: () {}, // Nanti bisa buat fitur ganti layout
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => items.isEmpty 
          ? const Center(child: Text("Belum ada barang di kulkas"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom ala Google Keep
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9, // Mengatur tinggi kotak
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => ItemCard(item: items[index]),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue, size: 32),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => AddItemSheet(ref: ref),
          );
        },
      ),
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  String selectedCategory = 'Makanan';
  // Daftar warna soft ala Google Keep
  int selectedColor = 0xFFFFFFFF; // Putih

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tambah Barang Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Nama Barang (Susu, Daging, dll)", border: InputBorder.none),
          ),
          const Divider(),
          // Pilih Kategori & Tanggal
          Row(
            children: [
              ActionChip(
                label: const Text("Pilih Tanggal"),
                avatar: const Icon(Icons.calendar_month, size: 16),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) selectedDate = picked;
                },
              ),
              const SizedBox(width: 10),
              // Dropdown Kategori Sederhana
              DropdownButton<String>(
                value: selectedCategory,
                items: <String>['Makanan', 'Minuman', 'Obat', 'Lainnya'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => selectedCategory = val!,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Panggil fungsi addItem dari provider
                  addItem(ref, nameController.text, selectedDate, selectedCategory, selectedColor);
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Simpan ke Kulkas"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  }
}