import 'package:flutter/material.dart';
import 'package:inventory_app_final/widgets/inventory/filter_page/category_filter.dart';
import 'package:inventory_app_final/widgets/inventory/filter_page/price_filter.dart';
import 'package:inventory_app_final/widgets/inventory/filter_page/stock_filter.dart';

class FilterPage extends StatefulWidget {
  final List<String> categories;
  final int totalProducts;
  final ValueNotifier<Map<String, dynamic>> filterNotifier;

  const FilterPage({
    super.key,
    required this.categories,
    required this.totalProducts,
    required this.filterNotifier,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String _currentFilter = 'Category';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: _showClearFiltersDialog,
            child: const Text(
              'Clear Filters',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Row(
        children: [
          _buildSidebar(theme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentFilter == 'Category')
                    CategoryFilter(
                      categories: widget.categories.toSet().toList(),
                      onSelectedCategoriesChanged: (selectedCategories) {
                        widget.filterNotifier.value['categories'] =
                            selectedCategories;
                      },
                      initialSelectedCategories: List<String>.from(
                          widget.filterNotifier.value['categories'] ?? []),
                    ),
                  if (_currentFilter == 'Price')
                    PriceFilter(
                      onPriceRangesChanged: (selectedPriceRanges) {
                        widget.filterNotifier.value['priceRanges'] =
                            selectedPriceRanges;
                      },
                      initialSelectedPriceRanges:
                          List<Map<String, dynamic>>.from(
                              widget.filterNotifier.value['priceRanges'] ?? []),
                    ),
                  if (_currentFilter == 'Stock')
                    StockFilter(
                      onStockStatusChanged: (selectedStockStatuses) {
                        widget.filterNotifier.value['stockStatuses'] =
                            selectedStockStatuses;
                      },
                      initialSelectedStockStatuses: List<String>.from(
                          widget.filterNotifier.value['stockStatuses'] ?? []),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 155,
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        children: [
          ListTile(
            title: Text(
              'Category',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            onTap: () => setState(() => _currentFilter = 'Category'),
          ),
          ListTile(
            title: Text(
              'Price Range',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            onTap: () => setState(() => _currentFilter = 'Price'),
          ),
          ListTile(
            title: Text(
              'Stock Availability',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            onTap: () => setState(() => _currentFilter = 'Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return BottomAppBar(
      color: theme.bottomAppBarTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.totalProducts} products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor, // Button color matches theme
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the confirmation dialog (alert)
  void _showClearFiltersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Filters'),
          content: const Text('Are you sure you want to clear all filters?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _clearFilters(); // Clear the filters
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // Clear the filters
  void _clearFilters() {
    setState(() {
      widget.filterNotifier.value = {
        'categories': <String>[],
        'priceRanges': <Map<String, dynamic>>[],
        'stockStatuses': <String>[],
      };
    });
  }

  void _applyFilters() {
    Navigator.pop(context, widget.filterNotifier.value);
  }
}
