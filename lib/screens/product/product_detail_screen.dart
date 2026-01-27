import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../providers/providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late TextEditingController _nameController;
  late DateTime _manufacturedDate;
  late DateTime _expiryDate;
  late int _remindBeforeDays;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _manufacturedDate = widget.product.manufacturedDate;
    _expiryDate = widget.product.expiryDate;
    _remindBeforeDays = widget.product.remindBeforeDays;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(productServiceProvider);
      await service.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        manufacturedDate: _manufacturedDate,
        expiryDate: _expiryDate,
        remindBeforeDays: _remindBeforeDays,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        ref.invalidate(productsProvider);
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

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batalkan'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(productServiceProvider);
      await service.deleteProduct(widget.product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil dihapus!'),
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
          if (_expiryDate.isBefore(_manufacturedDate)) {
            _expiryDate = _manufacturedDate.add(const Duration(days: 1));
          }
        } else {
          _expiryDate = date;
        }
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Produk',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _handleDelete,
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _handleUpdate,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'SIMPAN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
        ],
      ),
      body: ListView(
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
            child: _isEditing
                ? TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: InputBorder.none,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Produk',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // Category
          categoriesAsync.when(
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
            data: (categories) {
              final category = categories.firstWhere(
                (cat) => cat.id == widget.product.categoryId,
                orElse: () => categories.first,
              );

              return Container(
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
                child: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
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
                _buildDateRow(
                  'Diproduksi',
                  _manufacturedDate,
                  _isEditing ? () => _selectDate(context, true) : null,
                ),
                const Divider(height: 24),
                _buildDateRow(
                  'Kadaluwarsa',
                  _expiryDate,
                  _isEditing ? () => _selectDate(context, false) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status
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
                Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      widget.product.isExpired
                          ? Icons.cancel
                          : widget.product.isExpiringSoon
                              ? Icons.warning
                              : Icons.check_circle,
                      color: widget.product.isExpired
                          ? Colors.red
                          : widget.product.isExpiringSoon
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.product.isExpired
                          ? 'Kadaluwarsa'
                          : widget.product.isExpiringSoon
                              ? 'Akan segera kedaluwarsa (${widget.product.daysUntilExpiry} Hari lagi)'
                              : 'Fresh (${widget.product.daysUntilExpiry} Hari lagi)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reminder
          if (_isEditing)
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
                              ? 'Tidak ada pengingat'
                              : '$_remindBeforeDays Hari${_remindBeforeDays > 1 ? 's' : ''}',
                          onChanged: (value) {
                            setState(() {
                              _remindBeforeDays = value.toInt();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _remindBeforeDays == 0
                            ? 'Off'
                            : '$_remindBeforeDays Hari${_remindBeforeDays > 1 ? 's' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
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
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}