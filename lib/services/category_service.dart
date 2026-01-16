import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final SupabaseClient _supabase;

  CategoryService(this._supabase);

  // Get all categories for current user (including defaults)
  Future<List<Category>> getCategories() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Initialize default categories for new user - FIXED VERSION
  Future<void> initializeDefaultCategories() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Check if user already has categories
      final existing = await getCategories();
      if (existing.isNotEmpty) return;

      // Call the database function to initialize categories
      await _supabase.rpc('initialize_default_categories', params: {
        'p_user_id': userId,
      });
      
      print('Default categories initialized for user: $userId');
    } catch (e) {
      print('Error initializing categories: $e');
      rethrow;
    }
  }

  // Add new category
  Future<Category> addCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = {
        'user_id': userId,
        'name': name,
        'icon': icon,
        'color': color,
        'is_default': false,
      };

      final response = await _supabase
          .from('categories')
          .insert(data)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update category
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (icon != null) data['icon'] = icon;
      if (color != null) data['color'] = color;

      final response = await _supabase
          .from('categories')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Delete category (only custom ones, not default)
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('is_default', false);
    } catch (e) {
      rethrow;
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}