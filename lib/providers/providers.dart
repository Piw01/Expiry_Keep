import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Service providers
final productServiceProvider = Provider<ProductService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProductService(supabase);
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CategoryService(supabase);
});

// Products provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return service.getProducts();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategories();
});

// Filter products by status
final freshProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.where((p) => p.isFresh).toList();
});

final expiringSoonProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.where((p) => p.isExpiringSoon).toList();
});

final expiredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.where((p) => p.isExpired).toList();
});

// Statistics provider
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  
  return {
    'total': products.length,
    'fresh': products.where((p) => p.isFresh).length,
    'expiring_soon': products.where((p) => p.isExpiringSoon).length,
    'expired': products.where((p) => p.isExpired).length,
  };
});