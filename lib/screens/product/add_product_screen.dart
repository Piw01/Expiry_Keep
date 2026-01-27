import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/category_model.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedCategoryId;
  DateTime _manufacturedDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  int _remindBeforeDays = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isManufactured) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isManufactured ? _manufacturedDate : _expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isManufactured) {
          _manufacturedDate = date;
          // Ensure expiry is after manufactured
          if (_expiryDate.isBefore(_manufacturedDate)) {
            _expiryDate = _manufacturedDate.add(const Duration(days: 1));
          }
        } else {
          _expiryDate = date;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(productServiceProvider);
      await service.addProduct(
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        manufacturedDate: _manufacturedDate,
        expiryDate: _expiryDate,
        remindBeforeDays: _remindBeforeDays,
      );

      if (mounted) {
        // Invalidate products to refresh the list
        ref.invalidate(productsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'SIMPAN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: InputBorder.none,
                  hintText: 'e.g., Susu Segar',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Silakan masukkan nama produk';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error saat memuat kategori: ${error.toString()}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Tidak ada kategori tersedia. Silakan hubungi pusat bantuan.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((category) {
                          final isSelected = _selectedCategoryId == category.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: _buildCategoryChip(category, isSelected),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dates
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDateField(
                    'Tanggal Produksi',
                    _manufacturedDate,
                    () => _selectDate(context, true),
                  ),
                  const Divider(height: 24),
                  _buildDateField(
                    'Tanggal Kadaluarsa',
                    _expiryDate,
                    () => _selectDate(context, false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingatkan saya sebelum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _remindBeforeDays.toDouble(),
                          min: 0,
                          max: 7,
                          divisions: 7,
                          label: _remindBeforeDays == 0
                              ? 'No reminder'
                              : '$_remindBeforeDays Hari${_remindBeforeDays > 1 ? 's' : ''}',
                          onChanged: (value) {
                            setState(() {
                              _remindBeforeDays = value.toInt();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: Text(
                          _remindBeforeDays == 0
                              ? 'Off'
                              : '$_remindBeforeDays hari${_remindBeforeDays > 1 ? 's' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Category category, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(int.parse('FF${category.color}', radix: 16))
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? Color(int.parse('FF${category.color}', radix: 16))
              : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}