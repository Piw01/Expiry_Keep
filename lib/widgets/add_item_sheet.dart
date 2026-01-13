import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';

class AddItemSheet extends StatefulWidget {
  final WidgetRef ref;
  const AddItemSheet({super.key, required this.ref});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final nameController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  String selectedCategory = 'Makanan';
  int selectedColor = 0xFFFFFFFF; // Putih Default

  // Daftar warna soft ala Google Keep
  final List<int> keepColors = [
    0xFFFFFFFF, // Putih
    0xFFF28B82, // Merah Muda
    0xFFFBBC04, // Oranye
    0xFFFFF475, // Kuning
    0xFFCCFF90, // Hijau
    0xFFAECBFA, // Biru
    0xFFD7AEFB, // Ungu
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: "Nama Barang", border: InputBorder.none),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 20),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedCategory,
                underline: const SizedBox(),
                items: ['Makanan', 'Minuman', 'Obat', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                onPressed: () async {
                  final p = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (p != null) setState(() => selectedDate = p);
                },
              )
            ],
          ),
          const SizedBox(height: 15),
          // PILIHAN WARNA ALA GOOGLE KEEP
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: keepColors.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => selectedColor = keepColors[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 35,
                  decoration: BoxDecoration(
                    color: Color(keepColors[i]),
                    shape: BoxShape.circle,
                    border: Border.all(color: selectedColor == keepColors[i] ? Colors.blue : Colors.grey.shade300, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  addItem(widget.ref, nameController.text, selectedDate, selectedCategory, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan Barang"),
            ),
          ),
        ],
      ),
    );
  }
}