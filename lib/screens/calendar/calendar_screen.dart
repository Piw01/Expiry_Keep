import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/product_model.dart';
import '../product/product_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text(
              'Calendar',
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Month selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Calendar grid
                _buildCalendar(productsAsync),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Products for selected date
          Expanded(
            child: _buildProductsList(productsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(AsyncValue<List<Product>> productsAsync) {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar days
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }
                
                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  dayNumber,
                );
                
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isSameDay(date, DateTime.now());
                
                // Check if any products expire on this date
                final hasProducts = productsAsync.maybeWhen(
                  data: (products) => products.any((p) => 
                    _isSameDay(p.expiryDate, date)
                  ),
                  orElse: () => false,
                );
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.red[600]
                          : isToday
                              ? Colors.red[100]
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      border: hasProducts
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.red[600]
                                  : Colors.black87,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductsList(AsyncValue<List<Product>> productsAsync) {
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (products) {
        final productsOnDate = products.where((p) => 
          _isSameDay(p.expiryDate, _selectedDate)
        ).toList();

        if (productsOnDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada produk yang kedaluwarsa pada\n${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'kedaluwarsa pada ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productsOnDate.length,
                itemBuilder: (context, index) {
                  final product = productsOnDate[index];
                  final categoriesAsync = ref.watch(categoriesProvider);
                  
                  return categoriesAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (categories) {
                      final category = categories.firstWhere(
                        (cat) => cat.id == product.categoryId,
                        orElse: () => categories.first,
                      );
                      
                      return _buildProductCard(product, category);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product, category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product.isExpired
                    ? Colors.red[100]
                    : product.isExpiringSoon
                        ? Colors.orange[100]
                        : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.isExpired
                    ? 'Kadaluwarsa'
                    : product.isExpiringSoon
                        ? 'Soon'
                        : 'Fresh',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: product.isExpired
                      ? Colors.red[700]
                      : product.isExpiringSoon
                          ? Colors.orange[700]
                          : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}