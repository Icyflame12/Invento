import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/screens/inventory/Editproduct.dart';
import 'package:inventory_app_final/screens/inventory/fliter_page.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/filter_icon_button.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/product_list.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/search_bar.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  _AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  late TextEditingController _searchController;
  late ValueNotifier<Map<String, dynamic>> filterNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    filterNotifier = ValueNotifier({
      'categories': [],
      'priceRanges': [],
      'stockStatuses': [],
    });

    // Load products into the global ValueNotifier
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await getAllProducts();
    productListNotifier.value = products;
    debugPrint("Loaded ${products.length} products.");
  }

  Future<void> _deleteProduct(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await deleteProduct(id);
      debugPrint("Deleted product with ID: $id.");
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully.')),
      );
    } else {
      debugPrint("Deletion canceled.");
    }
  }

  Future<void> _updateProduct(Productmodel product, int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductScreen(
          product: product,
          productId: product.id,
          onProductUpdated: _loadProducts,
        ),
      ),
    );
  }

  Future<void> _openFilterPage() async {
    final filters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          categories: productListNotifier.value.map((e) => e.category).toList(),
          totalProducts: productListNotifier.value.length,
          filterNotifier: filterNotifier,
        ),
      ),
    );

    if (filters != null) {
      filterNotifier.value = filters;
      setState(() {});
    }
  }

  List<Productmodel> getFilteredProducts(List<Productmodel> allProducts) {
    final filters = filterNotifier.value;
    List<Productmodel> filteredProducts = allProducts;

    if (filters['categories'].isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => filters['categories'].contains(product.category))
          .toList();
    }

    if (filters['priceRanges'].isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return filters['priceRanges'].any((range) =>
            product.productPrice >= range['min'] &&
            product.productPrice <= range['max']);
      }).toList();
    }

    if (filters['stockStatuses'].isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        if (filters['stockStatuses'].contains('In Stock') &&
            product.productQuantity > 10) {
          return true;
        }
        if (filters['stockStatuses'].contains('Out of Stock') &&
            product.productQuantity == 0) {
          return true;
        }
        if (filters['stockStatuses'].contains('Low in Stock') &&
            product.productQuantity > 0 &&
            product.productQuantity <= 10) {
          return true;
        }
        return false;
      }).toList();
    }

    String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) => product.productName.toLowerCase().contains(query))
          .toList();
    }

    return filteredProducts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    filterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          FilterIconButton(onPressed: _openFilterPage),
        ],
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          custom_SearchBar(
            controller: _searchController,
            onSearchChanged: (value) => setState(() {}),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Productmodel>>(
              valueListenable: productListNotifier,
              builder: (context, products, child) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }

                final filteredProducts = getFilteredProducts(products);

                if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text('No products match your search.'));
                }

                return ProductList(
                  products: filteredProducts,
                  onEdit: _updateProduct,
                  onDelete: _deleteProduct,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
