import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class ProductProvider with ChangeNotifier {
  List<Productmodel> _allProducts = [];
  List<Productmodel> _filteredProducts = [];
  String _selectedFilter = 'All'; // Default filter value

  List<Productmodel> get allProducts => _allProducts;
  List<Productmodel> get filteredProducts => _filteredProducts;

  String get selectedFilter => _selectedFilter;

  // Set products list
  void setAllProducts(List<Productmodel> products) {
    _allProducts = products;
    _filteredProducts =
        products; // Initially, set the filtered list as the complete list
    notifyListeners();
  }

  // Apply filter to products
  void filterProducts(String query) {
    final lowerCaseQuery = query.toLowerCase();
    _filteredProducts = _allProducts.where((product) {
      return product.productName.toLowerCase().contains(lowerCaseQuery) ??
          false;
    }).toList();

    if (_selectedFilter != 'All') {
      _filteredProducts = _filteredProducts.where((product) {
        if (_selectedFilter == 'Price') {
          return product.productPrice >
              50; // Example: Filter products above $50
        } else if (_selectedFilter == 'Category') {
          return product.category ==
              'Electronics'; // Example: Filter by category
        }
        return true;
      }).toList();
    }
    notifyListeners();
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    filterProducts('');
  }
}
