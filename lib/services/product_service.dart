import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase;

  ProductService(this._supabase);

  // Get all products for current user
  Future<List<Product>> getProducts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('products')
          .select()
          .eq('user_id', userId)
          .order('expiry_date', ascending: true);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Add new product
  Future<Product> addProduct({
    required String categoryId,
    required String name,
    required DateTime manufacturedDate,
    required DateTime expiryDate,
    int remindBeforeDays = 1,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Calculate status
      final now = DateTime.now();
      final daysUntilExpiry = expiryDate.difference(now).inDays;
      ProductStatus status;
      if (daysUntilExpiry < 0) {
        status = ProductStatus.expired;
      } else if (daysUntilExpiry <= 7) {
        status = ProductStatus.expiringSoon;
      } else {
        status = ProductStatus.fresh;
      }

      // Calculate reminder date
      DateTime? reminderDate;
      if (remindBeforeDays > 0) {
        reminderDate = expiryDate.subtract(Duration(days: remindBeforeDays));
      }

      final data = {
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        'manufactured_date': manufacturedDate.toIso8601String(),
        'expiry_date': expiryDate.toIso8601String(),
        'status': status.value,
        'remind_before_days': remindBeforeDays,
        'reminder_date': reminderDate?.toIso8601String(),
      };

      final response = await _supabase
          .from('products')
          .insert(data)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update product
  Future<Product> updateProduct({
    required String id,
    String? categoryId,
    String? name,
    DateTime? manufacturedDate,
    DateTime? expiryDate,
    int? remindBeforeDays,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (categoryId != null) data['category_id'] = categoryId;
      if (name != null) data['name'] = name;
      if (manufacturedDate != null) {
        data['manufactured_date'] = manufacturedDate.toIso8601String();
      }
      if (expiryDate != null) {
        data['expiry_date'] = expiryDate.toIso8601String();
        
        // Recalculate status
        final now = DateTime.now();
        final daysUntilExpiry = expiryDate.difference(now).inDays;
        ProductStatus status;
        if (daysUntilExpiry < 0) {
          status = ProductStatus.expired;
        } else if (daysUntilExpiry <= 7) {
          status = ProductStatus.expiringSoon;
        } else {
          status = ProductStatus.fresh;
        }
        data['status'] = status.value;
      }
      if (remindBeforeDays != null) {
        data['remind_before_days'] = remindBeforeDays;
        if (expiryDate != null && remindBeforeDays > 0) {
          data['reminder_date'] = expiryDate
              .subtract(Duration(days: remindBeforeDays))
              .toIso8601String();
        }
      }

      final response = await _supabase
          .from('products')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Get products by status
  Future<List<Product>> getProductsByStatus(ProductStatus status) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('products')
          .select()
          .eq('user_id', userId)
          .eq('status', status.value)
          .order('expiry_date', ascending: true);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get products expiring today
  Future<List<Product>> getProductsExpiringToday() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final response = await _supabase
          .from('products')
          .select()
          .eq('user_id', userId)
          .gte('expiry_date', startOfDay.toIso8601String())
          .lte('expiry_date', endOfDay.toIso8601String())
          .order('expiry_date', ascending: true);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}