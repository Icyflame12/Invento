import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/screens/sales/saleDetailsPage.dart';
import 'package:inventory_app_final/widgets/sales/add_sale/proceed_button.dart';
import 'package:inventory_app_final/widgets/sales/add_sale/product_grid.dart';
import 'package:inventory_app_final/widgets/sales/add_sale/search_filter_widget.dart';
import 'package:inventory_app_final/widgets/sales/add_sale/filter_dialog.dart'; // Import the filter dialog

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Productmodel> _allProducts = [];
  List<Productmodel> _filteredProducts = [];
  Set<String> _selectedCategories = {};
  final Set<Productmodel> _selectedProducts = {};

  double? _minPrice;
  double? _maxPrice;

  final ValueNotifier<List<Productmodel>> _filteredProductsNotifier =
      ValueNotifier<List<Productmodel>>([]);

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // Load products from the database or API
    _allProducts = await getAllProducts();
    _filterProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _filteredProductsNotifier.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final lowerCaseQuery = _searchController.text.toLowerCase();
    _filteredProducts = _allProducts.where((product) {
      final matchesQuery =
          product.productName.toLowerCase().contains(lowerCaseQuery) ?? false;
      final matchesPrice =
          (_minPrice == null || product.productPrice >= _minPrice!) &&
              (_maxPrice == null || product.productPrice <= _maxPrice!);
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(product.category);
      return matchesQuery && matchesPrice && matchesCategory;
    }).toList();

    _filteredProductsNotifier.value = _filteredProducts;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          allProducts: _allProducts,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          selectedCategories: _selectedCategories,
          onMinPriceChanged: (newMinPrice) {
            setState(() {
              _minPrice = newMinPrice;
              _filterProducts(); // Re-filter products when min price changes
            });
          },
          onMaxPriceChanged: (newMaxPrice) {
            setState(() {
              _maxPrice = newMaxPrice;
              _filterProducts(); // Re-filter products when max price changes
            });
          },
          onCategoriesChanged: (newSelectedCategories) {
            setState(() {
              _selectedCategories = newSelectedCategories;
              _filterProducts(); // Re-filter products when categories change
            });
          },
        );
      },
    );
  }

  Future<void> _refreshProducts() async {
    // Simulate a network call or database query
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _filterProducts();
    });
  }

  Future<void> proceedToCustomerDetails() async {
    final selectedProducts = _selectedProducts
        .map((product) => {
              'product': product,
              'quantity': 1, // Default quantity
            })
        .toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SaleDetailPage(selectedProducts: selectedProducts),
      ),
    );

    if (result != null && result == 'saleCompleted') {
      // Navigate directly to Main Dashboard and clear the navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', // Main Dashboard route
        (route) => false, // Remove all previous routes
      );
    }
  }

  void _toggleProductSelection(Productmodel product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Sales Page',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Products',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            SearchFilterWidget(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              showFilterDialog: _showFilterDialog,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProducts,
                child: ValueListenableBuilder<List<Productmodel>>(
                  valueListenable: _filteredProductsNotifier,
                  builder: (context, filteredProducts, _) {
                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2 /
                            2.5, // Adjusted aspect ratio to reduce card height
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isSelected = _selectedProducts.contains(product);

                        return ProductCard(
                          product: product,
                          isSelected: isSelected,
                          toggleProductSelection: _toggleProductSelection,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            ProceedButton(proceedToCustomerDetails: proceedToCustomerDetails),
          ],
        ),
      ),
    );
  }
}
