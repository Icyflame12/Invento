import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class SlowMovingItemsPage extends StatefulWidget {
  const SlowMovingItemsPage({super.key});

  @override
  State<SlowMovingItemsPage> createState() => _SlowMovingItemsPageState();
}

class _SlowMovingItemsPageState extends State<SlowMovingItemsPage> {
  List<Productmodel> slowMovingItems = [];
  String filterPeriod = 'day'; // Default filter period is 'day'
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchSlowMovingItems();
  }

  // Show date picker to select start date
  Future<void> _selectStartDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        startDate = selectedDate;
      });
      _selectEndDate(); // Automatically show the end date picker after selecting start date
    }
  }

  // Show date picker to select end date
  Future<void> _selectEndDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        endDate = selectedDate;
      });
      _fetchSlowMovingItems(); // Refetch data after selecting both dates
    }
  }

  Future<void> _fetchSlowMovingItems() async {
    final allProducts = await getAllProducts();
    final allSales = await getAllSales();

    // Use the manually selected start and end date if provided
    DateTime effectiveStartDate = startDate ?? DateTime.now();
    DateTime effectiveEndDate = endDate ?? DateTime.now();

    print('Filter Period: $filterPeriod');
    print('Start Date: $effectiveStartDate');
    print('End Date: $effectiveEndDate');

    // Calculate sales per product per selected period
    List<Productmodel> slowMoving = [];

    for (var product in allProducts) {
      // Filter sales for this product in the selected period
      final salesForProductInPeriod = allSales.where((sale) {
        return sale.productId == product.id &&
            sale.saleDate.isAfter(effectiveStartDate) &&
            sale.saleDate.isBefore(effectiveEndDate
                .add(Duration(days: 1))); // Inclusive of end date
      }).toList();

      // If there are sales for this product in the selected period
      if (salesForProductInPeriod.isNotEmpty) {
        // Calculate the total sales for this product in the selected period
        int totalSalesInPeriod = salesForProductInPeriod.fold(
            0, (sum, sale) => sum + sale.quantitySold);

        // If total sales are below the threshold (less than 10 units), consider it slow-moving
        if (totalSalesInPeriod < 10) {
          slowMoving.add(product);
        }
      }
    }

    setState(() {
      slowMovingItems = slowMoving;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slow Moving Items'),
        actions: [
          // Filter Selector Icon Button
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterPeriod = value;
                if (filterPeriod != 'custom') {
                  startDate = null; // Clear any previously selected date range
                  endDate = null;
                  _fetchSlowMovingItems(); // Refetch data after filter change
                }
              });
              if (filterPeriod == 'custom') {
                _selectStartDate(); // Trigger start date picker for custom range
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'day',
                child: Row(
                  children: [
                    Icon(Icons.today, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text("Per Day"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'week',
                child: Row(
                  children: [
                    Icon(Icons.calendar_view_week,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text("Per Week"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'month',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text("Per Month"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'custom',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text("Custom Range"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: slowMovingItems.isEmpty
          ? Center(
              child: Text(
                'No slow-moving items found for the selected period.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: slowMovingItems.length,
              itemBuilder: (context, index) {
                final product = slowMovingItems[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(Icons.inventory_2,
                        color: theme.colorScheme.primary),
                    title: Text(product.productName),
                    subtitle: Text('Quantity: ${product.productQuantity}'),
                    trailing:
                        Text('\$${product.productPrice.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
    );
  }
}
