import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:note_app/screens/product/add_product_screen.dart';
import 'package:note_app/screens/product/product_detail_screen.dart';
import '../../../providers/providers.dart';
import '../../../models/product_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.access_time_rounded, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text(
              'Expiry Keep',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return _buildEmptyState(context);
          }

          return categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const Center(child: Text('Error loading categories')),
            data: (categories) {
              final categoryMap = {
                for (var cat in categories) cat.id: cat
              };

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(productsProvider);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildStatsSection(ref),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            final category = categoryMap[product.categoryId];
                            return _buildProductCard(context, ref, product, category);
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          ).then((_) => ref.invalidate(productsProvider));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No products yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first product',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(),
      error: (error, stack) => const SizedBox(),
      data: (stats) {
        return Container(
          margin: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Fresh', stats['fresh']!, Colors.green),
              _buildStatItem('Expiring', stats['expiring_soon']!, Colors.orange),
              _buildStatItem('Expired', stats['expired']!, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
    category,
  ) {
    final daysLeft = product.daysUntilExpiry;
    Color statusColor;
    String statusText;

    if (product.isExpired) {
      statusColor = Colors.red;
      statusText = 'Expired';
    } else if (product.isExpiringSoon) {
      statusColor = Colors.orange;
      statusText = '$daysLeft days left';
    } else {
      statusColor = Colors.green;
      statusText = '$daysLeft days left';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        ).then((_) => ref.invalidate(productsProvider));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.isExpired
                ? Colors.red.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    category?.icon ?? '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category?.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, yyyy').format(product.expiryDate),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}