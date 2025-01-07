import 'package:flutter/material.dart';
import 'package:inventory_app_final/widgets/inventory/filter_page/category_filter.dart';
import 'package:inventory_app_final/widgets/inventory/filter_page/price_filter.dart';

class SalesFilter extends StatefulWidget {
  final List<String> categories; // Ensure this is a List<String>
  final int totalProducts;
  final ValueNotifier<Map<String, dynamic>> filterNotifier;

  const SalesFilter({
    super.key,
    required this.categories,
    required this.totalProducts,
    required this.filterNotifier,
  });

  @override
  _SalesFilterState createState() => _SalesFilterState();
}

class _SalesFilterState extends State<SalesFilter> {
  String _currentFilter = 'Category';
  List<String> _selectedCategories =
      []; // Declare the selected categories as List<String>

  @override
  Widget build(BuildContext context) {
    print(
        'Categories: ${widget.categories}'); // Debugging: Print categories to check

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: _showClearFiltersDialog,
            child: const Text('Clear Filters',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentFilter == 'Category')
                    Expanded(
                      // Wrap the CategoryFilter widget with Expanded to ensure proper space
                      child: CategoryFilter(
                        categories: widget.categories.toSet().toList(),
                        onSelectedCategoriesChanged: (selectedCategories) {
                          setState(() {
                            _selectedCategories =
                                List<String>.from(selectedCategories);
                            widget.filterNotifier.value['categories'] =
                                _selectedCategories;
                          });
                        },
                        initialSelectedCategories: List<String>.from(
                          widget.filterNotifier.value['categories'] ?? [],
                        ),
                      ),
                    ),
                  if (_currentFilter == 'Price')
                    PriceFilter(
                      onPriceRangesChanged: (selectedPriceRanges) {
                        widget.filterNotifier.value['priceRanges'] =
                            selectedPriceRanges;
                      },
                      initialSelectedPriceRanges:
                          List<Map<String, dynamic>>.from(
                        widget.filterNotifier.value['priceRanges'] ?? [],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 155,
      color: Colors.grey[200],
      child: ListView(
        children: [
          ListTile(
            title: const Text('Category'),
            onTap: () => setState(() => _currentFilter = 'Category'),
          ),
          ListTile(
            title: const Text('Price Range'),
            onTap: () => setState(() => _currentFilter = 'Price'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.totalProducts} products found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
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
      };
    });
  }

  void _applyFilters() {
    Navigator.pop(context, widget.filterNotifier.value);
  }
}
